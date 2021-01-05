[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [String] $keyvaultName,

    [Parameter(Mandatory)]
    [String] $keyvaultResourceGroupName,

    [Parameter()]
    [String] $keyvaultCertificatePermissions = "",

    [Parameter()]
    [String] $keyvaultKeyPermissions = "",

    [Parameter()]
    [String] $keyvaultSecretPermissions = "",

    [Parameter()]
    [String] $keyvaultStoragePermissions = ""
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Write-HeaderFooter.ps1"
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
#endregion ===END IMPORTS===

Write-Header

$identityId = (Invoke-Executable az account show | ConvertFrom-Json).user.name

$kvcp = $keyvaultCertificatePermissions -split ' '
$kvkp = $keyvaultKeyPermissions -split ' '
$kvsp = $keyvaultSecretPermissions -split ' '
$kvstp = $keyvaultStoragePermissions -split ' '

if (!$identityId) {
    throw "Identity not found"
}
Write-Host "Identity ID: $identityId"
Invoke-Executable az keyvault set-policy --name $keyvaultName --certificate-permissions @kvcp --key-permissions @kvkp --secret-permissions @kvsp --storage-permissions @kvstp --spn $identityId --resource-group $keyvaultResourceGroupName | Out-Null

Write-Footer