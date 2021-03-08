[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $KeyVaultName,
    [Parameter(Mandatory)][string] $SecretName,
    [Parameter()][string] $SecretDescription,
    [Parameter()][string] $SecretExpires,
    [Parameter()][string] $SecretNotBefore,
    [Alias("FilePath")]
    [Parameter(Mandatory, ParameterSetName = "File")][string] $SecretFilePath,
    [Alias("FileEncoding")]
    [Parameter(Mandatory, ParameterSetName = "File")][ValidateSet("ascii", "base64", "hex", "utf-16be", "utf-16le", "utf-8")][string] $SecretFileFileEncoding,
    [Alias("Value")]
    [Parameter(Mandatory, ParameterSetName = "Value")][string] $SecretValue
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

$scriptArguments = "--vault-name", "$KeyVaultName", "--name", "$SecretName"

switch ($PSCmdlet.ParameterSetName) {
    "File" {
        $scriptArguments += "--encoding", "$SecretFileFileEncoding", "--file", "$SecretFilePath"
    }
    "Value" {
        $scriptArguments += "--value", "$SecretValue"
    }
}

if ($SecretDescription) {
    $scriptArguments += "--description", "$SecretDescription"
}

if ($SecretExpires) {
    $scriptArguments += "--expires", "$SecretExpires"
}

if ($SecretNotBefore) {
    $scriptArguments += "--not-before", "$SecretNotBefore"
}

Invoke-Executable az keyvault secret set @scriptArguments

Write-Footer -ScopedPSCmdlet $PSCmdlet