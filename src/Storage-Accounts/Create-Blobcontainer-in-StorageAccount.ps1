[CmdletBinding()]
param (
    [Alias("BlobStorageAccountName")]
    [Parameter(Mandatory)][string] $StorageAccountName,
    [Alias("ContainerName", "BlobStorageContainerName")]
    [Parameter(Mandatory)][string] $BlobContainerName
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

Invoke-Executable az storage container create --account-name $StorageAccountName --name $BlobContainerName --auth-mode login

Write-Footer -ScopedPSCmdlet $PSCmdlet