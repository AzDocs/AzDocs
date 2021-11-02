function Add-VnetIntegration
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string] $AppResourceGroupName,
        [Parameter(Mandatory)][string] $AppName,
        [Parameter(Mandatory)][string] $AppVnetIntegrationVnetName,
        [Parameter(Mandatory)][string] $AppVnetIntegrationSubnetName,
        [Parameter()][string] $AppSlotName,
        [Parameter(Mandatory)][bool] $RouteAllTrafficThroughVnet,
        [Parameter(Mandatory)][ValidateSet('functionapp', 'webapp')][string]$AppType  
    )

    Write-Header -ScopedPSCmdlet $PSCmdlet

    $fullAppName = $AppName
    $additionalParameters = @()

    if ($AppSlotName)
    {
        $additionalParameters += '--slot' , $AppSlotName
        $fullAppName += " [$AppSlotName]"
    }
    
    $vnetIntegrations = Invoke-Executable az $AppType vnet-integration list --resource-group $AppResourceGroupName --name $AppName @additionalParameters | ConvertFrom-Json
    $matchedIntegrations = $vnetIntegrations | Where-Object vnetResourceId -Like "*/providers/Microsoft.Network/virtualNetworks/$AppVnetIntegrationVnetName/subnets/$AppVnetIntegrationSubnetName"
    if ($matchedIntegrations)
    {
        Write-Host "VNET Integration found for $fullAppName"
    }
    else
    {
        Write-Host "VNET Integration NOT found, adding it to $fullAppName"
        Invoke-Executable az $AppType vnet-integration add --resource-group $AppResourceGroupName --name $AppName --vnet $AppVnetIntegrationVnetName --subnet $AppVnetIntegrationSubnetName @additionalParameters
        Invoke-Executable az $AppType restart --name $AppName --resource-group $AppResourceGroupName @additionalParameters
    }
    
    # Set vnet-route-all for vnet integration
    Invoke-Executable az $AppType config set --resource-group $AppResourceGroupName --name $AppName @additionalParameters --vnet-route-all-enabled $RouteAllTrafficThroughVnet
    
    Write-Footer -ScopedPSCmdlet $PSCmdlet
}