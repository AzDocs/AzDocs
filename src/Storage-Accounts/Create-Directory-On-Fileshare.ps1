[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $StorageAccountResourceGroupname,
    [Parameter(Mandatory)][string] $StorageAccountName,
    [Parameter(Mandatory)][string] $FileshareName,
    [Parameter(Mandatory)][string] $DirectoryPath
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

# Fetch Storage Account Key. Unfortunately no Managed Identities yet :(
$storageAccountKey = Invoke-Executable az storage account keys list --resource-group $StorageAccountResourceGroupname --account-name $StorageAccountName --query=[0].value --output tsv

# Create Directory on Fileshare
Invoke-Executable az storage directory create --name $DirectoryPath --share-name $FileshareName --account-name $StorageAccountName --account-key $storageAccountKey

Write-Footer -ScopedPSCmdlet $PSCmdlet