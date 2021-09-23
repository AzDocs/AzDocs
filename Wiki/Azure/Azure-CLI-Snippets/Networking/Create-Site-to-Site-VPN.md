[[_TOC_]]

# Description

This snippet will create an Azure Container Instances instance for you. It will be integrated into the given subnet.

# Parameters

Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.

| Parameter                                  | Example Value                                            | Description                                                                                                                                                                                                                              |
| ------------------------------------------ | -------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| VirtualNetworkGatewayVnetName              | `my-vnet-$(Release.EnvironmentName)`                     | The name of the VNET.                                                                                                                                                                                                                    |
| VirtualNetworkGatewayVnetResourceGroupName | `sharedservices-rg`                                      | The resource group of the VNET.                                                                                                                                                                                                          |
| VirtualNetworkGatewayName                  | `VPN-To-Onprem`                                          | The name of the virtual network gateway.                                                                                                                                                                                                 |
| VirtualNetworkGatewayResouceGroupName      | `Customer-Shared-$(Release.EnvironmentName)`             | The resourcegroup where the virtual network gateway should be. This is usually in the same resourcegroup as your vnet.                                                                                                                   |
| VirtualNetworkGatewaySkuName               | `VpnGw1`                                                 | The SKU name for the Virtual network gateway. Accepted values: `Basic, ErGw1AZ, ErGw2AZ, ErGw3AZ, HighPerformance, Standard, UltraPerformance, VpnGw1, VpnGw1AZ, VpnGw2, VpnGw2AZ, VpnGw3, VpnGw3AZ, VpnGw4, VpnGw4AZ, VpnGw5, VpnGw5AZ` |
| LocalGatewayName                           | `onpremises-network-location-$(Release.EnvironmentName)` | The name of the local gateway to use.                                                                                                                                                                                                    |
| LocalGatewayIpAddress                      | `172.16.0.1`                                             | The local IP address for your gateway in your to-be-connected-datacenter.                                                                                                                                                                |
| LocalNetworkCIDR                           | `172.16.0.0/12`                                          | The CIDR for your to-be-connected-datacenter network.                                                                                                                                                                                    |
| VpnConnectionName                          | `customer-$(Release.EnvironmentName)-to-onpremises`      | The name for the connection resource.                                                                                                                                                                                                    |
| VpnConnectionSharedKey                     | `aM2uzBKjT2nAxwKhzS3u`                                   | The shared key for the VPN connection.                                                                                                                                                                                                   |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Create Site to Site VPN"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/Networking/Create-Site-to-Site-VPN.ps1"
    arguments: "-VirtualNetworkGatewayVnetName '$(VirtualNetworkGatewayVnetName)' -VirtualNetworkGatewayVnetResourceGroupName '$(VirtualNetworkGatewayVnetResourceGroupName)' -VirtualNetworkGatewayName '$(VirtualNetworkGatewayName)' -VirtualNetworkGatewayResouceGroupName '$(VirtualNetworkGatewayResouceGroupName)' -VirtualNetworkGatewaySkuName '$(VirtualNetworkGatewaySkuName)' -LocalGatewayName '$(LocalGatewayName)' -LocalGatewayIpAddress '$(LocalGatewayIpAddress)' -LocalNetworkCIDR '$(LocalNetworkCIDR)' -VpnConnectionName '$(VpnConnectionName)' -VpnConnectionSharedKey '$(VpnConnectionSharedKey)'"
```

# Code

[Click here to download this script](../../../../src/Networking/Create-Site-to-Site-VPN.ps1)

# Links

[Azure CLI - az network vnet show](https://docs.microsoft.com/en-us/cli/azure/network/vnet?view=azure-cli-latest#az_network_vnet_show)

[Azure CLI - az network public-ip create](https://docs.microsoft.com/en-us/cli/azure/network/public-ip?view=azure-cli-latest#az_network_public_ip_create)

[Azure CLI - az network public-ip show](https://docs.microsoft.com/en-us/cli/azure/network/public-ip?view=azure-cli-latest#az_network_public_ip_show)

[Azure CLI - az network vnet-gateway show](https://docs.microsoft.com/en-us/cli/azure/network/vnet-gateway?view=azure-cli-latest#az_network_vnet_gateway_show)

[Azure CLI - az network vnet-gateway create](https://docs.microsoft.com/en-us/cli/azure/network/vnet-gateway?view=azure-cli-latest#az_network_vnet_gateway_create)

[Azure CLI - az network local-gateway show](https://docs.microsoft.com/en-us/cli/azure/network/local-gateway?view=azure-cli-latest#az_network_local_gateway_show)

[Azure CLI - az network local-gateway create](https://docs.microsoft.com/en-us/cli/azure/network/local-gateway?view=azure-cli-latest#az_network_local_gateway_create)

[Azure CLI - az network vpn-connection show](https://docs.microsoft.com/en-us/cli/azure/network/vpn-connection?view=azure-cli-latest#az_network_vpn_connection_show)

[Azure CLI - az network vpn-connection create](https://docs.microsoft.com/en-us/cli/azure/network/vpn-connection?view=azure-cli-latest#az_network_vpn_connection_create)
