[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $LogAnalyticsWorkspaceResourceGroupName,
    [Parameter(Mandatory)][string] $LogAnalyticsWorkspaceName,
    [Parameter()][string] $OutputPipelineVariableName = "LogAnalyticsWorkspaceKey"
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

$logAnalyticsWorkspaceKey = (Invoke-Executable az monitor log-analytics workspace get-shared-keys --resource-group $LogAnalyticsWorkspaceResourceGroupName --workspace-name $LogAnalyticsWorkspaceName | ConvertFrom-Json -AsHashTable).primarySharedKey
Write-Host "LogAnalyticsWorkspaceKey: $logAnalyticsWorkspaceKey"
Write-Host "##vso[task.setvariable variable=$($OutputPipelineVariableName);isOutput=true]$logAnalyticsWorkspaceKey"

Write-Footer -ScopedPSCmdlet $PSCmdlet
