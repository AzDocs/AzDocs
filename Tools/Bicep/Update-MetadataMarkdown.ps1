#Requires -Version 7
Set-StrictMode -Version 3.0
<#
@metadata({
  Columns : [
    {
        name : 'Example'
        value =  'Tadat'
    }]
  }
  Groups : [
    { 
        Name: 'Private dns stufffy'
        Required : yes

    } 
  ]
  RequiredOverride : true
  ShowRequired: false
})

#>

<#
.SYNOPSIS
    Creating or updated the markdown files based on the given metadata
.DESCRIPTION
    Creating or updated the markdown files based on the given metadata.
.EXAMPLE
    . .\Tools\Bicep\Get-BicepMetadata.ps1
    . .\Tools\Bicep\Update-MetadataMarkdown.ps1
    $metadata = Get-BicepMetadata -path 'src-bicep'
    Update-MetadataMarkdown -Metadata $metadata -DestinationPath 'Wiki\Azure\AzDocs-v2\Modules'

    Loading the functions, fetching the metadata from the bicep files in te 'Azure.PlatformProvisioning\src-bicep' directory in the $metadata variable. 
    Creating the Markdown files in the 'docs' destination directory based on the given $metadata variable that has been created in the previous statement.
#>
function Update-MetadataMarkdown
{
    [CmdletBinding()]
    param (
        # Metadata of the bicep files created by the Get-BicepMetadata function
        [Parameter(Mandatory)]
        [PSCustomObject]
        $Metadata,

        # Destination Path where the markdown files should be created
        [Parameter()]
        [string]
        $DestinationPath = $PWD,


        # If this switch is used, then the destination folder is not deleted.
        [Parameter()]
        [switch]
        $KeepDestinationPath
    )

    function ConvertTo-SpaceWithHtmlSpaces
    {
        [CmdletBinding()]
        param (
            [Parameter()]
            [string[]]
            $lines
        )
        $lines | ForEach-Object { 
            $singleDescription = $_
            $newDescription = $singleDescription.TrimStart()
            if ($newDescription.Length -ne $singleDescription.Length)
            {
                $neededBreakspaces = $singleDescription.Length - $newDescription.Length
                0..$neededBreakspaces | ForEach-Object {
                    $newDescription = "&nbsp;$newDescription"
                } 
            }
            return $newDescription
        }
    }

    Function New-MarkdownSection
    {
        [CmdletBinding()]
        param ( 
            [Parameter()]
            [System.IO.StreamWriter]
            $StreamWriter,
        
            [Parameter()]
            [string]
            $Header,

            [Parameter()]
            [array]
            $lines,

            # Parameter help description
            [Parameter()]
            [switch]
            $NoBreak
        )
        if ($lines)
        {
            $StreamWriter.WriteLine() | Out-Null
            $StreamWriter.WriteLine("## $Header") | Out-Null
            $sb = [System.Text.StringBuilder]::new()
            $inPre = $false
            for ($i = 0; $i -lt $lines.Count; $i++)
            {
                $currentLine = $lines[$i]
                if ($currentLine -match '<pre>') { $inPre = $true }
                if ($i -gt 0)
                {
                    if ($inPre -or $NoBreak)
                    {
                        $sb.Append("`r`n") | Out-Null
                    }
                    else
                    {
                        $sb.Append("<br>`r`n") | Out-Null
                    }
                }
                $sb.Append($currentLine) | Out-Null
                if ($currentLine -match '</pre>') { $inPre = $false }
            }
            $newLines = $sb.ToString()
            $StreamWriter.WriteLine($newLines) | Out-Null 
        }
    }

    function ConvertTo-MarkDownSanitizedText
    {
        [CmdletBinding()]
        param (
            [Parameter( ValueFromPipeline)]
            [string]
            $string
        )
        process
        {
            return $string | ForEach-Object { $_.Replace('|' , '&#124;').Replace('$', '&#36;') } 
        }
       
    }

    function ConvertTo-SingularResourceName
    {
        [CmdletBinding()]
        [OutputType([string])]
        param (
            [Parameter(Mandatory)]
            [string]
            $ResourceName
        )

        if ($ResourceName -match 'ies$')
        {
            return "$($ResourceName.Substring(0, $ResourceName.Length - 3))y"
        }

        if ($ResourceName -match '(xes|ses|zes|ches|shes)$')
        {
            return $ResourceName.Substring(0, $ResourceName.Length - 2)
        }

        if ($ResourceName -match 's$')
        {
            return $ResourceName.Substring(0, $ResourceName.Length - 1)
        }

        return $ResourceName
    }

    function ConvertTo-ResourceTypeDocLink
    {
        [CmdletBinding()]
        [OutputType([string])]
        param (
            [Parameter(Mandatory)]
            [string]
            $TypeText
        )

        # Link resource-derived Bicep types to Azure template references when possible.
        if ($TypeText -notmatch "^(?<TypeKind>resourceInput|resourceOutput)<\s*'(?<ResourceType>[^@']+)@(?<ApiVersion>[^']+)'\s*>\s*(?<PropertyPath>(?:\.[A-Za-z0-9_\*]+)*)(?<TypeSuffix>(?:\[\])*\??)$")
        {
            return $TypeText
        }

        $resourceType = $matches.ResourceType
        $apiVersion = $matches.ApiVersion
        $typeSuffix = $matches.TypeSuffix

        $resourceTypeSegments = $resourceType.Split('/')
        if ($resourceTypeSegments.Count -lt 2)
        {
            return $TypeText
        }

        $providerNamespace = $resourceTypeSegments[0].ToLowerInvariant()
        $resourcePath = ($resourceTypeSegments[1..($resourceTypeSegments.Count - 1)] | ForEach-Object { $_.ToLowerInvariant() }) -join '/'
        $documentationUrl = "https://learn.microsoft.com/en-us/azure/templates/$providerNamespace/$apiVersion/${resourcePath}?pivots=deployment-language-bicep"

        # Keep links stable by pointing to the template landing page only.
        # Property anchors are not guaranteed to remain stable across docs updates.

        $displayType = "resourceInput<'$resourceType@$apiVersion'>$($matches.PropertyPath)"
        if ($matches.TypeKind -eq 'resourceOutput')
        {
            $displayType = "resourceOutput<'$resourceType@$apiVersion'>$($matches.PropertyPath)"
        }

        return "[$displayType]($documentationUrl)$typeSuffix"
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

    function Test-HasResourceDerivedTypes
    {
        [CmdletBinding()]
        [OutputType([bool])]
        param (
            [Parameter(Mandatory)]
            [PSCustomObject]
            $FileMetadata
        )

        foreach ($parameterInfo in ($FileMetadata.ParameterInfo ?? @()))
        {
            if (Test-IsResourceDerivedType -TypeText $parameterInfo.Type)
            {
                return $true
            }
        }

        foreach ($outputInfo in ($FileMetadata.OutputInfo ?? @()))
        {
            if (Test-IsResourceDerivedType -TypeText $outputInfo.Type)
            {
                return $true
            }
        }

        return $false
    }

    function Add-ResourceDerivedTypesNote
    {
        [CmdletBinding()]
        param (
            [Parameter(Mandatory)]
            [System.IO.StreamWriter]
            $StreamWriter,

            [Parameter(Mandatory)]
            [PSCustomObject]
            $FileMetadata
        )

        if (-not (Test-HasResourceDerivedTypes -FileMetadata $FileMetadata))
        {
            return
        }

        $StreamWriter.WriteLine() | Out-Null
        $StreamWriter.WriteLine('> [!NOTE]') | Out-Null
        $StreamWriter.WriteLine('> This module uses Bicep resource-derived types (`resourceInput<>` / `resourceOutput<>`).') | Out-Null
        $StreamWriter.WriteLine('> - [Resource-derived types](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/user-defined-data-types#resource-derived-types)') | Out-Null
        $StreamWriter.WriteLine('> - [Bicep data types](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/data-types)') | Out-Null
    }

    function ConvertTo-UserDefinedTypeLink
    {
        [CmdletBinding()]
        [OutputType([string])]
        param (
            [Parameter(Mandatory)]
            [string]
            $TypeText,

            [Parameter()]
            [AllowEmptyCollection()]
            [string[]]
            $UserDefinedTypes = @()
        )

        if ($TypeText -match '^(?<BaseType>[A-Za-z_][A-Za-z0-9_]*)(?<Suffix>(?:\[\])*\??)$' -and $matches.BaseType -in $UserDefinedTypes)
        {
            return "[$($matches.BaseType)](#$($matches.BaseType))$($matches.Suffix)"
        }

        return $TypeText
    }

    Function Add-ParametersSection
    {
        [CmdletBinding()]
        param ( 
            [Parameter(Mandatory)]
            [System.IO.StreamWriter]
            $StreamWriter,

            [Parameter(Mandatory)]
            [PSCustomObject[]]
            $ParameterInfos,

            # Parameter help description
            [Parameter()]
            [string[]]
            $UserDefinedTypes
        )
        $StreamWriter.WriteLine('## Parameters') | Out-Null
        $StreamWriter.WriteLine('| Name | Type | Required | Validation | Default value | Description |') | Out-Null
        $StreamWriter.WriteLine('| -- |  -- | -- | -- | -- | -- |') | Out-Null
        $ParameterInfos | ForEach-Object { 
            $parameterInfo = $_ #  $parameterInfo  =  $singleFileMetadata.ParameterInfo[0]
            $validation = 'None'
            $allowedDecorator = $parameterInfo.Decorators['allowed'] ?? $null
            if ($allowedDecorator)
            {
                $validation = $allowedDecorator | Join-String -Separator '` or `' -OutputPrefix '`' -OutputSuffix '`' | Out-String -NoNewline
            }
            elseif (Test-IsResourceDerivedType -TypeText $parameterInfo.Type)
            {
                $validation = 'Schema-constrained (resource-derived type)'
            }

            if ($parameterInfo.Decorators.ContainsKey('minLength') -or $parameterInfo.Decorators.ContainsKey('maxLength'))
            {
                $min = $parameterInfo.Decorators['minLength'] ?? '0'
                $max = $parameterInfo.Decorators['maxLength'] ?? '*'
                if ($min -eq $max)
                {
                    $validation = "Length is $min"
                }
                else
                {
                    $validation = "Length between $min-$max"
                }
                    
            }

            if ($parameterInfo.Decorators.ContainsKey('minValue') -or $parameterInfo.Decorators.ContainsKey('maxValue'))
            {
                $min = $parameterInfo.Decorators['minValue'] ?? '0'
                $max = $parameterInfo.Decorators['maxValue'] ?? '*'
                if ($min -eq $max)
                {
                    $validation = "Value is $min"
                }
                else
                {
                    $validation = "Value between $min-$max"
                }
                    
            }
            
            $description = $parameterInfo.Decorators['description'] ?? $null | ConvertTo-MarkDownSanitizedText
   
            if (![string]::IsNullOrEmpty($description) -and $parameterInfo.Decorators.description -is [array] -and $parameterInfo.Decorators.description.Count -gt 1 )
            {
                $spacedDescription = ConvertTo-SpaceWithHtmlSpaces -lines $parameterInfo.Decorators.description
                $description = $spacedDescription | Join-String -Separator '<br>' | ConvertTo-MarkDownSanitizedText
            }
   
            $defaultValue = $parameterInfo.DefaultValue | ConvertTo-MarkDownSanitizedText
            if (![string]::IsNullOrEmpty($description) -and $parameterInfo.DefaultValue -is [array] -and $parameterInfo.DefaultValue.Count -gt 1)
            {
                $defaultValue = $parameterInfo.DefaultValue | Join-String -Separator '<br>' | ConvertTo-MarkDownSanitizedText
            }
            $required = "<input type=""checkbox""$($null -eq $parameterInfo.DefaultValue ? ' checked' : '')>"

            $parameterTypeText = ConvertTo-UserDefinedTypeLink -TypeText $parameterInfo.Type -UserDefinedTypes $UserDefinedTypes
            if ($parameterTypeText -eq $parameterInfo.Type)
            {
                $parameterTypeText = ConvertTo-ResourceTypeDocLink -TypeText $parameterInfo.Type
            }

            $StreamWriter.WriteLine("| $($parameterInfo.Name) | $parameterTypeText | $required | $validation | <pre>$defaultValue</pre> | $description |") | Out-Null   
        }
    }


    function Add-TypeSection
    {
        [CmdletBinding()]
        param (
            [Parameter()]
            [System.IO.StreamWriter]
            $StreamWriter,

            [Parameter()]
            [PSCustomObject[]]
            $UserDefinedTypes 
        )
        
        if ($UserDefinedTypes)
        {
            $StreamWriter.WriteLine() | Out-Null
            $StreamWriter.WriteLine('## User Defined Types') | Out-Null
            $StreamWriter.WriteLine('| Name | Type | Discriminator | Description') | Out-Null
            $StreamWriter.WriteLine('| -- |  -- | -- | -- |') | Out-Null
            $UserDefinedTypes | ForEach-Object { 
                $outputInfo = $_ #  $parameterInfo  =  $singleFileMetadata.ParameterInfo[0]
                $typeText = $outputInfo.Type
                if ($typeText -is [array])
                {
                    if ($typeText.Count -gt 1)
                    {
                        $spacedType = ConvertTo-SpaceWithHtmlSpaces -lines $typeText
                        $typeText = $spacedType | Join-String -Separator '<br>' | ConvertTo-MarkDownSanitizedText
                    }
                    else
                    {
                        $typeText = $typeText[0] | ConvertTo-MarkDownSanitizedText
                    }
                }
                else
                {
                    $typeText = $typeText | ConvertTo-MarkDownSanitizedText
                }

                $StreamWriter.WriteLine("| <a id=""$($outputInfo.Name)"">$($outputInfo.Name)</a>  | <pre>$typeText</pre> | $($outputInfo.Decorators['discriminator'] ?? $null ) | $($outputInfo.Decorators['description'] ?? $null ) | ") | Out-Null

            }
        }
    }


    function Add-OutputsSection
    {
        [CmdletBinding()]
        param (
            [Parameter()]
            [System.IO.StreamWriter]
            $StreamWriter,

            [Parameter()]
            [PSCustomObject[]]
            $Outputs
        )
        
        if ($Outputs)
        {
            $StreamWriter.WriteLine() | Out-Null
            $StreamWriter.WriteLine('## Outputs') | Out-Null
            $StreamWriter.WriteLine('| Name | Type | Description |') | Out-Null
            $StreamWriter.WriteLine('| -- |  -- | -- |') | Out-Null
            $Outputs | ForEach-Object { 
                $outputInfo = $_ #  $parameterInfo  =  $singleFileMetadata.ParameterInfo[0]
                $outputTypeText = ConvertTo-ResourceTypeDocLink -TypeText $outputInfo.Type
                $StreamWriter.WriteLine("| $($outputInfo.Name) | $outputTypeText | $($outputInfo.Decorators['description'] ?? $null ) |") | Out-Null

            }
        }
    }

    function Add-TargetScopeSection
    {
        [CmdletBinding()]
        param (
            [Parameter()]
            [System.IO.StreamWriter]
            $StreamWriter,

            [Parameter()]
            [string]
            $TargetScope
        )
        $StreamWriter.WriteLine("Target Scope: $($singleFileMetadata.TargetScope)") | Out-Null

    }

    if (!$KeepDestinationPath)
    {
        if (Test-Path $DestinationPath)
        {
            $cleanCurrentPath = $DestinationPath -eq $pwd
            if ($cleanCurrentPath )
            {
                Push-Location
                Set-Location '..'
            }      
 
            Remove-Item $DestinationPath -Recurse
           
            if ($cleanCurrentPath )
            {
                Pop-Location
            } 
        }
    }


    $Metadata | ForEach-Object {
        $singleFileMetadata = $_ #  $singleFileMetadata  = $Metadata[0]
        try
        {
            
            $destinationFolder = Join-Path -Path $DestinationPath -ChildPath $singleFileMetadata.Path
            if (!(Test-Path $destinationFolder))
            {
                New-Item -Path $destinationFolder -ItemType Directory | Out-Null
            }
            $destinationFile = Join-Path -Path $destinationFolder -ChildPath "$($singleFileMetadata.Name).md"
      
            $streamWriter = [System.IO.StreamWriter]::new($destinationFile, $false, [System.Text.Encoding]::UTF8)
            $streamWriter.NewLine = "`r`n"

            $streamWriter.WriteLine("# $($singleFileMetadata.Name)") | Out-Null

            $streamWriter.WriteLine() | Out-Null
            Add-TargetScopeSection -StreamWriter $streamWriter -TargetScope $singleFileMetadata.TargetScope
            Add-ResourceDerivedTypesNote -StreamWriter $streamWriter -FileMetadata $singleFileMetadata

            Add-TypeSection -StreamWriter $streamWriter -UserDefinedTypes $singleFileMetadata.TypeInfo

            New-MarkdownSection -StreamWriter $streamWriter -Header 'Synopsis' -lines ($singleFileMetadata.Metadata | Where-Object Name -EQ 'Synopsis' | Select-Object -ExpandProperty Value)
            New-MarkdownSection -StreamWriter $streamWriter -Header 'Description' -lines ($singleFileMetadata.Metadata | Where-Object Name -EQ 'Description' | Select-Object -ExpandProperty Value)
            New-MarkdownSection -StreamWriter $streamWriter -Header 'Security Default' -lines ($singleFileMetadata.Metadata | Where-Object Name -EQ 'SECURITY_DEFAULTS' | Select-Object -ExpandProperty Value)

            if ($singleFileMetadata.ParameterInfo)
            {
                $streamWriter.WriteLine() | Out-Null
                $userDefinedTypes = $singleFileMetadata.TypeInfo ? $singleFileMetadata.TypeInfo.Name : @()
                Add-ParametersSection -StreamWriter $streamWriter -ParameterInfos $singleFileMetadata.ParameterInfo -UserDefinedTypes $userDefinedTypes

            }
           
            Add-OutputsSection -StreamWriter $streamWriter -Outputs $singleFileMetadata.outputInfo
            New-MarkdownSection -StreamWriter $streamWriter -Header 'Examples' -lines ($singleFileMetadata.Metadata | Where-Object Name -EQ 'Example' | Select-Object -ExpandProperty Value) -NoBreak
            New-MarkdownSection -StreamWriter $streamWriter -Header 'Links' -lines ($singleFileMetadata.Metadata | Where-Object Name -EQ 'Links' | Select-Object -ExpandProperty Value)
            $streamWriter.Flush()
        }
        finally
        {
            if ($null -ne $streamWriter -and $streamWriter -is [System.IDisposable])
            {
                $streamWriter.Dispose()
                $streamWriter = $null
            }
        }
    }
}