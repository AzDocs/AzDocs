[CmdletBinding()]
param (
    [Alias("StorageAccountName")]
    [Parameter(Mandatory)][string] $BlobStorageAccountName,
    [Alias("ContainerName")]
    [Parameter(Mandatory)][string] $BlobStorageContainerName
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Write-HeaderFooter.ps1"
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
#endregion ===END IMPORTS===

Write-Header

Invoke-Executable az storage container create --account-name $BlobStorageAccountName --name $BlobStorageContainerName --auth-mode login

Write-Footer