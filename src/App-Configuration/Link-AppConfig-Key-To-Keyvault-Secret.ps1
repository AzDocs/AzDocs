[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $AppConfigName,
    [Parameter(Mandatory)][string] $AppConfigKeyName,
    [Parameter(Mandatory)][string] $KeyVaultName,
    [Parameter(Mandatory)][string] $KeyVaultSecretName,
    [Parameter(Mandatory)][string] $Label
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

$keyVaultSecretId = (Invoke-Executable az keyvault secret list --vault-name $KeyVaultName --query "[?name=='$($KeyVaultSecretName)']" | ConvertFrom-Json).id

Invoke-Executable az appconfig kv set-keyvault --name $AppConfigName --key $AppConfigKeyName --label $Label --secret-identifier $keyVaultSecretId --yes

Write-Footer -ScopedPSCmdlet $PSCmdlet