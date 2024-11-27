<#
.SYNOPSIS
    Short description
.DESCRIPTION
    Long description
.EXAMPLE
    PS C:\> . Azure.PlatformProvisioning\Tools\Convert-WriteHeaderToString.ps1 ; Convert-WriteHeaderToString -inputLine @'
>  ParameterSetName : DeploymentSlot
>  AppServicePlanName : ASP-dev-Linux
>  AppServicePlanResourceGroupName : ASP-dev
>  FunctionAppResourceGroupName : app-dev
'@
    Converts the output of write-header to arguments like you would be able to call the script itself
.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    General notes
#>
function Convert-WriteHeaderToString
{
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $inputLine
    )

    $lines = $inputLine.Split("`n", [StringSplitOptions]::RemoveEmptyEntries)
    $lines | ForEach-Object {
        $line = $_.TrimStart('>').Trim()
        if (!$line.StartsWith('ParameterSetName'))
        {
            $sep = $line.IndexOf(':')
            $parameter = $line.Substring(0, $sep).Trim()
            $value = $line.Substring($sep + 1).Trim()
            $newValue = switch ($value)
            {
                'True' { '$true' }
                'False' { '$false' }
                Default { "'$value'" }
            }
            "-$parameter $newValue"
        }
    } | Join-String -Separator ' '
}