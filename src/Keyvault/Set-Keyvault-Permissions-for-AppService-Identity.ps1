[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $AppServiceName,
    [Parameter(Mandatory)][string] $AppServiceResourceGroupName,
    [Parameter()][string] $KeyvaultCertificatePermissions,
    [Parameter()][string] $KeyvaultKeyPermissions,
    [Parameter()][string] $KeyvaultSecretPermissions,
    [Parameter()][string] $KeyvaultStoragePermissions,
    [Parameter(Mandatory)][string] $KeyvaultName,
    [Parameter()][string] $AppServiceSlotName
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Write-HeaderFooter.ps1"
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
. "$PSScriptRoot\..\common\Get-ManagedIdentity.ps1"
#endregion ===END IMPORTS===

Write-Header

$identityId = Get-ManagedIdentity -AppService -ResourceName $AppServiceName -ResourceGroupName $AppServiceResourceGroupName -AppServiceSlotName $AppServiceSlotName

$kvcp = $KeyvaultCertificatePermissions -split ' '
$kvkp = $KeyvaultKeyPermissions -split ' '
$kvsp = $KeyvaultSecretPermissions -split ' '
$kvstp = $KeyvaultStoragePermissions -split ' '

Invoke-Executable az keyvault set-policy --certificate-permissions @kvcp --key-permissions @kvkp --secret-permissions @kvsp --storage-permissions @kvstp --object-id $identityId --name $KeyvaultName

Write-Footer