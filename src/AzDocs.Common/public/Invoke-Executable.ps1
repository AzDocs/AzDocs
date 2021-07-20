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
        [Parameter()][switch] $AllowToFail
    )

    # Saving the LASTEXITCODE for when we enable -AllowToFail to reset the LASTEXITCODE later
    $lastKnownExitCode = $global:LASTEXITCODE

    # Make sure to append --debug when using Azure CLI with $env:System_Debug set to $true
    if ($ExecutableLiteralPath -eq 'az')
    {
        if ($env:System_Debug -and $env:System_Debug -eq $true)
        {
            $ExecutableArguments += "--debug"
        }
    }

    Write-Header -ScopedPSCmdlet $PSCmdlet -OverrideMessage "$ExecutableLiteralPath $ExecutableArguments" -OmitOutputParameters

    # Execute the original executable with the original parameters
    & $ExecutableLiteralPath $ExecutableArguments
    
    if($env:System_Debug)
    {
        Write-Host "Returncode: $LASTEXITCODE"
    }

    # If an error was thrown and -AllowToFail is not passed --> Break the pipeline.
    if (!$AllowToFail -and !$?)
    {
        Write-Error "Arguments: $ExecutableLiteralPath $ExecutableArguments"
        Get-Error
        throw $Error
    }

    # Restore original $LASTEXITCODE when -AllowToFail is passed
    if ($AllowToFail)
    {
        if($env:System_Debug)
        {
            Write-Host "Overriding LASTEXITCODE to $lastKnownExitCode due to -AllowToFail."
        }
        $global:LASTEXITCODE = $lastKnownExitCode
    }

    # Make sure to reset color (bug in AzDo pipelines which keeps it on orange/red after a catched error)
    [Console]::ResetColor()

    Write-Footer -ScopedPSCmdlet $PSCmdlet
}
