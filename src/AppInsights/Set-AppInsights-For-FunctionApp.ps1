[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $AppInsightsName,
    [Parameter(Mandatory)][string] $AppInsightsResourceGroupName,
    [Parameter(Mandatory)][string] $FunctionAppName,
    [Parameter(Mandatory)][string] $FunctionAppResourceGroupName,
    [Parameter()][string] $AppServiceSlotName,
    [Parameter()][bool] $ApplyToAllSlots = $false
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

Write-Warning 'This script is deprecated. Please use the Create-Application-Insights-Extension-for-FunctionApps-codeless.ps1 instead.'
Write-Host '##vso[task.complete result=SucceededWithIssues;]'

# Create Web App
& "$PSScriptRoot\Create-Application-Insights-Extension-for-FunctionApps-codeless.ps1" @PSBoundParameters

Write-Footer -ScopedPSCmdlet $PSCmdlet
