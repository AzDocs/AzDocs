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

if ($ApplyToAllSlots)
{
    $availableSlots = Invoke-Executable -AllowToFail az functionapp deployment slot list --name $FunctionAppName --resource-group $FunctionAppResourceGroupName | ConvertFrom-Json
}

# Set the AppInsights connection information on the AppService
SetAppInsightsForFunctionApp -AppInsightsName $AppInsightsName -AppInsightsResourceGroupName $AppInsightsResourceGroupName -FunctionAppName $FunctionAppName -FunctionAppResourceGroupName $FunctionAppResourceGroupName -AppServiceSlotName $AppServiceSlotName

# Apply to all slots if desired
foreach($availableSlot in $availableSlots)
{
    SetAppInsightsForFunctionApp -AppInsightsName $AppInsightsName -AppInsightsResourceGroupName $AppInsightsResourceGroupName -FunctionAppName $FunctionAppName -FunctionAppResourceGroupName $FunctionAppResourceGroupName -AppServiceSlotName $availableSlot.name
}

Write-Footer -ScopedPSCmdlet $PSCmdlet
