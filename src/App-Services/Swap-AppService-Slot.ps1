[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $AppServiceResourceGroupName,
    [Parameter(Mandatory)][string] $AppServiceName,
    [Alias("SourcesSlot")]
    [Parameter()][string] $AppServiceSourceSlot = 'staging',
    [Alias("TargetSlot")]
    [Parameter()][string] $AppServiceTargetSlot = 'production'
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Write-HeaderFooter.ps1"
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
#endregion ===END IMPORTS===

Write-Header

Invoke-Executable az webapp deployment slot swap --resource-group $AppServiceResourceGroupName --name $AppServiceName --slot $AppServiceSourceSlot --target-slot $AppServiceTargetSlot

Write-Footer