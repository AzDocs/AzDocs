[CmdletBinding()]
param (
    [Alias("BlobStorageAccountName")]
    [Parameter(Mandatory)][string] $StorageAccountName,
    [Alias("ContainerName", "BlobStorageContainerName")]
    [Parameter(Mandatory)][string] $BlobContainerName,
    [Parameter(Mandatory)][string] $StorageAccountResourceGroupName,
    [Parameter(Mandatory)][string] $LogAnalyticsWorkspaceResourceId
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

# Create storage container
Invoke-Executable az storage container create --account-name $StorageAccountName --name $BlobContainerName --auth-mode login

# Enable diagnostic settings for storage blobcontainer
$storageAccountId = (Invoke-Executable az storage account show --name $StorageAccountName --resource-group $StorageAccountResourceGroupName | ConvertFrom-Json).id
Set-DiagnosticSettings -ResourceId "$storageAccountId/blobServices/default" -ResourceName $StorageAccountName -LogAnalyticsWorkspaceResourceId $LogAnalyticsWorkspaceResourceId -Logs "[{ 'category': 'StorageRead', 'enabled': true }, { 'category': 'StorageWrite', 'enabled': true }, { 'category': 'StorageDelete', 'enabled': true }]".Replace("'", '\"')  -Metrics "[ { 'category': 'AllMetrics', 'enabled': true } ]".Replace("'", '\"') 

Write-Footer -ScopedPSCmdlet $PSCmdlet