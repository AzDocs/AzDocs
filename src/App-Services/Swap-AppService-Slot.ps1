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
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

Invoke-Executable az webapp deployment slot swap --resource-group $AppServiceResourceGroupName --name $AppServiceName --slot $AppServiceSourceSlot --target-slot $AppServiceTargetSlot

Write-Footer -ScopedPSCmdlet $PSCmdlet