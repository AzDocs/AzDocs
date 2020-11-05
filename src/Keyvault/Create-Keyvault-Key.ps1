[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [String] $keyVaultName,

    [Parameter(Mandatory)]
    [String] $keyName
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
#endregion ===END IMPORTS===

Write-Host 'Check if key exists'
$key = az keyvault key show --vault-name $keyVaultName --name $keyName | ConvertFrom-Json

if (!$key) {
    Write-Host 'Create key'
    Invoke-Executable az keyvault key create --vault-name $keyVaultName --name $keyName
} else {
    Write-Host 'Key already exists'
}