[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [String] $appServiceName,

    [Parameter(Mandatory)]
    [String] $appServiceResourceGroupName,

    [Parameter(Mandatory)]
    [String] $keyvaultCertificatePermissions,

    [Parameter(Mandatory)]
    [String] $keyvaultKeyPermissions,

    [Parameter(Mandatory)]
    [String] $keyvaultSecretPermissions,

    [Parameter(Mandatory)]
    [String] $keyvaultStoragePermissions,

    [Parameter(Mandatory)]
    [String] $keyvaultName,

    [Parameter()]
    [String] $AppServiceSlotName
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Write-HeaderFooter.ps1"
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
. "$PSScriptRoot\..\common\Get-ManagedIdentity.ps1"
#endregion ===END IMPORTS===

Write-Header

$identityId = Get-ManagedIdentity -Name $appServiceName -ResourceGroup $appServiceResourceGroupName -Slot $AppServiceSlotName

$kvcp = $keyvaultCertificatePermissions -split ' '
$kvkp = $keyvaultKeyPermissions -split ' '
$kvsp = $keyvaultSecretPermissions -split ' '
$kvstp = $keyvaultStoragePermissions -split ' '

Invoke-Executable az keyvault set-policy --certificate-permissions @kvcp --key-permissions @kvkp --secret-permissions @kvsp --storage-permissions @kvstp --object-id $identityId --name $keyvaultName

Write-Footer