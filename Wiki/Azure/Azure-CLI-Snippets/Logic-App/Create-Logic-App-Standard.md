[[_TOC_]]

# Description

This snippet will create a Logic App (Standard). This means that this Logic App is created within a specific Logic App AppService Plan.
The Logic App (Standard) is created based on the Azure Functions extensibility model, which means the cli commands used for the function app, will also be used for this resource.

The logic app is set to https only and the logic app cannot be deployed with ftp(s) for to be compliant with the azure policies.

This snippet also managed the following compliancy rules:

- HTTPS only
- Disable FTP
- Set Tags on this resource
- Set a Managed Identity for the logic app
- Adds a private endpoint to securely connect to this logic app
- Sets the network configuration to only allow the private endpoint connection or vnet integration

# Parameters

Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.
| Parameter | Required | Example Value | Description |
| ----------------------------------------------- | ------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| LogicAppName | <input type="checkbox" checked> | `azuretestlogicapp$(Release.EnvironmentName)` | The name of the logic app. It's recommended to stick to lowercase alphanumeric characters for this. |
| AppServicePlanName | <input type="checkbox" checked> | `Shared-ASP-$(Release.EnvironmentName)-Linux-1` | The AppService Plan name. This App Service Plan has to have one of the following SKUs: `WS1`, `WS2` and `WS3`. |
| AppServicePlanResourceGroupName | <input type="checkbox" checked> | `Shared-ASP-$(Release.EnvironmentName)-Linux` \ `Shared-ASP-$(Release.EnvironmentName)-Win` | The ResourceGroup name where the AppServicePlan resides in. |
| LogAnalyticsWorkspaceResourceId | <input type="checkbox" checked> | `/subscriptions/<subscriptionid>/resourceGroups/<resourcegroup>/providers/Microsoft.OperationalInsights/workspaces/<loganalyticsworkspacename>` | The log analytics workspace the Logic App is using for writing its diagnostics settings) |
| LogicAppResourceGroupName | <input type="checkbox" checked> | `MyTeam-TestApi-$(Release.EnvironmentName)` | The ResourceGroup where your desired Logic App will reside in |
| LogicAppStorageAccountName | <input type="checkbox" checked> | `azuretestlogicapp$(Release.EnvironmentName)storage` | The name of the (pre-existing) storage account which will be the backend storage for this logic app |
| LogicAppMinimalTlsVersion | <input type="checkbox"> | `1.2` | Set the TLS Version for the logic app. Defaults to 1.2 |
| ForcePublic | <input type="checkbox"> | n.a. | If you are not using any networking settings, you need to pass this boolean to confirm you are willingly creating a public resource (to avoid unintended public resources). You can pass it as a switch without a value (`-ForcePublic`). |
| StopLogicAppImmediatelyAfterCreation | <input type="checkbox"> | `$false` | Stop the function app immediately after creation. Defaults to false. |
| StopLogicAppSlotImmediatelyAfterCreation | <input type="checkbox"> | `$false` | Stop the function app slot immediately after creation. Defaults to false. |
| DiagnosticSettingsLogs | <input type="checkbox"> | `@('Requests';'MongoRequests';)` | If you want to enable a specific set of diagnostic settings for the category 'Logs'. By default, all categories for 'Logs' will be enabled. |
| DiagnosticSettingsMetrics | <input type="checkbox"> | `@('Requests';'MongoRequests';)` | If you want to enable a specific set of diagnostic settings for the category 'Metrics'. By default, all categories for 'Metrics' will be enabled. |
| DiagnosticSettingsDisabled | <input type="checkbox"> | n.a. | If you don't want to enable any diagnostic settings, you can pass this as a switch witout a value(`-DiagnosticsettingsDisabled`). |

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

| Parameter                                    | Required for Pvt Endpoint       | Example Value                           | Description                                                                                                          |
| -------------------------------------------- | ------------------------------- | --------------------------------------- | -------------------------------------------------------------------------------------------------------------------- |
| LogicAppPrivateEndpointVnetName              | <input type="checkbox" checked> | `my-vnet-$(Release.EnvironmentName)`    | The name of the VNET to place the Function App Private Endpoint in.                                                  |
| LogicAppPrivateEndpointVnetResourceGroupName | <input type="checkbox" checked> | `sharedservices-rg`                     | The ResourceGroup where your VNET, for your Function App Private Endpoint, resides in.                               |
| LogicAppPrivateEndpointSubnetName            | <input type="checkbox" checked> | `app-subnet-3`                          | The subnet to place the private endpoint for this function app in                                                    |
| DNSZoneResourceGroupName                     | <input type="checkbox" checked> | `MyDNSZones-$(Release.EnvironmentName)` | Make sure to use the shared DNS Zone resource group (you can only register a zone once per subscription).            |
| LogicAppPrivateDnsZoneName                   | <input type="checkbox" checked> | `privatelink.azurewebsites.net`         | The DNS Zone to use. If you are not sure, it's safe to use `privatelink.azurewebsites.net` as value for AppServices. |

_Note: When using Private Endpoints, make sure to add several private endpoints to the storage account for the different subresources the Logic App needs. These are Table, Queue, Blob and File storage. See https://docs.microsoft.com/en-us/azure/logic-apps/deploy-single-tenant-logic-apps-private-storage-account for more information._

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Create Logic App"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/Logic-App/Create-Logic-App-Standard.ps1"
    arguments: >
      -AppServicePlanName '$(AppServicePlanName)' 
      -AppServicePlanResourceGroupName '$(AppServicePlanResourceGroupName)' 
      -LogicAppResourceGroupName '$(LogicAppResourceGroupName)' 
      -LogicAppName '$(LogicAppName)' 
      -LogicAppStorageAccountName '$(LogicAppStorageAccountName)'
      -LogAnalyticsWorkspaceResourceId '$(LogAnalyticsWorkspaceResourceId)'
      -ResourceTags $(ResourceTags) 
      -GatewayVnetResourceGroupName '$(GatewayVnetResourceGroupName)' 
      -GatewayVnetName '$(GatewayVnetName)' 
      -GatewaySubnetName '$(GatewaySubnetName)' 
      -GatewayWhitelistRulePriority '$(GatewayWhitelistRulePriority)' 
      -LogicAppPrivateEndpointVnetResourceGroupName '$(LogicAppPrivateEndpointVnetResourceGroupName)' 
      -LogicAppPrivateEndpointVnetName '$(LogicAppPrivateEndpointVnetName)' 
      -LogicAppPrivateEndpointSubnetName '$(LogicAppPrivateEndpointSubnetName)' 
      -DNSZoneResourceGroupName '$(DNSZoneResourceGroupName)' 
      -LogicAppPrivateDnsZoneName '$(LogicAppPrivateDnsZoneName)' 
      -LogicAppMinimalTlsVersion '$(LogicAppMinimalTlsVersion)' 
      -StopLogicAppImmediatelyAfterCreation $(StopLogicAppImmediatelyAfterCreation) 
      -StopLogicAppSlotImmediatelyAfterCreation $(StopLogicAppSlotImmediatelyAfterCreation) 
      -DiagnosticSettingsLogs $(DiagnosticSettingsLogs) 
      -DiagnosticSettingsDisabled $(DiagnosticSettingsDisabled)
```

# Code

## Create Logic App

The snippet to create a Logic App.

[Click here to download this script](../../../../src/Logic-App/Create-Logic-App.ps1)

# Links

- [Azure CLI - az-logicapp-create](https://docs.microsoft.com/en-us/cli/azure/logicapp?view=azure-cli-latest#az-logicapp-create)
- [Azure CLI - az appservice plan show](https://docs.microsoft.com/en-us/cli/azure/appservice/plan?view=azure-cli-latest#az-appservice-plan-show)
- [Azure CLI - az-functionapp-identity-assign](https://docs.microsoft.com/en-us/cli/azure/functionapp/identity?view=azure-cli-latest#az-functionapp-identity-assign)
- [App Service Pricing for SKU's](https://azure.microsoft.com/nl-nl/pricing/details/app-service/windows/)
- [App Service Create Diagnostics settings](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/diagnostic-settings)
- [App Service Az Monitor Diagnostics settings](https://docs.microsoft.com/en-us/cli/azure/monitor/diagnostic-settings?view=azure-cli-latest#az-monitor-diagnostic-settings-update)
- [App Service Enable Diagnostics Logging](https://docs.microsoft.com/en-us/azure/app-service/troubleshoot-diagnostic-logs)
- [Template settings for Diagnostics settings](https://docs.microsoft.com/en-us/azure/azure-monitor/samples/resource-manager-diagnostic-settings)
- [Azure Cli for Diagnostics settings](http://techgenix.com/azure-diagnostic-settings/)
