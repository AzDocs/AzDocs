[[_TOC_]]

# Description

<font color="red">NOTE: This script is now legacy. Please use `App-Services/Create-App-Service-Plan-Linux` & `Create-Function-App` instead of this task.</font>

This snippet will create an Function App if it does not exist & create an app service plan if it does not exist. It also adds the mandatory tags to the resources.

This script will call the following 2 scripts in order (please refer to those scripts for information):

[Create-App-Service-Plan-Linux](/Azure/Azure-CLI-Snippets/App-Services/Create-App-Service-Plan-Linux)
[Create-Function-App-Linux](/Azure/Azure-CLI-Snippets/Functions/Create-Function-App-Linux)

# Parameters

Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.
| Parameter | Example Value | Description |
|--|--|--|
| FunctionAppName | `azuretestapifunc$(Release.EnvironmentName)` | The name of the function app. It's recommended to stick to lowercase alphanumeric characters for this. |
| AppServicePlanName | `Shared-ASP-$(Release.EnvironmentName)-Linux-1` | The AppService Plan name. Mandatory and and this may be an existing App service plan, Windows App services should use a different App Service Plan then Linux App services|
| AppServicePlanSkuName | `S1` | The pricing tier that is going to be used. A list can be found here: [App Service Pricing for SKU's](https://azure.microsoft.com/nl-nl/pricing/details/app-service/windows/) |
| FunctionAppPrivateEndpointSubnetName | `app-subnet-3` | The subnet to place the private endpoint for this function app in |
| AppServicePlanResourceGroupName | `Shared-ASP-$(Release.EnvironmentName)-Linux` | The ResourceGroup name where the AppServicePlan resides in. |
| LogAnalyticsWorkspaceResourceId | `/subscriptions/<subscriptionid>/resourceGroups/<resourcegroup>/providers/Microsoft.OperationalInsights/workspaces/<loganalyticsworkspacename>` | The log analytics workspace the appservice is using for writing its diagnostics settings) |
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
| AppServicePlanNumberOfWorkerInstances | `3` | OPTIONAL: The amount of worker instances you want for this appservice plan. For high availability, choose 2 or more. The default value (if you don't pass any value) will be 3. |
| FunctionAppNumberOfInstances | `2` | OPTIONAL: You can define how much instances of your functions will be ran (use 2 or more for HA. use 1 if you have server side sessions/stateful apps). The default value (if you don't pass any value) will be 2. |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Create Function App with App Service Plan Linux"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/Functions/Create-Function-App-with-App-Service-Plan-Linux.ps1"
    arguments: "-FunctionAppPrivateEndpointVnetResourceGroupName '$(FunctionAppPrivateEndpointVnetResourceGroupName)' -FunctionAppPrivateEndpointVnetName '$(FunctionAppPrivateEndpointVnetName)' -FunctionAppPrivateEndpointSubnetName '$(FunctionAppPrivateEndpointSubnetName)' -AppServicePlanName '$(AppServicePlanName)' -AppServicePlanResourceGroupName '$(AppServicePlanResourceGroupName)' -AppServicePlanSkuName '$(AppServicePlanSkuName)' -ResourceTags $(ResourceTags) -FunctionAppResourceGroupName '$(FunctionAppResourceGroupName)' -FunctionAppName '$(FunctionAppName)' -FunctionAppStorageAccountName '$(FunctionAppStorageAccountName)' -LogAnalyticsWorkspaceResourceId '$(LogAnalyticsWorkspaceResourceId)' -DNSZoneResourceGroupName '$(DNSZoneResourceGroupName)' -FunctionAppPrivateDnsZoneName '$(FunctionAppPrivateDnsZoneName)' -FunctionAppAlwaysOn $(FunctionAppAlwaysOn) -FUNCTIONS_EXTENSION_VERSION '$(FUNCTIONS_EXTENSION_VERSION)' -ASPNETCORE_ENVIRONMENT '$(ASPNETCORE_ENVIRONMENT)' -EnableFunctionAppDeploymentSlot -FunctionAppDeploymentSlotName '$(FunctionAppDeploymentSlotName)' -DisablePublicAccessForFunctionAppDeploymentSlot $(DisablePublicAccessForFunctionAppDeploymentSlot) -AppServicePlanNumberOfWorkerInstances '$(AppServicePlanNumberOfWorkerInstances)' -FunctionAppNumberOfInstances '$(FunctionAppNumberOfInstances)'"
```

# Code

## Create Linux FunctionApp

The snippet to create a Linux Function App & ASP. Note that there can be no Windows App Service Plan in the same resourcegroup. This snippet will also create the app service plan if it does not exist.

[Click here to download this script](../../../../src/Functions/Create-Function-App-with-App-Service-Plan-Linux.ps1)
