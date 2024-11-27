[CmdletBinding()]
param (
    [Alias('ActionGroupName')]
    [Parameter(Mandatory)][string] $MonitorAlertActionGroupName,
    [Alias('ApplicationResourceGroupName')]
    [Parameter(Mandatory)][string] $MonitorAlertActionResourceGroupName,
    [Alias('Action')]
    [Parameter(Mandatory)][string[]] $AlertAction
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

$actionGroup = (Invoke-Executable az monitor action-group create --name $MonitorAlertActionGroupName --resource-group $MonitorAlertActionResourceGroupName --action @AlertAction) | ConvertFrom-Json
Write-Host ($actionGroup | ConvertTo-Json)
Write-Output $actionGroup.id

Write-Footer -ScopedPSCmdlet $PSCmdlet