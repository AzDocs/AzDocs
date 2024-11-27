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
        [Parameter(Mandatory)][string] $ExecutableLiteralPath,
        [Parameter(ValueFromRemainingArguments)] $ExecutableArguments,
        [Parameter()][switch] $AllowToFail,
        [Parameter()][switch] $PreventDebugging,
        [Parameter()][switch] $WhatIf 
    )

    # Saving the LASTEXITCODE for when we enable -AllowToFail to reset the LASTEXITCODE later
    $lastKnownExitCode = $global:LASTEXITCODE

    # Make sure to append --debug when using Azure CLI with $env:SYSTEM_DEBUG set to $true
    if (!$PreventDebugging -and $ExecutableLiteralPath -eq 'az')
    {
        if ($env:SYSTEM_DEBUG -and $env:SYSTEM_DEBUG -eq $true)
        {
            $ExecutableArguments += '--debug'
        }
    }
    if ($WhatIf)
    {
        $ExecutableArguments += ' [WHATIF]'
    }

    Write-Header -ScopedPSCmdlet $PSCmdlet -OverrideMessage "$ExecutableLiteralPath $ExecutableArguments" -OmitOutputParameters

    # Execute the original executable with the original parameters in child scope
    if (!$WhatIf)
    {
        & $ExecutableLiteralPath @ExecutableArguments
    }
    # If an error was thrown from the last operation and -AllowToFail is not passed --> Break the pipeline. 
    if (!$AllowToFail -and !$?)
    {
        Write-Host "Returncode: $LASTEXITCODE"
        Write-Error "Arguments: $ExecutableLiteralPath $ExecutableArguments"
        Get-Error
        throw $Error
    }

    if ($env:SYSTEM_DEBUG -and $env:SYSTEM_DEBUG -eq $true)
    {
        Write-Host "Returncode: $LASTEXITCODE"
    }

    # Restore original $LASTEXITCODE when -AllowToFail is passed
    if ($AllowToFail)
    {
        Write-ColorHost -Message '[AllowToFail previous command]' -Color 'Blue'
        if ($env:SYSTEM_DEBUG -and $env:SYSTEM_DEBUG -eq $true)
        {
            Write-Host "Overriding LASTEXITCODE to $lastKnownExitCode due to -AllowToFail."
        }
        $global:LASTEXITCODE = $lastKnownExitCode
    }

    # Make sure to reset color (bug in AzDo pipelines which keeps it on orange/red after a catched error)
    [Console]::ResetColor()

    Write-Footer -ScopedPSCmdlet $PSCmdlet
}
