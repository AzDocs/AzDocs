[CmdletBinding()]
param (
    [Alias('BlobStorageAccountName')]
    [Parameter(Mandatory)][string] $StorageAccountName,
    [Alias('ContainerName', 'BlobStorageContainerName')]
    [Parameter(Mandatory)][string] $BlobContainerName,
    [Parameter(Mandatory)][string] $StorageAccountResourceGroupName,
    # Diagnostic settings
    [Parameter(Mandatory)][string] $LogAnalyticsWorkspaceResourceId,
    [Parameter()][System.Object[]] $DiagnosticSettingsLogs,
    [Parameter()][System.Object[]] $DiagnosticSettingsMetrics,
    
    # Disable diagnostic settings
    [Parameter()][switch] $DiagnosticSettingsDisabled
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

# Create storage container
Invoke-Executable az storage container create --account-name $StorageAccountName --name $BlobContainerName --auth-mode login

# Enable diagnostic settings for storage blobcontainer
$storageAccountId = (Invoke-Executable az storage account show --name $StorageAccountName --resource-group $StorageAccountResourceGroupName | ConvertFrom-Json).id
if ($DiagnosticSettingsDisabled)
{
    Remove-DiagnosticSetting -ResourceId "$storageAccountId/blobServices/default" -LogAnalyticsWorkspaceResourceId $LogAnalyticsWorkspaceResourceId -ResourceName $StorageAccountName
}
else
{
    Set-DiagnosticSettings -ResourceId "$storageAccountId/blobServices/default" -ResourceName $StorageAccountName -LogAnalyticsWorkspaceResourceId $LogAnalyticsWorkspaceResourceId -DiagnosticSettingsLogs:$DiagnosticSettingsLogs -DiagnosticSettingsMetrics:$DiagnosticSettingsMetrics 
}

Write-Footer -ScopedPSCmdlet $PSCmdlet