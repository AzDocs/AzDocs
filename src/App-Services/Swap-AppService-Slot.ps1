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

Write-Warning 'This script is deprecated. Please use the standard task Azure App Service Manage instead.'
Write-Host "##vso[task.complete result=SucceededWithIssues;]"

Invoke-Executable az webapp deployment slot swap --resource-group $AppServiceResourceGroupName --name $AppServiceName --slot $AppServiceSourceSlot --target-slot $AppServiceTargetSlot

Write-Footer -ScopedPSCmdlet $PSCmdlet