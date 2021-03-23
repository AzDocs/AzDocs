[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $AppServiceResourceGroupName,
    [Parameter(Mandatory)][string] $AppServiceName,
    [Alias("VnetName")]
    [Parameter(Mandatory)][string] $AppServiceVnetIntegrationVnetName,
    [Parameter(Mandatory)][string] $AppServiceVnetIntegrationSubnetName,
    [Parameter()][string] $AppServiceSlotName,
    [Parameter()][bool] $ApplyToAllSlots = $false
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

function Add-VnetIntegration
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string] $AppServiceResourceGroupName,
        [Parameter(Mandatory)][string] $AppServiceName,
        [Parameter(Mandatory)][string] $AppServiceVnetIntegrationVnetName,
        [Parameter(Mandatory)][string] $AppServiceVnetIntegrationSubnetName,
        [Parameter()][string] $AppServiceSlotName
    )

    Write-Header -ScopedPSCmdlet $PSCmdlet

    $fullAppServiceName = $AppServiceName
    $additionalParameters = @()

    if ($AppServiceSlotName) {
        $additionalParameters += '--slot' , $AppServiceSlotName
        $fullAppServiceName += " [$AppServiceSlotName]"
    }
    
    $vnetIntegrations = Invoke-Executable az webapp vnet-integration list --resource-group $AppServiceResourceGroupName --name $AppServiceName @additionalParameters | ConvertFrom-Json
    $matchedIntegrations = $vnetIntegrations | Where-Object  vnetResourceId -like "*/providers/Microsoft.Network/virtualNetworks/$AppServiceVnetIntegrationVnetName/subnets/$AppServiceVnetIntegrationSubnetName"
    if ($matchedIntegrations) {
        Write-Host "VNET Integration found for $fullAppServiceName"
    }
    else {
        Write-Host "VNET Integration NOT found, adding it to $fullAppServiceName"
        Invoke-Executable az webapp vnet-integration add --resource-group $AppServiceResourceGroupName --name $AppServiceName --vnet $AppServiceVnetIntegrationVnetName --subnet $AppServiceVnetIntegrationSubnetName @additionalParameters
        Invoke-Executable az webapp restart --name $AppServiceName --resource-group $AppServiceResourceGroupName @additionalParameters
    }
    
    # Set WEBSITE_VNET_ROUTE_ALL=1 for vnet integration
    Invoke-Executable az webapp config appsettings set --resource-group $AppServiceResourceGroupName --name $AppServiceName @additionalParameters --settings "WEBSITE_VNET_ROUTE_ALL=1"
    
    Write-Footer -ScopedPSCmdlet $PSCmdlet
}

Write-Footer -ScopedPSCmdlet $PSCmdlet

# To slot or not, thats the question
if($AppServiceSlotName)
{
    Add-VnetIntegration -AppServiceResourceGroupName $AppServiceResourceGroupName -AppServiceName $AppServiceName -AppServiceVnetIntegrationVnetName $AppServiceVnetIntegrationVnetName -AppServiceVnetIntegrationSubnetName $AppServiceVnetIntegrationSubnetName -AppServiceSlotName $AppServiceSlotName
}
else
{
    Add-VnetIntegration -AppServiceResourceGroupName $AppServiceResourceGroupName -AppServiceName $AppServiceName -AppServiceVnetIntegrationVnetName $AppServiceVnetIntegrationVnetName -AppServiceVnetIntegrationSubnetName $AppServiceVnetIntegrationSubnetName
}

# Apply to all slots if desired
if ($ApplyToAllSlots)
{
    $availableSlots = Invoke-Executable -AllowToFail az webapp deployment slot list --name $AppServiceName --resource-group $AppServiceResourceGroupName | ConvertFrom-Json
    foreach($availableSlot in $availableSlots)
    {
        Add-VnetIntegration -AppServiceResourceGroupName $AppServiceResourceGroupName -AppServiceName $AppServiceName -AppServiceVnetIntegrationVnetName $AppServiceVnetIntegrationVnetName -AppServiceVnetIntegrationSubnetName $AppServiceVnetIntegrationSubnetName -AppServiceSlotName $availableSlot.name
    }
}