[[_TOC_]]

# Description
This snippet will create a Point-To-Site VPN for you. 

# Parameters
Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.

| Parameter | Example Value | Description |
|--|--|--|
| VirtualNetworkGatewayVnetName | `my-vnet-$(Release.EnvironmentName)` | The name of the VNET. |
| VirtualNetworkGatewayVnetResourceGroupName | `sharedservices-rg` | The resource group of the VNET. |
| VirtualNetworkGatewayName | `VPN-To-Onprem` | The name of the virtual network gateway. |
| VirtualNetworkGatewayResouceGroupName | `Customer-Shared-$(Release.EnvironmentName)` | The resourcegroup where the virtual network gateway should be. This is usually in the same resourcegroup as your vnet. |
| VirtualNetworkGatewaySkuName | `VpnGw1` | The SKU name for the Virtual network gateway. Accepted values: `Basic, ErGw1AZ, ErGw2AZ, ErGw3AZ, HighPerformance, Standard, UltraPerformance, VpnGw1, VpnGw1AZ, VpnGw2, VpnGw2AZ, VpnGw3, VpnGw3AZ, VpnGw4, VpnGw4AZ, VpnGw5, VpnGw5AZ` |

# Code
[Click here to download this script](../../../../src/Networking/Create-Point-to-Site-VPN.ps1)

# Links

[Azure CLI - az network vnet show](https://docs.microsoft.com/en-us/cli/azure/network/vnet?view=azure-cli-latest#az_network_vnet_show)

[Azure CLI - az network public-ip create](https://docs.microsoft.com/en-us/cli/azure/network/public-ip?view=azure-cli-latest#az_network_public_ip_create)

[Azure CLI - az network public-ip show](https://docs.microsoft.com/en-us/cli/azure/network/public-ip?view=azure-cli-latest#az_network_public_ip_show)

[Azure CLI - az network vnet-gateway show](https://docs.microsoft.com/en-us/cli/azure/network/vnet-gateway?view=azure-cli-latest#az_network_vnet_gateway_show)

[Azure CLI - az network vnet-gateway create](https://docs.microsoft.com/en-us/cli/azure/network/vnet-gateway?view=azure-cli-latest#az_network_vnet_gateway_create)