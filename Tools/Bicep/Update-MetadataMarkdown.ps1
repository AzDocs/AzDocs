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
    . .\Azure.PlatformProvisioning\Tools\Bicep\Get-BicepMetadata.ps1
    . .\Azure.PlatformProvisioning\Tools\Bicep\Update-MetadataMarkdown.ps1
    $metadata = Get-BicepMetadata -path 'Azure.PlatformProvisioning\src-bicep'
    Update-MetadataMarkdown -Metadata $metadata -DestinationPath 'Azure.PlatformProvisioning\Wiki\Azure\AzDocs-v2\Modules'

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
            $br = '<br>'
            if ($NoBreak)
            {
                $br = ''
            }
            $newLines = $lines | Join-String -Separator "$br`r`n" 
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

            $parameterTypeText = $parameterInfo.Type -contains $UserDefinedTypes ? "[$($parameterInfo.Type)](#$($parameterInfo.Type))" : $parameterInfo.Type

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
                $StreamWriter.WriteLine("| <a id=""$($outputInfo.Name)"">$($outputInfo.Name)</a>  | <pre>$($outputInfo.Type | ConvertTo-MarkDownSanitizedText )</pre> | $($outputInfo.Decorators['discriminator'] ?? $null ) | $($outputInfo.Decorators['description'] ?? $null ) | ") | Out-Null

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
                $StreamWriter.WriteLine("| $($outputInfo.Name) | $($outputInfo.Type) | $($outputInfo.Decorators['description'] ?? $null ) |") | Out-Null

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