[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $ResourceGroupName,
    [Alias("StorageAccountName")]
    [Parameter(Mandatory)][string] $BlobStorageAccountName,
    [Parameter(Mandatory)][string] $QueueName
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

$connectionString = (Invoke-Executable az storage account show-connection-string -n $BlobStorageAccountName -g $ResourceGroupName --query connectionString -o tsv)
$env:AZURE_STORAGE_CONNECTION_STRING = $connectionString

Invoke-Executable az storage queue create --name $StorageAccountName

Write-Footer -ScopedPSCmdlet $PSCmdlet