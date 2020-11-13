[[_TOC_]]

# Description
This snippet will create an application gateway.

# Parameters
Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.

| Parameter | Example Value | Description |
|--|--|--|
| applicationGatewayName | `customer-appgw-$(Release.EnvironmentName)` | The name to use for this application gateway |
| applicationGatewayResourceGroupName | `myshared-resourcegroup` | The name of the resourcegroup to place this application gateway in. |
| gatewaySubnetName | `gateway-subnet` | The subnet where you want to place this Application Gateway in. |
| applicationGatewayCapacity | `2` | The number of instances to use for this appgw |
| applicationGatewaySku | `Standard_v2` | The SKU name for the AppGw. Advised value: Standard_v2. List of accepted values: Standard_Large, Standard_Medium, Standard_Small, Standard_v2, WAF_Large, WAF_Medium, WAF_v2. |
| certificateKeyvaultName | `my-shared-keyvault` | The keyvault where you want to save your SSL certificates to for this AppGw. This is usually 1 tenant-wide shared keyvault dedicated to these SSL certificates. |
| certificateKeyvaultResourceGroupName | `myshared-resourcegroup` | The resourcegroup where the keyvault resides in. |

# Code
[Click here to download this script](../../../../src/Application-Gateway/Create-Application-Gateway.ps1)

# Links

[Azure CLI - az network vnet show](https://docs.microsoft.com/en-us/cli/azure/network/vnet?view=azure-cli-latest#az_network_vnet_show)

[Azure CLI - az network public-ip create](https://docs.microsoft.com/en-us/cli/azure/network/public-ip?view=azure-cli-latest#az_network_public_ip_create)

[Azure CLI - az network public-ip show](https://docs.microsoft.com/en-us/cli/azure/network/public-ip?view=azure-cli-latest#az_network_public_ip_show)

[Azure CLI - az network application-gateway create](https://docs.microsoft.com/en-us/cli/azure/network/application-gateway?view=azure-cli-latest#az_network_application_gateway_create)

[Azure CLI - az identity create](https://docs.microsoft.com/en-us/cli/azure/identity?view=azure-cli-latest#az_identity_create)

[Azure CLI - az identity show](https://docs.microsoft.com/en-us/cli/azure/identity?view=azure-cli-latest#az_identity_show)

[Azure CLI - az network application-gateway identity assign](https://docs.microsoft.com/en-us/cli/azure/network/application-gateway/identity?view=azure-cli-latest#az_network_application_gateway_identity_assign)

[Azure CLI - az network vnet subnet update](https://docs.microsoft.com/en-us/cli/azure/network/vnet/subnet?view=azure-cli-latest#az_network_vnet_subnet_update)

[Azure CLI - az keyvault network-rule add](https://docs.microsoft.com/en-us/cli/azure/keyvault/network-rule?view=azure-cli-latest#az_keyvault_network_rule_add)
