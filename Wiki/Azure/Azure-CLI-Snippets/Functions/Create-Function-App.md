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
| Parameter | Required | Example Value | Description |
|--|--|--|--|
| FunctionAppName | <input type="checkbox" checked> | `azuretestapifunc$(Release.EnvironmentName)` | The name of the function app. It's recommended to stick to lowercase alphanumeric characters for this. |
| AppServicePlanName | <input type="checkbox" checked> | `Shared-ASP-$(Release.EnvironmentName)-Linux-1` | The AppService Plan name. Mandatory and and this may be an existing App service plan, Windows App services should use a different App Service Plan then Linux App services|
| AppServicePlanResourceGroupName | <input type="checkbox" checked> | `Shared-ASP-$(Release.EnvironmentName)-Linux` \ `Shared-ASP-$(Release.EnvironmentName)-Win` | The ResourceGroup name where the AppServicePlan resides in. |
| LogAnalyticsWorkspaceResourceId | <input type="checkbox" checked> | `/subscriptions/<subscriptionid>/resourceGroups/<resourcegroup>/providers/Microsoft.OperationalInsights/workspaces/<loganalyticsworkspacename>` | The log analytics workspace the appservice is using for writing its diagnostics settings) |
| FunctionAppResourceGroupName | <input type="checkbox" checked> | `MyTeam-TestApi-$(Release.EnvironmentName)` | The ResourceGroup where your desired Function App will reside in |
| FunctionAppStorageAccountName | <input type="checkbox" checked> | `azuretestapifunc$(Release.EnvironmentName)storage` | The name of the (pre-existing) storage account which will be the backend storage for this function app |
| FunctionAppAlwaysOn | <input type="checkbox" checked> | `true`/`false` | Let the function app run in always on mode (this doesn't work for consumption plan function apps) |
| FUNCTIONS_EXTENSION_VERSION | <input type="checkbox" checked> | `~3` | Choose `~2` voor v2 and `~3` for v3 of Function Apps (if you are unsure, use `~3`) |
| ASPNETCORE_ENVIRONMENT | <input type="checkbox" checked> | `Development` | Use either `Development`, `Acceptance` or `Production`. NOTE: `Development` and `Production` have features which are provided by the framework. [Read more here](https://docs.microsoft.com/en-us/aspnet/core/fundamentals/environments) |
| EnableFunctionAppDeploymentSlot | <input type="checkbox"> | | If you pass this switch (without value), a deployment slot will be created. |
| FunctionAppDeploymentSlotName | <input type="checkbox"> | `staging` | Name of the slot to create additional to the production slot. Has the default value of "staging". |
| DisablePublicAccessForFunctionAppDeploymentSlot | <input type="checkbox"> | `true` | The public access can be removed from the deployment slot. By default this has a value of true. |
| FunctionAppRuntime | <input type="checkbox"> | `dotnet` | The runtime you want your code to run in. By default this has a value of "dotnet". |
| FunctionAppNumberOfInstances | <input type="checkbox"> | `2` | OPTIONAL: You can define how much instances of your functions will be ran (use 2 or more for HA. use 1 if you have server side sessions/stateful apps). The default value (if you don't pass any value) will be 2. |
| FunctionAppOSType | <input type="checkbox" checked> | `Linux`\ `Windows` | The OS type of the function app. You can choose between 'Linux' or 'Windows'. |
| ForcePublic | <input type="checkbox"> | n.a. | If you are not using any networking settings, you need to pass this boolean to confirm you are willingly creating a public resource (to avoid unintended public resources). You can pass it as a switch without a value (`-ForcePublic`). |

# VNET Whitelisting Parameters

If you want to use "vnet whitelisting" on your resource. Use these parameters. Using VNET Whitelisting is the recommended way of building & connecting your application stack within Azure.

> NOTE: These parameters are only required when you want to use the VNet whitelisting feature for this resource.

| Parameter                    | Required for VNET Whitelisting  | Example Value                        | Description                                                              |
| ---------------------------- | ------------------------------- | ------------------------------------ | ------------------------------------------------------------------------ |
| GatewayVnetResourceGroupName | <input type="checkbox" checked> | `sharedservices-rg`                  | The ResourceGroup where your VNET, for your Gateway, resides in.         |
| GatewayVnetName              | <input type="checkbox" checked> | `my-vnet-$(Release.EnvironmentName)` | The name of the VNET the Gateway is in                                   |
| GatewaySubnetName            | <input type="checkbox" checked> | `app-subnet-4`                       | The name of the subnet the Gateway is in                                 |
| GatewayWhitelistRulePriority | <input type="checkbox" checked> | `20`                                 | The priority of the whitelist rule. Can be left blank. Defaults to `20`. |

# Private Endpoint Parameters

If you want to use private endpoints on your resource. Use these parameters. Private Endpoints are used for connecting to your Azure Resources from on-premises.

> NOTE: These parameters are only required when you want to use a private endpoint for this resource.

| Parameter                                       | Required for Pvt Endpoint       | Example Value                           | Description                                                                                                          |
| ----------------------------------------------- | ------------------------------- | --------------------------------------- | -------------------------------------------------------------------------------------------------------------------- |
| FunctionAppPrivateEndpointVnetName              | <input type="checkbox" checked> | `my-vnet-$(Release.EnvironmentName)`    | The name of the VNET to place the Function App Private Endpoint in.                                                  |
| FunctionAppPrivateEndpointVnetResourceGroupName | <input type="checkbox" checked> | `sharedservices-rg`                     | The ResourceGroup where your VNET, for your Function App Private Endpoint, resides in.                               |
| FunctionAppPrivateEndpointSubnetName            | <input type="checkbox" checked> | `app-subnet-3`                          | The subnet to place the private endpoint for this function app in                                                    |
| DNSZoneResourceGroupName                        | <input type="checkbox" checked> | `MyDNSZones-$(Release.EnvironmentName)` | Make sure to use the shared DNS Zone resource group (you can only register a zone once per subscription).            |
| FunctionAppPrivateDnsZoneName                   | <input type="checkbox" checked> | `privatelink.azurewebsites.net`         | The DNS Zone to use. If you are not sure, it's safe to use `privatelink.azurewebsites.net` as value for AppServices. |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
        - task: AzureCLI@2
           displayName: 'Create Function App'
           condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
           inputs:
               azureSubscription: '${{ parameters.SubscriptionName }}'
               scriptType: pscore
               scriptPath: '$(Pipeline.Workspace)/AzDocs/Functions/Create-Function-App.ps1'
               arguments: "-AppServicePlanName '$(AppServicePlanName)' -AppServicePlanResourceGroupName '$(AppServicePlanResourceGroupName)' -FunctionAppResourceGroupName '$(FunctionAppResourceGroupName)' -FunctionAppName '$(FunctionAppName)' -FunctionAppStorageAccountName '$(FunctionAppStorageAccountName)' -FunctionAppOSType '$(FunctionAppOSType)' -LogAnalyticsWorkspaceResourceId '$(LogAnalyticsWorkspaceResourceId)' -FunctionAppAlwaysOn $(FunctionAppAlwaysOn) -FUNCTIONS_EXTENSION_VERSION '$(FUNCTIONS_EXTENSION_VERSION)' -ASPNETCORE_ENVIRONMENT '$(ASPNETCORE_ENVIRONMENT)' -FunctionAppNumberOfInstances '$(FunctionAppNumberOfInstances)' -FunctionAppRuntime '$(FunctionAppRuntime)' -ResourceTags $(ResourceTags) -EnableFunctionAppDeploymentSlot -FunctionAppDeploymentSlotName '$(FunctionAppDeploymentSlotName)' -DisablePublicAccessForFunctionAppDeploymentSlot '$(DisablePublicAccessForFunctionAppDeploymentSlot)' -GatewayVnetResourceGroupName '$(GatewayVnetResourceGroupName)' -GatewayVnetName '$(GatewayVnetName)' -GatewaySubnetName '$(GatewaySubnetName)' -GatewayWhitelistRulePriority '$(GatewayWhitelistRulePriority)' -FunctionAppPrivateEndpointVnetResourceGroupName '$(FunctionAppPrivateEndpointVnetResourceGroupName)' -FunctionAppPrivateEndpointVnetName '$(FunctionAppPrivateEndpointVnetName)' -FunctionAppPrivateEndpointSubnetName '$(FunctionAppPrivateEndpointSubnetName)' -DNSZoneResourceGroupName '$(DNSZoneResourceGroupName)' -FunctionAppPrivateDnsZoneName '$(FunctionAppPrivateDnsZoneName)'"
```

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
