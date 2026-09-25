#Requires -Version 7
Set-StrictMode -Version 3.0
<#
.SYNOPSIS
    Creating metadata of the bicep files.
.DESCRIPTION
    Creating metadata of the bicep files. If the path is not defined, all the bicep files under the current directy and child directory will be used.
.NOTES
    For documentation of the bicep file, check the documentation: https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/file.
.EXAMPLE
    . .\Azure.PlatformProvisioning\Tools\Bicep\Get-BicepMetadata.ps1
    Get-BicepMetadata -path 'Azure.PlatformProvisioning\src-bicep' | ConvertTo-Json -depth 100 | Out-File 'docs.json'

    Creates a docs.json file with the metadata of the bicep files.
#>
function Get-BicepMetadata
{
    [CmdletBinding()]
    param (
        # Path to start searching for
        [Parameter()]
        [string]
        $Path = $PWD
    )

    function Get-DecoratorNumber
    {
        [CmdletBinding()]
        [OutputType([string])]
        param (
            [Parameter()]
            [string]
            $line
        )
        if ($line -match '^@\w+\((?<Number>-?\d+)\)')
        {
            return $matches.Number
        }
        else
        {
            Write-Warning 'Could not fetch the number of decorator'
        }
    }

    function Test-IsResourceDerivedType
    {
        [CmdletBinding()]
        [OutputType([bool])]
        param (
            [Parameter()]
            [string]
            $TypeText
        )

        if ([string]::IsNullOrWhiteSpace($TypeText))
        {
            return $false
        }

        return $TypeText -match "^\s*resource(?:Input|Output)\s*<\s*'[^']+@[^']+'\s*>\s*(?:\.[A-Za-z0-9_\*]+)*\s*(?:\[\])?\??\s*$"
    }

    function Get-DeclarationTypeAndDefault
    {
        [CmdletBinding()]
        [OutputType([hashtable])]
        param (
            [Parameter()]
            [string]
            $LineRemainder
        )

        $result = @{
            Type = $null
            DefaultValue = $null
        }

        if ($LineRemainder -match '^(?<Type>.+?)(?:\s+=\s+(?<DefaultValue>.*))?$')
        {
            $result.Type = $matches.Type.Trim()
            if ($matches.ContainsKey('DefaultValue'))
            {
                $result.DefaultValue = $matches.DefaultValue
            }
        }

        return $result
    }

    Function Add-MetadataBlock
    {
        [CmdletBinding()]
        param (
            [Parameter()]
            [string]
            $SectionName,

            [Parameter(Mandatory)]
            [object]
            $SectionValues,

            # Parameter help description
            [Parameter(Mandatory)]
            [PSCustomObject]
            $MetadataObject

        )
        if ($null -ne $SectionName -and $SectionName -ne [string]::Empty )
        {
            $MetadataObject.Metadata += [PSCustomObject]@{
                Name  = $SectionName
                Value = $SectionValues
            }
        }
    }

    Push-Location
    try
    {
        Set-Location $Path 
   
        # Note: For batch linting/building multiple files, use bicep CLI directly:
        # bicep lint --pattern 'src-bicep/**/*.bicep' (much faster than PowerShell loop)
        $bicepFiles = Get-ChildItem -Filter '*.bicep' -Recurse
        $bicepFiles | ForEach-Object {
            $bicepFile = $_ # $bicepFile = $bicepFiles[0]
            $relativePath = Resolve-Path $bicepFile.Directory -Relative
            $bicepMetaData = [PSCustomObject]@{
                Name          = $bicepFile.BaseName
                Path          = $relativePath       
                TargetScope   = 'resourceGroup'
                Metadata      = @()
                TypeInfo      = @()
                ParameterInfo = @()
                outputInfo    = @()        
            }
            $currentDecorator = @{}
            $multiLine = $false
            $multilineValues = @()
            $multiLineParameter = $null
            $multiLineType = $null
            $multiLineTypeNestingDepth = 0
            $multiLineTypeAwaitingContinuation = $false
            $multilineEnd = $null


            $lines = Get-Content $bicepFile
            $lines | ForEach-Object {
                $line = $_  # $line  = $lines[9]
                Write-Debug ">$line"
            
                if ($multiLine)
                {
                    if ($multiLineDecorator -eq 'type')
                    {
                        $trimmedLine = $line.Trim()

                        if ($multiLineTypeAwaitingContinuation)
                        {
                            if (![string]::IsNullOrWhiteSpace($trimmedLine) -and !$trimmedLine.StartsWith('|'))
                            {
                                $multiLineType.Type = $multilineValues
                                $bicepMetaData.TypeInfo += $multiLineType
                                $multiLineType = $null
                                $multiLineTypeNestingDepth = 0
                                $multiLineTypeAwaitingContinuation = $false
                                $multiLine = $false
                                $multiLineDecorator = $null

                                if ($line -match '^targetScope = ''(?<targetScope>.*)''\s*$')
                                {
                                    $bicepMetaData.TargetScope = $matches.targetScope
                                }
                                elseif ($line -match '^type\s+(?<typeName>\w+)\s*=\s*(?<value>.*)\s*$')
                                {
                                    $typeValue = $matches.value
                                    $typeValueTrimmed = $typeValue.Trim()
                                    if ([string]::IsNullOrWhiteSpace($typeValueTrimmed) -or $typeValueTrimmed -eq '{' -or $typeValueTrimmed -eq '[' -or $typeValueTrimmed.StartsWith('|'))
                                    {
                                        $multiLine = $true
                                        $multiLineDecorator = 'type'
                                        $multiLineType = [PSCustomObject]@{
                                            Name       = $matches.typeName
                                            Type       = $null
                                            Decorators = $currentDecorator
                                        }
                                        $currentDecorator = @{}
                                        $multilineValues = @()
                                        $multiLineTypeNestingDepth = 0
                                        $multiLineTypeAwaitingContinuation = $false

                                        if (![string]::IsNullOrWhiteSpace($typeValueTrimmed))
                                        {
                                            $multilineValues += $typeValue
                                            $multiLineTypeNestingDepth += ([regex]::Matches($typeValue, '[\{\[\(]')).Count
                                            $multiLineTypeNestingDepth -= ([regex]::Matches($typeValue, '[\}\]\)]')).Count
                                        }
                                    }
                                    else
                                    {
                                        $type = [PSCustomObject]@{
                                            Name       = $matches.typeName
                                            Type       = $typeValue
                                            Decorators = $currentDecorator
                                        }
                                        $bicepMetaData.TypeInfo += $type
                                        $currentDecorator = @{}
                                    }
                                }
                                elseif ($line -match '^param\s+(?<ParameterName>[^\s]+)\s+(?<LineRemainder>.+)$')
                                {
                                    $typeAndDefault = Get-DeclarationTypeAndDefault -LineRemainder $matches.LineRemainder
                                    $defaultValue = $typeAndDefault.DefaultValue
                                    $parameter = [PSCustomObject]@{
                                        Name         = $matches.ParameterName
                                        Type         = $typeAndDefault.Type
                                        IsResourceDerivedType = (Test-IsResourceDerivedType -TypeText $typeAndDefault.Type)
                                        DefaultValue = $defaultValue
                                        Decorators   = $currentDecorator
                                    }
                                    $bicepMetaData.ParameterInfo += $parameter

                                    $currentDecorator = @{}
                                    $multiLineParameter = $parameter
                                    if ($defaultValue -eq '{')
                                    {
                                        $multiLine = $true
                                        $multiLineDecorator = 'parameter'
                                        $multilineEndsLike = '}*'
                                        $multilineEnd = '}'
                                        $multilineValues = @('{')

                                    }
                                    elseif ($defaultValue -eq '[')
                                    {
                                        $multiLine = $true
                                        $multiLineDecorator = 'parameter'
                                        $multilineEndsLike = ']*'
                                        $multilineEnd = ']'
                                        $multilineValues = @('[')
                                    }
                                }
                                elseif ($line -match '^output\s+(?<OutputName>[^\s]+)\s+(?<LineRemainder>.+)$')
                                {
                                    $typeAndDefault = Get-DeclarationTypeAndDefault -LineRemainder $matches.LineRemainder
                                    $output = [PSCustomObject]@{
                                        Name       = $matches.OutputName
                                        Type       = $typeAndDefault.Type
                                        IsResourceDerivedType = (Test-IsResourceDerivedType -TypeText $typeAndDefault.Type)
                                        Decorators = $currentDecorator
                                    }
                                    $bicepMetaData.outputInfo += $output
                                    $currentDecorator = @{}
                                }
                                elseif ($line -like '/`*')
                                {
                                    $multiline = $true
                                    $multiLineDecorator = 'MultiLineComment'
                                    $multilineEndsLike = '*`*/'
                                    $multilineValues = @()
                                    $multilineCommentSection = [String]::Empty
                                }
                                elseif ($line -like '@*')
                                {
                                    if ($line -match '^@(?<DecoratorName>[\w.]+)\(')
                                    {
                                        $decoratorName = ($matches.DecoratorName).ToLower()
                                        switch ($decoratorName)
                                        {
                                            'allowed'
                                            {
                                                if ($line -notlike '*])')
                                                {
                                                    $multiline = $true
                                                    $multiLineDecorator = $decoratorName
                                                    $multilineEndsLike = '])'
                                                    $multilineValues = @()
                                                }
                                            }
                                            'sys.description'
                                            {
                                                if ($line -like "@sys.description('''*")
                                                {
                                                    $multiline = $true
                                                    $multiLineDecorator = 'description'
                                                    $multilineEndsLike = "*''')"
                                                    $multilineValues = @()
                                                }
                                                elseif ($line -match '^@sys\.description\(''(?<Description>.*)''\)\s*(?:\/\/.*)?$')
                                                {
                                                    $currentDecorator.Add($decoratorName, $matches.Description)
                                                }
                                            }
                                            'description'
                                            {
                                                if ($line -like "@description('''*")
                                                {
                                                    $multiline = $true
                                                    $multiLineDecorator = $decoratorName
                                                    $multilineEndsLike = "*''')"
                                                    $multilineValues = @()
                                                }
                                                elseif ($line -match '^@description\(''(?<Description>.*)''\)\s*(?:\/\/.*)?$')
                                                {
                                                    $currentDecorator.Add($decoratorName, $matches.Description)
                                                }
                                            }
                                            'discriminator'
                                            {
                                                if ($line -match '^@discriminator\(''(?<type>.*)''\)\s*(?:\/\/.*)?$')
                                                {
                                                    $currentDecorator.Add($decoratorName, $matches.type)
                                                }
                                            }
                                            'maxLength' { $currentDecorator.Add($decoratorName, (Get-DecoratorNumber -line $line)) }
                                            'minLength' { $currentDecorator.Add($decoratorName, (Get-DecoratorNumber -line $line)) }
                                            'maxValue' { $currentDecorator.Add($decoratorName, (Get-DecoratorNumber -line $line)) }
                                            'minValue' { $currentDecorator.Add($decoratorName, (Get-DecoratorNumber -line $line)) }
                                            'secure' { $currentDecorator.Add($decoratorName, '') }
                                            'export' { $currentDecorator.Add($decoratorName, '') }
                                        }
                                    }
                                }
                                elseif ($line -notmatch '^\s*$' -and $currentDecorator.Count -gt 0)
                                {
                                    $currentDecorator = @{}
                                }

                                return
                            }

                            $multiLineTypeAwaitingContinuation = $false
                        }

                        $multilineValues += $line
                        $multiLineTypeNestingDepth += ([regex]::Matches($line, '[\{\[\(]')).Count
                        $multiLineTypeNestingDepth -= ([regex]::Matches($line, '[\}\]\)]')).Count

                        if ($multiLineTypeNestingDepth -le 0)
                        {
                            $multiLineTypeAwaitingContinuation = $true
                        }

                        return
                    }

                    if ($line -like $multilineEndsLike )
                    { 
                        if ($multiLineDecorator -eq 'parameter')
                        {
                            $multilineValues += $multilineEnd 
                            $multiLineParameter.DefaultValue = $multilineValues
                        }
                        elseif ($multiLineDecorator -eq 'MultiLineComment')
                        {
                            Add-MetadataBlock -MetadataObject $bicepMetaData -SectionName $multilineCommentSection -SectionValues $multilineValues
                            $multilineValues = @()
                        }
                        else
                        {
                            $currentDecorator.Add($multiLineDecorator, $multilineValues)
                            Write-Debug "Add decorator for $multiLineDecorator"
                        }
                        $multiLine = $false
                    }
                    else
                    {
                        $valueToAdd = $null
                        switch ($multiLineDecorator)
                        {
                            'allowed'
                            { 
                                if ($line -match '^\s*(?<string>''?)(?<value>[^'']*?)''?\s*$')
                                {
                                    $valueToAdd = "$($matches.string)$($matches.value)$($matches.string)"
                                }
                                else
                                {
                                    Write-Warning "Cannot parse the value for the allowed decorator: '$line'"
                                }
                            }
                            'description' { $valueToAdd = $line }
                            'discriminator' { $valueToAdd = $line }
                            'parameter' { $valueToAdd = $line }
                            'MultiLineComment'
                            {
                                if ($line.StartsWith('.') -and $line -match '\.(?<SectionName>.+)')
                                {
                                    Add-MetadataBlock -MetadataObject $bicepMetaData -SectionName $multilineCommentSection -SectionValues $multilineValues
                                    $multilineValues = @()
                                    $multilineCommentSection = $matches.SectionName.Trim()
                                    return
                                }
                                else
                                {
                                    $valueToAdd = $line
                                }
                            }
                            Default
                            { 
                                Write-Warning 'Cannot parse the value for the unknown  decorator'
                            }
                        }
                        Write-Debug "Add for decorator '$multiLineDecorator' value '$valueToAdd'"
                        $multilineValues += $valueToAdd
                    }
                    return
                }
                else
                {
                    if ($line -like 'targetScope *')
                    {
                        if ($line -match '^targetScope = ''(?<targetScope>.*)''\s*$')
                        {
                            $bicepMetaData.TargetScope = $matches.targetScope             
                        }
                        else
                        {
                            Write-Warning "Could not match target scope '$line'"
                        }
                    }
                    elseif ($line -like 'type *')
                    {
                        if ($line -match '^type\s+(?<typeName>\w+)\s*=\s*(?<value>.*)\s*$')
                        {
                            $typeValue = $matches.value
                            $typeValueTrimmed = $typeValue.Trim()

                            if ([string]::IsNullOrWhiteSpace($typeValueTrimmed) -or $typeValueTrimmed -eq '{' -or $typeValueTrimmed -eq '[' -or $typeValueTrimmed.StartsWith('|'))
                            {
                                $multiLine = $true
                                $multiLineDecorator = 'type'
                                $multiLineType = [PSCustomObject]@{
                                    Name       = $matches.typeName
                                    Type       = $null
                                    Decorators = $currentDecorator
                                }
                                $currentDecorator = @{}
                                $multilineValues = @()
                                $multiLineTypeNestingDepth = 0
                                $multiLineTypeAwaitingContinuation = $false

                                if (![string]::IsNullOrWhiteSpace($typeValueTrimmed))
                                {
                                    $multilineValues += $typeValue
                                    $multiLineTypeNestingDepth += ([regex]::Matches($typeValue, '[\{\[\(]')).Count
                                    $multiLineTypeNestingDepth -= ([regex]::Matches($typeValue, '[\}\]\)]')).Count
                                }
                            }
                            else
                            {
                                $type = [PSCustomObject]@{
                                    Name       = $matches.typeName
                                    Type       = $typeValue
                                    Decorators = $currentDecorator
                                }
                                $bicepMetaData.TypeInfo += $type
                                $currentDecorator = @{}
                            }
                        }
                        else
                        {
                            Write-Warning "Could not match type line '$line'"
                        }
                    }
                    elseif ($line -like 'param *')
                    {
                        if ($line -match '^param\s+(?<ParameterName>[^\s]+)\s+(?<LineRemainder>.+)$')
                        {
                            $typeAndDefault = Get-DeclarationTypeAndDefault -LineRemainder $matches.LineRemainder
                            $defaultValue = $typeAndDefault.DefaultValue
                            $parameter = [PSCustomObject]@{
                                Name         = $matches.ParameterName
                                Type         = $typeAndDefault.Type
                                IsResourceDerivedType = (Test-IsResourceDerivedType -TypeText $typeAndDefault.Type)
                                DefaultValue = $defaultValue 
                                Decorators   = $currentDecorator
                            }
                            $bicepMetaData.ParameterInfo += $parameter 

                            $currentDecorator = @{}
                            $multiLineParameter = $parameter
                            if ($defaultValue -eq '{')
                            {
                                $multiLine = $true
                                $multiLineDecorator = 'parameter'
                                $multilineEndsLike = '}*'
                                $multilineEnd = '}'
                                $multilineValues = @('{')

                            }
                            elseif ($defaultValue -eq '[')
                            {
                                $multiLine = $true
                                $multiLineDecorator = 'parameter'
                                $multilineEndsLike = ']*'
                                $multilineEnd = ']'
                                $multilineValues = @('[')
                            }
                        }
                        else
                        {
                            Write-Warning "Could not match param line '$line'"
                        }
                    }
                    elseif ($line -like 'output *')
                    {

                        if ($line -match '^output\s+(?<OutputName>[^\s]+)\s+(?<LineRemainder>.+)$')
                        {
                            $typeAndDefault = Get-DeclarationTypeAndDefault -LineRemainder $matches.LineRemainder
                            $output = [PSCustomObject]@{
                                Name       = $matches.OutputName
                                Type       = $typeAndDefault.Type
                                IsResourceDerivedType = (Test-IsResourceDerivedType -TypeText $typeAndDefault.Type)
                                Decorators = $currentDecorator
                            }
                            $bicepMetaData.outputInfo += $output 
                            $currentDecorator = @{}
                        }
                        else
                        {
                            Write-Warning "Could not match output line '$line'"
                        }
                    }
                    elseif ($line -like '/`*')
                    {
                        $multiline = $true
                        $multiLineDecorator = 'MultiLineComment'
                        $multilineEndsLike = '*`*/'
                        $multilineValues = @()
                        $multilineCommentSection = [String]::Empty
                    }
                    elseif ($line -like '@*')
                    {
                
                        if ($line -match '^@(?<DecoratorName>[\w.]+)\(')
                        {
                            $decoratorName = ($matches.DecoratorName).ToLower()
                            Write-Debug "Processing decorator $decoratorName"
                            switch ($decoratorName)
                            {
                                'allowed'
                                { 
                                    if ($line -like '*])')
                                    {
                                        Write-Warning "Single line allow?'$line'"
                                    }
                                    else
                                    {
                                        $multiline = $true
                                        $multiLineDecorator = $decoratorName
                                        $multilineEndsLike = '])'
                                        $multilineValues = @()
                                    }
                             
                                }
                                'sys.description'
                                 {             
                                    if ($line -like "@sys.description('''*")
                                    {
                                        $multiline = $true
                                        $multiLineDecorator = 'description'
                                        $multilineEndsLike = "*''')"
                                        $multilineValues = @()
                                    }
                                    else
                                    {
                                        if ($line -match '^@sys\.description\(''(?<Description>.*)''\)\s*(?:\/\/.*)?$')
                                        {
                                            $currentDecorator.Add($decoratorName , $matches.Description )
                                        }
                                        else
                                        {
                                            Write-Warning "Could not parse description '$line'"
                                        }
                                    }
                                }
                                'description'
                                {             
                                    if ($line -like "@description('''*")
                                    {
                                        $multiline = $true
                                        $multiLineDecorator = $decoratorName
                                        $multilineEndsLike = "*''')"
                                        $multilineValues = @()
                                    }
                                    else
                                    {
                                        if ($line -match '^@description\(''(?<Description>.*)''\)\s*(?:\/\/.*)?$')
                                        {
                                            $currentDecorator.Add($decoratorName , $matches.Description )
                                        }
                                        else
                                        {
                                            Write-Warning "Could not parse description '$line'"
                                        }
                                    }
                                }
                                'discriminator'
                                {
                                    if ($line -match '^@discriminator\(''(?<type>.*)''\)\s*(?:\/\/.*)?$')
                                    {
                                        $currentDecorator.Add($decoratorName , $matches.type )
                                    }
                                    else
                                    {
                                        Write-Warning "Could not parse discriminator '$line'"
                                    }
                                } 
                                'maxLength' { $currentDecorator.Add($decoratorName , (Get-DecoratorNumber -line $line)) }
                                'minLength' { $currentDecorator.Add($decoratorName , (Get-DecoratorNumber -line $line)) }
                                'maxValue' { $currentDecorator.Add($decoratorName , (Get-DecoratorNumber -line $line)) }
                                'minValue' { $currentDecorator.Add($decoratorName , (Get-DecoratorNumber -line $line)) }
                                'secure' { $currentDecorator.Add($decoratorName , '' ) }
                                'export' { $currentDecorator.Add($decoratorName , '' ) }
                                Default
                                {
                                    Write-Warning "Could not process decorator '$decoratorName'"
                                }
                            }
                        }
                        else
                        {
                            Write-Warning "Could not figure out the decorator name'$line'"
                        }
                    }
                    elseif ($line -match '^\s*$' )
                    { 
                        Write-Debug "empty line don't clear the decorators"
                    }
                    else
                    {
                        if ( $currentDecorator.Count -gt 0)
                        {
                            Write-Debug "Clean decorators for  $line"
                            $currentDecorator = @{}
                        }
                    }
                }
            }

            if ($multiLine -and $multiLineDecorator -eq 'type' -and $null -ne $multiLineType)
            {
                $multiLineType.Type = $multilineValues
                $bicepMetaData.TypeInfo += $multiLineType
                $multiLineType = $null
                $multiLine = $false
                $multiLineDecorator = $null
            }

            return $bicepMetaData
        }
    }
    finally
    {
        Pop-Location
    }
}