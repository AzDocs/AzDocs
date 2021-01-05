[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [String] $keyVaultName,

    [Parameter(Mandatory)]
    [String] $keyName
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Write-HeaderFooter.ps1"
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
#endregion ===END IMPORTS===

Write-Header

Write-Host 'Check if key exists'
$key = Invoke-Executable az keyvault key show --vault-name $keyVaultName --name $keyName | ConvertFrom-Json

if (!$key) {
    Write-Host 'Create key'
    Invoke-Executable az keyvault key create --vault-name $keyVaultName --name $keyName
}
else {
    Write-Host 'Key already exists'
}

Write-Footer