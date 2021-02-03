[CmdletBinding()]
param (
    [Alias("ActionGroupName")]
    [Parameter(Mandatory)][string] $MonitorAlertActionGroupName,
    [Alias("ApplicationResourceGroupName")]
    [Parameter(Mandatory)][string] $MonitorAlertActionResourceGroupName,
    [Alias("Action")]
    [Parameter(Mandatory)][string[]] $AlertAction
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Write-HeaderFooter.ps1"
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
#endregion ===END IMPORTS===

Write-Header

Invoke-Executable az monitor action-group create --name $MonitorAlertActionGroupName --resource-group $MonitorAlertActionResourceGroupName --action @AlertAction

Write-Footer