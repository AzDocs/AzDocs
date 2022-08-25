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
            $newDescription = $singleDescription.TrimStart();
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
            [System.Text.StringBuilder]
            $StringBuilder,
        
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
            $StringBuilder.AppendLine("## $Header") | Out-Null
            $br = '<br>'
            if ($NoBreak)
            {
                $br = ''
            }
            $newLines = $lines | Join-String -Separator "$br`r`n" 
            $StringBuilder.AppendLine($newLines) | Out-Null
            $StringBuilder.AppendLine() | Out-Null
        }
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
        $sb = [System.Text.StringBuilder]::new()

        $sb.AppendLine("# $($singleFileMetadata.Name)") | Out-Null
       
        $sb.AppendLine() | Out-Null
        $sb.AppendLine("Target Scope: $($singleFileMetadata.TargetScope)") | Out-Null
        $sb.AppendLine() | Out-Null

        New-MarkdownSection -StringBuilder $sb -Header 'Synopsis' -lines ($singleFileMetadata.Metadata | Where-Object Name -EQ 'Synopsis' | Select-Object -ExpandProperty Value)
        New-MarkdownSection -StringBuilder $sb -Header 'Description' -lines ($singleFileMetadata.Metadata | Where-Object Name -EQ 'Description' | Select-Object -ExpandProperty Value)
        New-MarkdownSection -StringBuilder $sb -Header 'Security Default' -lines ($singleFileMetadata.Metadata | Where-Object Name -EQ 'SECURITY_DEFAULTS' | Select-Object -ExpandProperty Value)

        $sb.AppendLine('## Parameters') | Out-Null
        $sb.AppendLine('| Name | Type | Required | Validation | Default value | Description |') | Out-Null
        $sb.AppendLine('| -- |  -- | -- | -- | -- | -- |') | Out-Null
        $singleFileMetadata.ParameterInfo | ForEach-Object { 
            $parameterInfo = $_ #  $parameterInfo  =  $singleFileMetadata.ParameterInfo[0]
            $validation = 'None'
            $allowedDecorator = $parameterInfo.Decorators['allowed'] ?? $null
            if ($allowedDecorator)
            {
                $validation = $allowedDecorator | Join-String -Separator '''` or  `''' -OutputPrefix '`''' -OutputSuffix '''`'
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
            

            $description = $parameterInfo.Decorators['description'] ?? $null
            if ( $null -ne $description -and $parameterInfo.Decorators.description -is [array] -and $parameterInfo.Decorators.description.Count -gt 1 )
            {
                $spacedDescription = ConvertTo-SpaceWithHtmlSpaces -lines $parameterInfo.Decorators.description
                $description = $spacedDescription | Join-String -Separator '<br>'
            }
   
            $defaultValue = $parameterInfo.DefaultValue
            if ($parameterInfo.DefaultValue -is [array] -and $parameterInfo.DefaultValue.Count -gt 1)
            {
                $defaultValue = $parameterInfo.DefaultValue | Join-String -Separator '<br>'
            }
            $required = "<input type=""checkbox""$($null -eq $parameterInfo.DefaultValue ? ' checked' : '')>"
            $sb.AppendLine("| $($parameterInfo.Name) | $($parameterInfo.Type) | $required | $validation | <pre>$defaultValue</pre> | $description |") | Out-Null
             
        }
        $sb.AppendLine('## Outputs') | Out-Null
        $sb.AppendLine('| Name | Type | Description |') | Out-Null
        $sb.AppendLine('| -- |  -- | -- |') | Out-Null
        $singleFileMetadata.outputInfo | ForEach-Object { 
            $outputInfo = $_ #  $parameterInfo  =  $singleFileMetadata.ParameterInfo[0]
            $sb.AppendLine("| $($outputInfo.Name) | $($outputInfo.Type) | $($outputInfo.Decorators['description'] ?? $null ) |") | Out-Null
 
        }

        New-MarkdownSection -StringBuilder $sb -Header 'Examples' -lines ($singleFileMetadata.Metadata | Where-Object Name -EQ 'Example' | Select-Object -ExpandProperty Value) -NoBreak
        New-MarkdownSection -StringBuilder $sb -Header 'Links' -lines ($singleFileMetadata.Metadata | Where-Object Name -EQ 'EXTERNAL_LINKS' | Select-Object -ExpandProperty Value)

        $destinationFolder = Join-Path -Path $DestinationPath -ChildPath $singleFileMetadata.Path
        if (!(Test-Path $destinationFolder))
        {
            New-Item -Path $destinationFolder -ItemType Directory
        }
        $destinationFile = Join-Path -Path $destinationFolder -ChildPath "$($singleFileMetadata.Name).md"
        $sb.ToString() | Out-File $destinationFile
    }
}