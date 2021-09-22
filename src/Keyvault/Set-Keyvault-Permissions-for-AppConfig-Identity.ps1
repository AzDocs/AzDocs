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
Set-KeyvaultPermissions -KeyvaultName $KeyvaultName -ManagedIdentityId $identityId -KeyvaultCertificatePermissions $KeyvaultCertificatePermissions -KeyvaultKeyPermissions $KeyvaultKeyPermissions -KeyvaultSecretPermissions $KeyvaultSecretPermissions -KeyvaultStoragePermissions $KeyvaultStoragePermissions

Write-Footer -ScopedPSCmdlet $PSCmdlet