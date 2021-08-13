[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $LogAnalyticsWorkspaceResourceGroupName,
    [Parameter(Mandatory)][string] $LogAnalyticsWorkspaceName,
    [Parameter()][string] $OutputPipelineVariableName = "LogAnalyticsWorkspaceId"
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

$logAnalyticsWorkspaceId = (Invoke-Executable az monitor log-analytics workspace show --resource-group $LogAnalyticsWorkspaceResourceGroupName --workspace-name $LogAnalyticsWorkspaceName | ConvertFrom-Json).customerId
Write-Host "LogAnalyticsWorkspaceId: $logAnalyticsWorkspaceId"
Write-Host "##vso[task.setvariable variable=$($OutputPipelineVariableName);isOutput=true]$logAnalyticsWorkspaceId"

Write-Footer -ScopedPSCmdlet $PSCmdlet