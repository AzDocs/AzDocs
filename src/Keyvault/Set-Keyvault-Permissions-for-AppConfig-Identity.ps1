[CmdletBinding()]
param (
    [Parameter()]
    [String] $appConfigName,

    [Parameter()]
    [String] $appConfigResourceGroupName,

    [Parameter()]
    [String] $keyvaultCertificatePermissions,

    [Parameter()]
    [String] $keyvaultKeyPermissions,

    [Parameter()]
    [String] $keyvaultSecretPermissions,

    [Parameter()]
    [String] $keyvaultStoragePermissions,

    [Parameter()]
    [String] $keyvaultName
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
#endregion ===END IMPORTS===

$identityId = (Invoke-Executable az appconfig identity show --resource-group $appConfigResourceGroupName --name $appConfigName | ConvertFrom-Json).principalId
if (-not $identityId) {
    throw "Could not find identity for $appConfigName"
}
Write-Host "Identity ID: $identityId"

$kvcp = $keyvaultCertificatePermissions -split ' '
$kvkp = $keyvaultKeyPermissions -split ' '
$kvsp =   $keyvaultSecretPermissions -split ' '
$kvstp  = $keyvaultStoragePermissions -split ' '

Invoke-Executable az keyvault set-policy --certificate-permissions @kvcp --key-permissions @kvkp --secret-permissions @kvsp --storage-permissions @kvstp --object-id $identityId --name $keyvaultName