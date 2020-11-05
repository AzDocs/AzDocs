[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [String] $keyVaultName,

    [Parameter(Mandatory)]
    [String] $secretName,

    [Parameter()]
    [String] $secretDescription,

    [Parameter()]
    [String] $secretExpires,

    [Parameter()]
    [String] $secretNotBefore,

    [Parameter(Mandatory, ParameterSetName = "File")]
    [String] $filePath,

    [Parameter(Mandatory, ParameterSetName = "File")]
    [ValidateSet("ascii", "base64", "hex", "utf-16be", "utf-16le", "utf-8")]
    [String] $fileEncoding,

    [Parameter(Mandatory, ParameterSetName = "Value")]
    [String] $value
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
#endregion ===END IMPORTS===

$scriptArguments = "--vault-name","$keyVaultName", "--name","$secretName"

switch ($PSCmdlet.ParameterSetName) {
    "File" {
        $scriptArguments += "--encoding","$fileEncoding", "--file","$filePath"
    }
    "Value" {
        $scriptArguments += "--value","$value"
    }
}

if ($secretDescription) {
    $scriptArguments += "--description","$secretDescription"
}

if ($secretExpires) {
    $scriptArguments += "--expires","$secretExpires"
}

if ($secretNotBefore) {
    $scriptArguments += "--not-before","$secretNotBefore"
}

if ($env:System_Debug -and $env:System_Debug -eq $true)
{
    $scriptArguments += "--debug"
}

write-host $scriptArguments

Invoke-Executable az keyvault secret set @scriptArguments