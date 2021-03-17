[CmdletBinding()]
param (
    [Alias("StorageAccountName")]
    [Parameter(Mandatory)][string] $BlobStorageAccountName,
    [Alias("ContainerName")]
    [Parameter(Mandatory)][string] $BlobStorageContainerName
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

Invoke-Executable az storage container create --account-name $BlobStorageAccountName --name $BlobStorageContainerName --auth-mode login

Write-Footer -ScopedPSCmdlet $PSCmdlet