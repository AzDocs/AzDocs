[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $KeyVaultName,
    [Parameter(Mandatory)][string] $SecretName,
    [Parameter()][string] $SecretDescription,
    [Parameter()][int][ValidateRange(1, 397)]  $SecretExpiresInDays = 397,
    [Parameter()][int][ValidateRange(0, [int]::MaxValue)] $SecretNotBeforeInDays = 0,
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

Write-Host 'Check if secret exists in deleted state'
if ($(Invoke-Executable -AllowToFail az keyvault secret show-deleted --vault-name $KeyVaultName --name $SecretName | ConvertFrom-Json))
{
    throw "Exception: Secret already exists in deleted state with name: $SecretName"
}

$scriptArguments = "--vault-name", "$KeyVaultName", "--name", "$SecretName"
switch ($PSCmdlet.ParameterSetName)
{
    "File"
    {
        $scriptArguments += "--encoding", "$SecretFileFileEncoding", "--file", "$SecretFilePath"
    }
    "Value"
    {
        $scriptArguments += "--value", "$SecretValue"
    }
}

if ($SecretDescription)
{
    $scriptArguments += "--description", "$SecretDescription"
}

if ($SecretExpiresInDays)
{
    # Calculate the date based upon the days
    $expirationDate = Get-UtcDateStringFromNow -Days $SecretExpiresInDays
    Write-Host "Expiration date: $expirationDate"
    $scriptArguments += "--expires", "$expirationDate"
}

if ($SecretNotBeforeInDays)
{
    # Calculate the date based upon the days
    $beforeDate = Get-UtcDateStringFromNow -Days $SecretNotBeforeInDays
    Write-Host "Not before date: $beforeDate"
    $scriptArguments += "--not-before", "$beforeDate"
}

Invoke-Executable az keyvault secret set @scriptArguments

Write-Footer -ScopedPSCmdlet $PSCmdlet