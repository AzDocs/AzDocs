# WARNING: THIS SCRIPT IS NOT FULLY DONE.
# This currently creates a Virtual network gateway. Thats it :).
[CmdletBinding()]
param (
    [Alias("VnetName")]
    [Parameter(Mandatory)][string] $VirtualNetworkGatewayVnetName,
    [Alias("VnetResourceGroupName")]
    [Parameter(Mandatory)][string] $VirtualNetworkGatewayVnetResourceGroupName,
    [Parameter(Mandatory)][string] $VirtualNetworkGatewayName,
    [Parameter(Mandatory)][string] $VirtualNetworkGatewayResouceGroupName,
    [Parameter()][string] $VirtualNetworkGatewaySkuName = "VpnGw1"
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Write-HeaderFooter.ps1"
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
#endregion ===END IMPORTS===

Write-Header

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

Write-Footer