[CmdletBinding()]
param (
    [Alias('FileshareStorageAccountResourceGroupname')]
    [Parameter(Mandatory)][string] $StorageAccountResourceGroupname,
    [Alias('FileshareStorageAccountName')]
    [Parameter(Mandatory)][string] $StorageAccountName,
    [Alias('ShareName')]
    [Parameter(Mandatory)][string] $FileshareName,
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

# Create storage fileshare
Invoke-Executable az storage share-rm create --storage-account $StorageAccountName --name $FileshareName

# Enable diagnostic settings for storage fileshare
$storageAccountId = (Invoke-Executable az storage account show --name $StorageAccountName --resource-group $StorageAccountResourceGroupName | ConvertFrom-Json).id
if ($DiagnosticSettingsDisabled)
{
    Remove-DiagnosticSetting -ResourceId "$storageAccountId/fileServices/default" -LogAnalyticsWorkspaceResourceId $LogAnalyticsWorkspaceResourceId -ResourceName $StorageAccountName
}
else
{
    Set-DiagnosticSettings -ResourceId "$storageAccountId/fileServices/default" -ResourceName $StorageAccountName -LogAnalyticsWorkspaceResourceId $LogAnalyticsWorkspaceResourceId -DiagnosticSettingsLogs:$DiagnosticSettingsLogs -DiagnosticSettingsMetrics:$DiagnosticSettingsMetrics 
}

Write-Footer -ScopedPSCmdlet $PSCmdlet