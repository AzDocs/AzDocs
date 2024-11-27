[CmdletBinding()]
param (
    [Parameter(Mandatory)][String] $KeyVaultName,
    [Parameter(Mandatory)][String] $KeyName,
    [Parameter()][int][ValidateRange(1, 397)] $KeyExpiresInDays = 397,
    [Parameter()][int][ValidateRange(0, [int]::MaxValue)] $KeyNotBeforeInDays = 0
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

Write-Host 'Check if key exists'

if ($(Invoke-Executable -AllowToFail az keyvault key show-deleted --vault-name $KeyVaultName --name $KeyName | ConvertFrom-Json))
{
    throw "Exception: Key already exists in deleted state with name: $KeyName"
}

$optionalParameters = @()
if ($KeyExpiresInDays)
{
    # Calculate the date based upon the days
    $expirationDate = Get-UtcDateStringFromNow -Days $KeyExpiresInDays
    Write-Host "Expiration date: $expirationDate"
    $optionalParameters += '--expires', "$expirationDate"
}

if ($KeyNotBeforeInDays)
{
    # Calculate the date based upon the days
    $beforeDate = Get-UtcDateStringFromNow -Days $SecretNotBeforeInDays
    Write-Host "Not Before Date: $beforeDate"
    $optionalParameters += '--not-before', "$beforeDate"
}

Invoke-Executable az keyvault key create --vault-name $KeyVaultName --name $KeyName @optionalParameters

Write-Footer -ScopedPSCmdlet $PSCmdlet