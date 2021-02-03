[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $KeyvaultName,
    [Parameter(Mandatory)][string] $KeyvaultResourceGroupName,
    [Parameter()][string] $KeyvaultCertificatePermissions = "",
    [Parameter()][string] $KeyvaultKeyPermissions = "",
    [Parameter()][string] $KeyvaultSecretPermissions = "",
    [Parameter()][string] $KeyvaultStoragePermissions = ""
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Write-HeaderFooter.ps1"
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
#endregion ===END IMPORTS===

Write-Header

$identityId = (Invoke-Executable az account show | ConvertFrom-Json).user.name

$kvcp = $KeyvaultCertificatePermissions -split ' '
$kvkp = $KeyvaultKeyPermissions -split ' '
$kvsp = $KeyvaultSecretPermissions -split ' '
$kvstp = $KeyvaultStoragePermissions -split ' '

if (!$identityId) {
    throw "Identity not found"
}
Write-Host "Identity ID: $identityId"
Invoke-Executable az keyvault set-policy --name $KeyvaultName --certificate-permissions @kvcp --key-permissions @kvkp --secret-permissions @kvsp --storage-permissions @kvstp --spn $identityId --resource-group $KeyvaultResourceGroupName | Out-Null

Write-Footer