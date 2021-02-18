[[_TOC_]]

# Description

This snippet will create an Web App if it does not exist & create an app service plan if it does not exist. It also adds the mandatory tags to the resources.

The webapp is set to https only and the webapp cannot be deployed with ftp(s) for to be compliant with the azure policies.

This snippet also managed the following compliancy rules:

- HTTPS only
- Disable FTP
- Set Tags on this resource
- Set a Managed Identity for the appservice
- Adds a private endpoint to securely connect to this appservice
- Sets the network configuration to only allow the private endpoint connection

# Parameters

Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.
| Parameter | Example Value | Description |
|--|--|--|
| AppServiceName | `azuretestapi-$(Release.EnvironmentName)` | The name of the webapp. It's recommended to stick to alphanumeric & hyphens for this. |
| AppServiceDiagnosticsName | `azuretestapi-$(Release.EnvironmentName)` | This name will be used as an identifier in the log analytics workspace. It is recommended to use your Application Insights name for this parameter. |
| AppServicePlanName | `Shared-ASP-$(Release.EnvironmentName)-Win-1` | The AppService Plan name. Mandatory and and this may be an existing App service plan, Windows App services should use a different App Service Plan then Linux App services |
| AppServicePlanSkuName | `S1` | The pricing tier that is going to be used. A list can be found here: [App Service Pricing for SKU's](https://azure.microsoft.com/nl-nl/pricing/details/app-service/windows/) |
| LogAnalyticsWorkspaceResourceId | `/subscriptions/<subscriptionid>/resourceGroups/<resourcegroup>/providers/Microsoft.OperationalInsights/workspaces/<loganalyticsworkspacename>` | The log analytics workspace the appservice is using for writing its diagnostics settings). |
| AppServicePrivateEndpointSubnetName | `app-subnet-3` | The subnet to place the private endpoint for this appservice in |
| AppServicePlanResourceGroupName | `Shared-ASP-$(Release.EnvironmentName)-Win` | The ResourceGroup name where the AppServicePlan resides in. |
| DNSZoneResourceGroupName | `MyDNSZones-$(Release.EnvironmentName)` | Make sure to use the shared DNS Zone resource group (you can only register a zone once per subscription). |
| AppServicePrivateDnsZoneName | `privatelink.azurewebsites.net` | The DNS Zone to use. If you are not sure, it's safe to use `privatelink.azurewebsites.net` as value for AppServices. |
| AppServiceResourceGroupName| `MyTeam-TestApi-$(Release.EnvironmentName)` | The ResourceGroup where your desired AppService will reside in |
| AppServiceRunTime | `'"DOTNETCORE|3.1"'` | The name of the runtime stack. Note: you need to encapsulate this value (even when you pass it as a variable) with a `' " <value> " '` (without spaces), which is needed to mitigate the parsing of the pipe character in this string. If you forget to do this, you will get an error about the runtime which could not be found. For a list of runtimes please use the `az webapp list-runtimes --linux` command [(Documentation here)](https://docs.microsoft.com/en-us/cli/azure/webapp?view=azure-cli-latest#az_webapp_list_runtimes). |
| EnableAppServiceDeploymentSlot | If you pass this switch (without value), a deployment slot will be created. | 
| AppServiceDeploymentSlotName | `'staging'` | Name of the slot to create additional to the production slot. Has the default value of "staging". |
| DisablePublicAccessForAppServiceDeploymentSlot | `true` | The public access can be removed from the deployment slot. By default this has a value of true. |  
| AppServicePrivateEndpointVnetName | `my-vnet-$(Release.EnvironmentName)` | The name of the VNET to place the App Service Private Endpoint in. |
| AppServicePrivateEndpointVnetResourceGroupName | `sharedservices-rg` | The ResourceGroup where your VNET, for your App Service Private Endpoint, resides in. |


# Code

The snippet for creating a webapp with linux and using the given runtime environment. This snippet will also create the app service plan if it does not exist (Linux is defined during the AppServiceplan creation). Note that there can be no Windows App Service Plans in the same resourcegroup.

[Click here to download this script](../../../../src/App-Services/Create-Web-App-with-App-Service-Plan-Linux.ps1)

# Links

- [Azure CLI - az webapp create](https://docs.microsoft.com/en-us/cli/azure/webapp?view=azure-cli-latest#az-webapp-create)
- [Azure CLI - az appservice plan create](https://docs.microsoft.com/en-us/cli/azure/appservice/plan?view=azure-cli-latest#az-appservice-plan-create)
- [Azure CLI - az webapp identity](https://docs.microsoft.com/en-us/cli/azure/webapp/identity?view=azure-cli-latest)
- [App Service Pricing for SKU's](https://azure.microsoft.com/nl-nl/pricing/details/app-service/windows/)
- [App Service Create Diagnostics settings](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/diagnostic-settings)
- [App Service Az Monitor Diagnostics settings](https://docs.microsoft.com/en-us/cli/azure/monitor/diagnostic-settings?view=azure-cli-latest#az-monitor-diagnostic-settings-update)
- [App Service Enable Diagnostics Logging](https://docs.microsoft.com/en-us/azure/app-service/troubleshoot-diagnostic-logs)
- [Template settings for Diagnostics settings](https://docs.microsoft.com/en-us/azure/azure-monitor/samples/resource-manager-diagnostic-settings)
- [Azure CLI for Diagnostics settings](http://techgenix.com/azure-diagnostic-settings/)
- [Azure CLI - az webapp deployment slot create](https://docs.microsoft.com/en-us/cli/azure/webapp/deployment/slot?view=azure-cli-latest#az_webapp_deployment_slot_create)
