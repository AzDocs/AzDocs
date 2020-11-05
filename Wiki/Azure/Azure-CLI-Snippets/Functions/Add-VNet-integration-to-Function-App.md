[[_TOC_]]

# Description
This snippet will add vnet-integration to an existing function app.

# Parameters
Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.
| Parameter | Example Value | Description |
|--|--|--|
| functionAppName | `myteamtestapi$(Release.EnvironmentName)` | The name of the function app. It's recommended to stick to lowercase alphanumeric characters. |
| functionAppResourceGroupName | `MyTeam-TestApi-$(Release.EnvironmentName)` | The resourcegroup where the function app resides in
| functionAppVnetIntegrationSubnetName | `app-subnet-4` | The name of the subnet to place the vnet-integration in. Note: Adding a function app vnetintegration to a subnet will delegate that entire subnet to the function apps. This means that no other resources can be placed inside this vnet (even no other appserviceplans). This has to be an empty subnet. |

# Code
[Click here to download this script](../../../../src/Functions/Add-VNet-integration-to-Function-App.ps1)

# Links

- [Azure CLI - az-functionapp-vnet-integration-list](https://docs.microsoft.com/en-us/cli/azure/functionapp/vnet-integration?view=azure-cli-latest#az-functionapp-vnet-integration-list)
- [Azure CLI - az-functionapp-vnet-integration-add](https://docs.microsoft.com/en-us/cli/azure/functionapp/vnet-integration?view=azure-cli-latest#az-functionapp-vnet-integration-add)
- [Azure CLI - az-functionapp-restart](https://docs.microsoft.com/en-us/cli/azure/functionapp?view=azure-cli-latest#az-functionapp-restart)