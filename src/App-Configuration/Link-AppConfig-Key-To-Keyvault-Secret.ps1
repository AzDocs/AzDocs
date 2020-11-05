[CmdletBinding()]
param (
    [Parameter()]
    [String] $appConfigName,

    [Parameter()]
    [String] $appConfigKeyName,

    [Parameter()]
    [String] $keyVaultName,

    [Parameter()]
    [String] $keyVaultSecretName,

    [Parameter()]
    [String] $label
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
#endregion ===END IMPORTS===

$keyVaultSecretId = (Invoke-Executable az keyvault secret list --vault-name $keyVaultName --query "[?name=='$($keyVaultSecretName)']" | ConvertFrom-Json).id

Invoke-Executable az appconfig kv set-keyvault --name $appConfigName --key $appConfigKeyName --label $label --secret-identifier $keyVaultSecretId --yes
