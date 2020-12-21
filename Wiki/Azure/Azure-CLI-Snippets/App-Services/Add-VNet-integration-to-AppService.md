[[_TOC_]]

# Description

This snippet will add vnet-integration to an existing appservice.

# Parameters

Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.
| Parameter | Example Value | Description |
|--|--|--|
| appServiceName | `MyTeam-TestApi-$(Release.EnvironmentName)` | The name of the webapp. It's recommended to stick to alphanumeric & hyphens for this. |
| appServiceResourceGroupName | `MyTeam-TestApi-$(Release.EnvironmentName)` | The resourcegroup where the appservice resides in
| appServiceVnetIntegrationSubnetName | `app-subnet-4` | The name of the subnet to place the vnet-integration in. Note: Adding an appservice vnetintegration to a subnet will delegate that entire subnet to the appservice. This means that no other resources can be placed inside this vnet (even no other appserviceplans). This has to be an empty subnet. |
| AppServiceSlotName | `staging` | OPTIONAL By default the production slot is used, use this variable to use a different slot. |

# Code

[Click here to download this script](../../../../src/App-Services/Add-VNet-integration-to-AppService.ps1)

# Links

- [Azure CLI - az-webapp-vnet-integration-list](https://docs.microsoft.com/en-us/cli/azure/webapp/vnet-integration?view=azure-cli-latest#az-webapp-vnet-integration-list)
- [Azure CLI - az-webapp-vnet-integration-add](https://docs.microsoft.com/en-us/cli/azure/webapp/vnet-integration?view=azure-cli-latest#az-webapp-vnet-integration-add)
- [Azure CLI - az-webapp-restart](https://docs.microsoft.com/en-us/cli/azure/webapp?view=azure-cli-latest#az-webapp-restart)