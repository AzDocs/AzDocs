[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $KeyvaultName,
    [Parameter(Mandatory)][string] $KeyvaultResourceGroupName,
    [Parameter()][string] $KeyvaultCertificatePermissions = '',
    [Parameter()][string] $KeyvaultKeyPermissions = '',
    [Parameter()][string] $KeyvaultSecretPermissions = '',
    [Parameter()][string] $KeyvaultStoragePermissions = ''
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

$identityId = (Invoke-Executable az account show | ConvertFrom-Json).user.name

if (!$identityId)
{
    throw 'Identity not found'
}

Write-Host "Identity ID: $identityId"
Set-KeyvaultPermissions -KeyvaultName $KeyvaultName -ManagedIdentityId $identityId -KeyvaultCertificatePermissions $KeyvaultCertificatePermissions -KeyvaultKeyPermissions $KeyvaultKeyPermissions -KeyvaultSecretPermissions $KeyvaultSecretPermissions -KeyvaultStoragePermissions $KeyvaultStoragePermissions

Write-Footer -ScopedPSCmdlet $PSCmdlet