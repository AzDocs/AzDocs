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
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

$identityId = Get-ManagedIdentity -AppConfig -ResourceName $AppConfigName -ResourceGroupName $AppConfigResourceGroupName

$kvcp = $KeyvaultCertificatePermissions -split ' '
$kvkp = $KeyvaultKeyPermissions -split ' '
$kvsp = $KeyvaultSecretPermissions -split ' '
$kvstp = $KeyvaultStoragePermissions -split ' '

Invoke-Executable az keyvault set-policy --certificate-permissions @kvcp --key-permissions @kvkp --secret-permissions @kvsp --storage-permissions @kvstp --object-id $identityId --name $KeyvaultName

Write-Footer -ScopedPSCmdlet $PSCmdlet