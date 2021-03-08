[CmdletBinding()]
param (
    [Alias("VnetName")]
    [Parameter(Mandatory)][string] $VirtualNetworkGatewayVnetName,
    [Alias("VnetResourceGroupName")]
    [Parameter(Mandatory)][string] $VirtualNetworkGatewayVnetResourceGroupName,
    [Parameter(Mandatory)][string] $VirtualNetworkGatewayName,
    [Parameter(Mandatory)][string] $VirtualNetworkGatewayResouceGroupName,
    [Parameter()][string] $VirtualNetworkGatewaySkuName = "VpnGw1",
    [Parameter(Mandatory)][string] $LocalGatewayName,
    [Parameter(Mandatory)][string] $LocalGatewayIpAddress,
    [Parameter(Mandatory)][string] $LocalNetworkCIDR,
    [Parameter(Mandatory)][string] $VpnConnectionName,
    [Parameter(Mandatory)][string] $VpnConnectionSharedKey
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

# Prepare some information
$vnetId = (Invoke-Executable az network vnet show --resource-group $VirtualNetworkGatewayVnetResourceGroupName --name $VirtualNetworkGatewayVnetName | ConvertFrom-Json).id
$virtualNetworkGatewayPublicIpName = "$($VirtualNetworkGatewayName)-publicip"
Write-Host "VNET ID: $vnetId"

# Make sure we have the Public IP Available
$publicIpId = (Invoke-Executable -AllowToFail az network public-ip show --resource-group $VirtualNetworkGatewayResouceGroupName --name $virtualNetworkGatewayPublicIpName | ConvertFrom-Json).id
if(!$publicIpId)
{
    $publicIpId = (Invoke-Executable az network public-ip create --resource-group $VirtualNetworkGatewayResouceGroupName --name $virtualNetworkGatewayPublicIpName | ConvertFrom-Json).publicIp.id
}
Write-Host "PublicIp: $publicIpId"

# Create the Virtual Network Gateway
$virtualNetworkGatewayId = (Invoke-Executable -AllowToFail az network vnet-gateway show --resource-group $VirtualNetworkGatewayResouceGroupName --name $VirtualNetworkGatewayName | ConvertFrom-Json).id
if(!$virtualNetworkGatewayId)
{
    $virtualNetworkGatewayId = (Invoke-Executable az network vnet-gateway create --name $VirtualNetworkGatewayName --public-ip-address $publicIpId --resource-group $VirtualNetworkGatewayResouceGroupName --vnet $vnetId --gateway-type Vpn --vpn-type RouteBased --sku $VirtualNetworkGatewaySkuName | ConvertFrom-Json).vnetGateway.id
}

# Create the Local Network Gateway
$localGatewayId = (Invoke-Executable -AllowToFail az network local-gateway show --resource-group $VirtualNetworkGatewayResouceGroupName --name $LocalGatewayName | ConvertFrom-Json).id
if(!$localGatewayId)
{
    $localGatewayId = (Invoke-Executable az network local-gateway create --resource-group $VirtualNetworkGatewayResouceGroupName --name $LocalGatewayName --gateway-ip-address $LocalGatewayIpAddress --local-address-prefixes $LocalNetworkCIDR | ConvertFrom-Json).id
}

# Create the connection between the Virtual Network Gateway and the On-Premises Gateway (Site-to-Site VPN)
$vpnConnection = Invoke-Executable -AllowToFail az network vpn-connection show --name $VpnConnectionName --resource-group $VirtualNetworkGatewayResouceGroupName | ConvertFrom-Json
if(!$vpnConnection)
{
    Invoke-Executable az network vpn-connection create --name $VpnConnectionName --resource-group $VirtualNetworkGatewayResouceGroupName --vnet-gateway1 $virtualNetworkGatewayId --shared-key $VpnConnectionSharedKey --local-gateway2 $LocalGatewayName
}

Write-Footer -ScopedPSCmdlet $PSCmdlet