[CmdletBinding()]
param (
    [Parameter(Mandatory)][String] $KeyVaultName,
    [Parameter(Mandatory)][String] $KeyName
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

Write-Host 'Check if key exists'

if (!$(Invoke-Executable -AllowToFail az keyvault key show --vault-name $KeyVaultName --name $KeyName | ConvertFrom-Json))
{
    # Check if there are no keys in deleted state with the same name
    if (!$(Invoke-Executable -AllowToFail az keyvault key show-deleted --vault-name $KeyVaultName --name $KeyName | ConvertFrom-Json))
    {
        Write-Host 'Create key'
        Invoke-Executable az keyvault key create --vault-name $KeyVaultName --name $KeyName
    }
    else
    {
        throw "Exception: Key already exists in deleted state with name: $KeyName"
    }
}
else
{
    Write-Host 'Key already exists'
}

Write-Footer -ScopedPSCmdlet $PSCmdlet