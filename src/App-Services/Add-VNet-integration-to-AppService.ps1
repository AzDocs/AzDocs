[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $AppServiceResourceGroupName,
    [Parameter(Mandatory)][string] $AppServiceName,
    [Parameter()][string] $AppServiceVnetIntegrationVnetResourceGroupName,
    [Alias('VnetName')]
    [Parameter(Mandatory)][string] $AppServiceVnetIntegrationVnetName,
    [Parameter(Mandatory)][string] $AppServiceVnetIntegrationSubnetName,
    [Parameter()][string] $AppServiceSlotName,
    [Parameter()][bool] $ApplyToAllSlots = $false,
    [Parameter()][bool] $RouteAllTrafficThroughVnet = $true
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

# Fetch available slots if we want to deploy all slots
if ($ApplyToAllSlots -eq $True)
{
    $availableSlots = Invoke-Executable -AllowToFail az webapp deployment slot list --name $AppServiceName --resource-group $AppServiceResourceGroupName | ConvertFrom-Json
}

if (![string]::IsNullOrWhiteSpace($AppServiceVnetIntegrationVnetResourceGroupName))
{
    $AppServiceVnetIntegrationVnetName = (Invoke-Executable az network vnet show --resource-group $AppServiceVnetIntegrationVnetResourceGroupName --name $AppServiceVnetIntegrationVnetName | ConvertFrom-Json).id
}

# Set VNET Integration on the main given slot (normally production)
Add-VnetIntegration -appType 'webapp' -AppResourceGroupName $AppServiceResourceGroupName -AppName $AppServiceName -AppVnetIntegrationVnetName $AppServiceVnetIntegrationVnetName -AppVnetIntegrationSubnetName $AppServiceVnetIntegrationSubnetName -AppSlotName $AppServiceSlotName -RouteAllTrafficThroughVnet:$RouteAllTrafficThroughVnet

# Apply to all slots if desired
foreach ($availableSlot in $availableSlots)
{
    Add-VnetIntegration -appType 'webapp' -AppResourceGroupName $AppServiceResourceGroupName -AppName $AppServiceName -AppVnetIntegrationVnetName $AppServiceVnetIntegrationVnetName -AppVnetIntegrationSubnetName $AppServiceVnetIntegrationSubnetName -AppSlotName $availableSlot.name -RouteAllTrafficThroughVnet:$RouteAllTrafficThroughVnet
}

Write-Footer -ScopedPSCmdlet $PSCmdlet