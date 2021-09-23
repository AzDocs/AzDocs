[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $FunctionAppResourceGroupName,
    [Parameter(Mandatory)][string] $FunctionAppName,
    [Alias('VnetName')]
    [Alias('FunctionAppVnetIntegrationName')]
    [Parameter(Mandatory)][string] $FunctionAppVnetIntegrationVnetName,
    [Parameter(Mandatory)][string] $FunctionAppVnetIntegrationSubnetName,
    [Parameter()][string] $FunctionAppServiceDeploymentSlotName,
    [Parameter()][bool] $ApplyToAllSlots = $false,
    [Parameter()][bool] $RouteAllTrafficThroughVnet = $true
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

# Fetch available slots if we want to deploy all slots
if ($ApplyToAllSlots)
{
    $availableSlots = Invoke-Executable -AllowToFail az functionapp deployment slot list --name $FunctionAppName --resource-group $FunctionAppResourceGroupName | ConvertFrom-Json
}

# Set VNET Integration on the main given slot (normally production)
Add-VnetIntegration -AppType 'functionapp' -AppResourceGroupName $FunctionAppResourceGroupName -AppName $FunctionAppName -AppVnetIntegrationVnetName $FunctionAppVnetIntegrationVnetName -AppVnetIntegrationSubnetName $FunctionAppVnetIntegrationSubnetName -AppSlotName $FunctionAppServiceDeploymentSlotName -RouteAllTrafficThroughVnet:$RouteAllTrafficThroughVnet

# Apply to all slots if desired
foreach ($availableSlot in $availableSlots)
{
    Add-VnetIntegration -AppType 'functionapp' -AppResourceGroupName $FunctionAppResourceGroupName -AppName $FunctionAppName -AppVnetIntegrationVnetName $FunctionAppVnetIntegrationVnetName -AppVnetIntegrationSubnetName $FunctionAppVnetIntegrationSubnetName -AppSlotName $availableSlot.name -RouteAllTrafficThroughVnet:$RouteAllTrafficThroughVnet
}

Write-Footer -ScopedPSCmdlet $PSCmdlet