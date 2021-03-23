[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $AppInsightsName,
    [Parameter(Mandatory)][string] $AppServiceName,
    [Parameter(Mandatory)][string] $AppServiceResourceGroupName,
    [Parameter(Mandatory)][string] $AppInsightsResourceGroupName,
    [Parameter()][string] $AppServiceSlotName,
    [Parameter()][bool] $ApplyToAllSlots = $false
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

if ($ApplyToAllSlots)
{
    $availableSlots = Invoke-Executable -AllowToFail az webapp deployment slot list --name $AppServiceName --resource-group $AppServiceResourceGroupName | ConvertFrom-Json
}

# Set the AppInsights connection information on the AppService
SetAppInsightsForAppService -AppInsightsName $AppInsightsName -AppInsightsResourceGroupName $AppInsightsResourceGroupName -AppServiceName $AppServiceName -AppServiceResourceGroupName $AppServiceResourceGroupName -AppServiceSlotName $AppServiceSlotName

# Apply to all slots if desired
foreach($availableSlot in $availableSlots)
{
    SetAppInsightsForAppService -AppInsightsName $AppInsightsName -AppInsightsResourceGroupName $AppInsightsResourceGroupName -AppServiceName $AppServiceName -AppServiceResourceGroupName $AppServiceResourceGroupName -AppServiceSlotName $availableSlot.name
}

Write-Footer -ScopedPSCmdlet $PSCmdlet
