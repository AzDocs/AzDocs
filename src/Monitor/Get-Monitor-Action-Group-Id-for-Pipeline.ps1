[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $MonitorActionGroupName,
    [Parameter(Mandatory)][string] $MonitorActionResourceGroupName,
    [Parameter()][string] $OutputPipelineVariableName = "MonitorActionGroupId"
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

$monitorActionGroup = Invoke-Executable az monitor action-group show --name $MonitorActionGroupName --resource-group $MonitorActionResourceGroupName | ConvertFrom-Json
Write-Host "Monitor action group id: $($monitorActionGroup.id)"
Write-Host "##vso[task.setvariable variable=$($OutputPipelineVariableName);isOutput=true]$($monitorActionGroup.Id)"

Write-Footer -ScopedPSCmdlet $PSCmdlet