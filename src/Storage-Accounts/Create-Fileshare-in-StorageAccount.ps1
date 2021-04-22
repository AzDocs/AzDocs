[CmdletBinding()]
param (
    [Alias("FileshareStorageAccountResourceGroupname")]
    [Parameter(Mandatory)][string] $StorageAccountResourceGroupname,
    [Alias("FileshareStorageAccountName")]
    [Parameter(Mandatory)][string] $StorageAccountName,
    [Alias("ShareName")]
    [Parameter(Mandatory)][string] $FileshareName
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

Invoke-Executable az storage share-rm create --storage-account $StorageAccountName --name $FileshareName

Write-Footer -ScopedPSCmdlet $PSCmdlet