<#
.SYNOPSIS
    Execute a command and check the exit code.
.DESCRIPTION
    Execute a command and check the exit code.
    After the executable has successfullu run the console colors are reset.
    This function will fix the fact that powershell will keep running the script if any executable goes wrong. This function will output the error and break the script.
.EXAMPLE
    PS C:\> Invoke-Executable az account show
    Executes the 'az' executable with the argument 'account' and 'show'
#>
function Invoke-Executable
{
    param(
        # Path to the executable
        [Parameter(Mandatory)]
        [string]
        $LiteralPath,

        # Arguments that are passed to the executable
        [Parameter(ValueFromRemainingArguments)]
        $PassThruArgs,

        # Parameter help description
        [Parameter()]
        [switch]
        $AllowToFail
    )

     #region ===BEGIN IMPORTS===
     . "$PSScriptRoot\Write-HeaderFooter.ps1"
     #endregion ===END IMPORTS===

    if ($LiteralPath -eq 'az')
    {
        if ($env:System_Debug -and $env:System_Debug -eq $true)
        {
            $PassThruArgs += "--debug"
        }
    }
    Write-Header -OverrideHeaderText "$LiteralPath $PassThruArgs" -HideParameters
    & $LiteralPath $PassThruArgs
    if (!$AllowToFail -and !$?)
    {
        Write-Error "Arguments: $LiteralPath $PassThruArgs"
        Get-Error
        throw $Error
    }
    [Console]::ResetColor()
    Write-Footer
}
