# WARNING: THIS SCRIPT IS NOT FULLY DONE.
# This currently creates a Virtual network gateway. Thats it :).
[CmdletBinding()]
param (
    [Parameter()]
    [String] $vnetName,

    [Parameter()]
    [String] $vnetResourceGroupName,

    [Parameter()]
    [String] $virtualNetworkGatewayName,

    [Parameter()]
    [String] $virtualNetworkGatewayResouceGroupName,

    [Parameter()]
    [String] $virtualNetworkGatewaySkuName = "VpnGw1"
)

# Prepare some information
$vnetId = (az network vnet show -g $vnetResourceGroupName -n $vnetName | ConvertFrom-Json).id
$virtualNetworkGatewayPublicIpName = "$($virtualNetworkGatewayName)-publicip"
Write-Host "VNET ID: $vnetId"

# Make sure we have the Public IP Available
$publicIpId = (az network public-ip show --resource-group $virtualNetworkGatewayResouceGroupName --name $virtualNetworkGatewayPublicIpName | ConvertFrom-Json).id
if([String]::IsNullOrWhiteSpace($publicIpId))
{
    $publicIpId = (az network public-ip create -g $virtualNetworkGatewayResouceGroupName -n $virtualNetworkGatewayPublicIpName | ConvertFrom-Json).publicIp.id
}
Write-Host "PublicIp: $publicIpId"

# Create the Virtual Network Gateway
$virtualNetworkGatewayId = (az network vnet-gateway show --resource-group $virtualNetworkGatewayResouceGroupName --name $virtualNetworkGatewayName | ConvertFrom-Json).id
if(!$virtualNetworkGatewayId)
{
    $virtualNetworkGatewayId = (az network vnet-gateway create --name $virtualNetworkGatewayName --public-ip-address $publicIpId --resource-group $virtualNetworkGatewayResouceGroupName --vnet $vnetId --gateway-type Vpn --vpn-type RouteBased --sku $virtualNetworkGatewaySkuName | ConvertFrom-Json).vnetGateway.id
}
