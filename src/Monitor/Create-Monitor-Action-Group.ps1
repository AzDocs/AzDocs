[CmdletBinding()]
param (
    [Parameter()]
    [string] $actionGroupName,

    [Parameter()]
    [string] $applicationResourceGroupName,

    [Parameter()]
    [string[]] $action
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Write-HeaderFooter.ps1"
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
#endregion ===END IMPORTS===

Write-Header

Invoke-Executable az monitor action-group create --name $actionGroupName --resource-group $applicationResourceGroupName --action @action

Write-Footer