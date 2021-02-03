[[_TOC_]]

# Description
This snippet will create a keyvault if it does not exist within a given (existing) subnet. It will also make sure that public access is denied by default. It will whitelist the application subnet so your app can connect to the keyvault within the vnet. All the needed components (private endpoint, service endpoint etc) will be created too.

This snippet also managed the following compliancy rules:
- Enable soft-delete
- Enable Diagnostic settings
- Use private endpoint
- block access from the internet
- Whitelist subnet

# Parameters
Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.

| Parameter | Example Value | Description |
|--|--|--|
| KeyvaultPrivateEndpointVnetResourceGroupName | `sharedservices-rg` | The ResourceGroup where your VNET, for your SQL Server Private Endpoint, resides in. |
| KeyvaultPrivateEndpointVnetName | `my-vnet-$(Release.EnvironmentName)` | The name of the VNET to place the Keyvault Private Endpoint in. |
| ApplicationVnetResourceGroupName | `sharedservices-rg` | The ResourceGroup where your VNET, for your appservice, resides in. |
| ApplicationVnetName | `my-vnet-$(Release.EnvironmentName)` | The name of the VNET the appservice is in|
| ApplicationSubnetName | `app-subnet-3` | The subnetname for the subnet whitelist on the keyvault. |
| DNSZoneResourceGroupName | `MyDNSZones-$(Release.EnvironmentName)` | Make sure to use the shared DNS Zone resource group (you can only register a zone once per subscription). |
| KeyvaultPrivateDnsZoneName | `privatelink.vaultcore.azure.net` | Generally this will be `privatelink.vaultcore.azure.net`. This defines which DNS Zone to use for the private keyvault endpoint. |
| KeyvaultDiagnosticsName | `mykeyvault-$(Release.EnvironmentName)` | This name will be used as an identifier in the log analytics workspace. It is recommended to use your Application Insights name for this parameter. |
| KeyvaultName | `mykeyvault-$(Release.EnvironmentName)` | This is the keyvault name to use. |
| KeyvaultPrivateEndpointSubnetName | `app-subnet-3` | The name of the subnet where the keyvault's private endpoint will reside in. |
| LogAnalyticsWorkspaceName | `/subscriptions/<subscriptionid>/resourceGroups/<resourcegroup>/providers/Microsoft.OperationalInsights/workspaces/<loganalyticsworkspacename>` | The name of the Log Analytics Workspace for the diagnostics settings of the keyvault. |
| KeyvaultResourceGroupName | `MyTeam-TestApi-$(Release.EnvironmentName)` | The ResourceGroup where your keyvault will reside in. |

# Code
[Click here to download this script](../../../../src/Keyvault/Create-Keyvault.ps1)

# Links

[Azure CLI - az-keyvault-create](https://docs.microsoft.com/en-us/cli/azure/keyvault?view=azure-cli-latest#az-keyvault-create)

[Azure CLI - Keyvault softdelete](https://docs.microsoft.com/en-us/azure/key-vault/general/soft-delete-cli)

[Azure CLI - az-network-vnet-subnet-update](https://docs.microsoft.com/en-us/cli/azure/network/vnet/subnet?view=azure-cli-latest#az-network-vnet-subnet-update)

[Azure CLI - az-keyvault-show](https://docs.microsoft.com/en-us/cli/azure/keyvault?view=azure-cli-latest#az-keyvault-show)

[Azure CLI - az-network-private-endpoint-create](https://docs.microsoft.com/en-us/cli/azure/network/private-endpoint?view=azure-cli-latest#az-network-private-endpoint-create)

[Azure CLI - az-network-private-dns-zone-show](https://docs.microsoft.com/en-us/cli/azure/ext/privatedns/network/private-dns/zone?view=azure-cli-latest#ext-privatedns-az-network-private-dns-zone-show)

[Azure CLI - az-network-private-dns-zone-create](https://docs.microsoft.com/en-us/cli/azure/ext/privatedns/network/private-dns/zone?view=azure-cli-latest#ext-privatedns-az-network-private-dns-zone-create)

[Azure CLI - az-network-private-dns-link-vnet-show](https://docs.microsoft.com/en-us/cli/azure/network/private-dns/link/vnet?view=azure-cli-latest#az-network-private-dns-link-vnet-show)

[Azure CLI - az-network-private-dns-link-vnet-create](https://docs.microsoft.com/en-us/cli/azure/network/private-dns/link/vnet?view=azure-cli-latest#az-network-private-dns-link-vnet-create)

[Azure CLI - az-network-private-endpoint-dns-zone-group-create](https://docs.microsoft.com/en-us/cli/azure/network/private-endpoint/dns-zone-group?view=azure-cli-latest#az-network-private-endpoint-dns-zone-group-create)

[Azure CLI - az-network-vnet-subnet-show](https://docs.microsoft.com/en-us/cli/azure/network/vnet/subnet?view=azure-cli-latest#az-network-vnet-subnet-show)

[Azure CLI - az-keyvault-network-rule-add](https://docs.microsoft.com/en-us/cli/azure/keyvault/network-rule?view=azure-cli-latest#az-keyvault-network-rule-add)

[Azure CLI - az-network-private-link-resource-list](https://docs.microsoft.com/en-us/cli/azure/network/private-link-resource?view=azure-cli-latest#az-network-private-link-resource-list)

[Create Diagnostics settings](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/diagnostic-settings)

[Azure CLI - Create Diagnostics settings](http://techgenix.com/azure-diagnostic-settings/)