[CmdletBinding()]
param (
    [Parameter()]
    [String] $vnetName,

    [Parameter()]
    [String] $vnetResourceGroupName,

    [Parameter()]
    [String] $virtualNetworkGatewaySubnetName,

    [Parameter()]
    [String] $virtualNetworkGatewayName,

    [Parameter()]
    [String] $virtualNetworkGatewayResouceGroupName,

    [Parameter()]
    [String] $virtualNetworkGatewaySkuName = "VpnGw1",

    [Parameter()]
    [String] $localGatewayName,

    [Parameter()]
    [String] $localGatewayIpAddress,

    [Parameter()]
    [String] $localNetworkCIDR,

    [Parameter()]
    [String] $vpnConnectionName,

    [Parameter()]
    [String] $vpnConnectionSharedKey
)

# Prepare some information
$vnetId = (az network vnet show -g $vnetResourceGroupName -n $vnetName | ConvertFrom-Json).id
$virtualNetworkGatewaySubnetId = (az network vnet subnet show -g $vnetResourceGroupName -n $virtualNetworkGatewaySubnetName --vnet-name $vnetName | ConvertFrom-Json).id
$virtualNetworkGatewayPublicIpName = "$($virtualNetworkGatewayName)-publicip"
Write-Host "VNET ID: $vnetId"
Write-Host "VirtualNetworkGateway SubnetID: $virtualNetworkGatewaySubnetId"

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

# Create the Local Network Gateway
$localGatewayId = (az network local-gateway show --resource-group $virtualNetworkGatewayResouceGroupName --name $localGatewayName | ConvertFrom-Json).id
if(!$localGatewayId)
{
    $localGatewayId = (az network local-gateway create --resource-group $virtualNetworkGatewayResouceGroupName --name $localGatewayName --gateway-ip-address $localGatewayIpAddress --local-address-prefixes $localNetworkCIDR | ConvertFrom-Json).id
}

# Create the connection between the Virtual Network Gateway and the On-Premises Gateway (Site-to-Site VPN)
$vpnConnection = az network vpn-connection show --name $vpnConnectionName --resource-group $virtualNetworkGatewayResouceGroupName | ConvertFrom-Json
if(!$vpnConnection)
{
    az network vpn-connection create --name $vpnConnectionName --resource-group $virtualNetworkGatewayResouceGroupName --vnet-gateway1 $virtualNetworkGatewayId --shared-key $vpnConnectionSharedKey --local-gateway2 $localGatewayName
}

