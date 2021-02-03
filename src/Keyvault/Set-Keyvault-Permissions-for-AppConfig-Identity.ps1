[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $AppConfigName,
    [Parameter(Mandatory)][string] $AppConfigResourceGroupName,
    [Parameter(Mandatory)][string] $KeyvaultCertificatePermissions,
    [Parameter(Mandatory)][string] $KeyvaultKeyPermissions,
    [Parameter(Mandatory)][string] $KeyvaultSecretPermissions,
    [Parameter(Mandatory)][string] $KeyvaultStoragePermissions,
    [Parameter(Mandatory)][string] $KeyvaultName
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Write-HeaderFooter.ps1"
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
. "$PSScriptRoot\..\common\Get-ManagedIdentity.ps1"
#endregion ===END IMPORTS===

Write-Header

$identityId = Get-ManagedIdentity -AppConfig -ResourceName $AppConfigName -ResourceGroupName $AppConfigResourceGroupName

$kvcp = $KeyvaultCertificatePermissions -split ' '
$kvkp = $KeyvaultKeyPermissions -split ' '
$kvsp = $KeyvaultSecretPermissions -split ' '
$kvstp = $KeyvaultStoragePermissions -split ' '

Invoke-Executable az keyvault set-policy --certificate-permissions @kvcp --key-permissions @kvkp --secret-permissions @kvsp --storage-permissions @kvstp --object-id $identityId --name $KeyvaultName

Write-Footer