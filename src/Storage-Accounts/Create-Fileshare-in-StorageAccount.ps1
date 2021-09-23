[CmdletBinding()]
param (
    [Alias("FileshareStorageAccountResourceGroupname")]
    [Parameter(Mandatory)][string] $StorageAccountResourceGroupname,
    [Alias("FileshareStorageAccountName")]
    [Parameter(Mandatory)][string] $StorageAccountName,
    [Alias("ShareName")]
    [Parameter(Mandatory)][string] $FileshareName,
    [Parameter(Mandatory)][string] $LogAnalyticsWorkspaceResourceId
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

# Create storage fileshare
Invoke-Executable az storage share-rm create --storage-account $StorageAccountName --name $FileshareName

# Enable diagnostic settings for storage fileshare
$storageAccountId = (Invoke-Executable az storage account show --name $StorageAccountName --resource-group $StorageAccountResourceGroupName | ConvertFrom-Json).id 
Set-DiagnosticSettings -ResourceId "$storageAccountId/fileServices/default" -ResourceName $StorageAccountName -LogAnalyticsWorkspaceResourceId $LogAnalyticsWorkspaceResourceId -Logs "[{ 'category': 'StorageRead', 'enabled': true }, { 'category': 'StorageWrite', 'enabled': true }, { 'category': 'StorageDelete', 'enabled': true }]".Replace("'", '\"')  -Metrics "[ { 'category': 'AllMetrics', 'enabled': true } ]".Replace("'", '\"') 

Write-Footer -ScopedPSCmdlet $PSCmdlet