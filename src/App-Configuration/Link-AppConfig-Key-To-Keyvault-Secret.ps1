[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $AppConfigName,
    [Parameter(Mandatory)][string] $AppConfigKeyName,
    [Parameter(Mandatory)][string] $KeyVaultName,
    [Parameter(Mandatory)][string] $KeyVaultSecretName,
    [Parameter(Mandatory)][string] $Label
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Write-HeaderFooter.ps1"
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
#endregion ===END IMPORTS===
Write-Header

$keyVaultSecretId = (Invoke-Executable az keyvault secret list --vault-name $KeyVaultName --query "[?name=='$($KeyVaultSecretName)']" | ConvertFrom-Json).id

Invoke-Executable az appconfig kv set-keyvault --name $AppConfigName --key $AppConfigKeyName --label $Label --secret-identifier $keyVaultSecretId --yes

Write-Footer