[[_TOC_]]

# Description
This snippet will create an Function App if it does not exist. It also adds the mandatory tags to the resources.

The function app is set to https only and the webapp cannot be deployed with ftp(s) for to be compliant with the azure policies.

This snippet also managed the following compliancy rules:
 - HTTPS only
 - Disable FTP
 - Set Tags on this resource
 - Set a Managed Identity for the function app
 - Adds a private endpoint to securely connect to this function app
 - Sets the network configuration to only allow the private endpoint connection

# Parameters
Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.
| Parameter | Example Value | Description |
|--|--|--|
| FunctionAppName | `azuretestapifunc$(Release.EnvironmentName)` | The name of the function app. It's recommended to stick to lowercase alphanumeric characters for this. |
| AppServicePlanName | `Shared-ASP-$(Release.EnvironmentName)-Linux-1` | The AppService Plan name. Mandatory and and this may be an existing App service plan, Windows App services should use a different App Service Plan then Linux App services|
| FunctionAppPrivateEndpointSubnetName | `app-subnet-3` | The subnet to place the private endpoint for this function app in |
| AppServicePlanResourceGroupName | `Shared-ASP-$(Release.EnvironmentName)-Linux` | The ResourceGroup name where the AppServicePlan resides in. |
| FunctionAppDiagnosticsName | `azuretestapi-$(Release.EnvironmentName)` | This name will be used as an identifier in the log analytics workspace. It is recommended to use your Application Insights name for this parameter. |
| LogAnalyticsWorkspaceName | `/subscriptions/<subscriptionid>/resourceGroups/<resourcegroup>/providers/Microsoft.OperationalInsights/workspaces/<loganalyticsworkspacename>` | The log analytics workspace the appservice is using for writing its diagnostics settings) |
| DNSZoneResourceGroupName | `MyDNSZones-$(Release.EnvironmentName)` | Make sure to use the shared DNS Zone resource group (you can only register a zone once per subscription). |
| FunctionAppPrivateDnsZoneName | `privatelink.azurewebsites.net` | The DNS Zone to use. If you are not sure, it's safe to use `privatelink.azurewebsites.net` as value for AppServices.
| FunctionAppResourceGroupName | `MyTeam-TestApi-$(Release.EnvironmentName)` | The ResourceGroup where your desired Function App will reside in |
| FunctionAppStorageAccountName | `azuretestapifunc$(Release.EnvironmentName)storage` | The name of the (pre-existing) storage account which will be the backend storage for this function app |
| FunctionAppAlwaysOn | `true`/`false` | Let the function app run in always on mode (this doesn't work for consumption plan function apps) |
| FUNCTIONS_EXTENSION_VERSION | `~3` | Choose `~2` voor v2 and `~3` for v3 of Function Apps (if you are unsure, use `~3`) |
| ASPNETCORE_ENVIRONMENT | `Development` | Use either `Development`, `Acceptance` or `Production`. NOTE: `Development` and `Production` have features which are provided by the framework. [Read more here](https://docs.microsoft.com/en-us/aspnet/core/fundamentals/environments) |
| FunctionAppPrivateEndpointVnetName | `my-vnet-$(Release.EnvironmentName)` | The name of the VNET to place the Function App Private Endpoint in. |
| FunctionAppPrivateEndpointVnetResourceGroupName | `sharedservices-rg` | The ResourceGroup where your VNET, for your Function App Private Endpoint, resides in. |
| EnableFunctionAppDeploymentSlot | If you pass this switch (without value), a deployment slot will be created. | 
| FunctionAppDeploymentSlotName | `staging` | Name of the slot to create additional to the production slot. Has the default value of "staging". |
| DisablePublicAccessForFunctionAppDeploymentSlot | `true` | The public access can be removed from the deployment slot. By default this has a value of true. |  
| FunctionAppNumberOfInstances | `2` | OPTIONAL: You can define how much instances of your functions will be ran (use 2 or more for HA. use 1 if you have server side sessions/stateful apps). The default value (if you don't pass any value) will be 2. |

# Code
## Create Linux FunctionApp
The snippet to create a Linux Function App.

[Click here to download this script](../../../../src/Functions/Create-Function-App-Linux.ps1)

# Links

- [Azure CLI - az-functionapp-create](https://docs.microsoft.com/en-us/cli/azure/functionapp?view=azure-cli-latest#az-functionapp-create)
- [Azure CLI - az appservice plan show](https://docs.microsoft.com/en-us/cli/azure/appservice/plan?view=azure-cli-latest#az-appservice-plan-show)
- [Azure CLI - az-functionapp-identity-assign](https://docs.microsoft.com/en-us/cli/azure/functionapp/identity?view=azure-cli-latest#az-functionapp-identity-assign)
- [App Service Pricing for SKU's](https://azure.microsoft.com/nl-nl/pricing/details/app-service/windows/)
- [App Service Create Diagnostics settings](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/diagnostic-settings)
- [App Service Az Monitor Diagnostics settings](https://docs.microsoft.com/en-us/cli/azure/monitor/diagnostic-settings?view=azure-cli-latest#az-monitor-diagnostic-settings-update)
- [App Service Enable Diagnostics Logging](https://docs.microsoft.com/en-us/azure/app-service/troubleshoot-diagnostic-logs)
- [Template settings for Diagnostics settings](https://docs.microsoft.com/en-us/azure/azure-monitor/samples/resource-manager-diagnostic-settings)
- [Azure Cli for Diagnostics settings](http://techgenix.com/azure-diagnostic-settings/)