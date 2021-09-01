[[_TOC_]]

# Description

<font color="red">NOTE: This script is now legacy. Please use `Create-App-Service-Plan-Linux` & `Create-Web-App` instead of this task.</font>

This snippet will create an Web App if it does not exist & create an app service plan if it does not exist. It also adds the mandatory tags to the resources.

This script will call the following 2 scripts in order (please refer to those scripts for information):

[Create-App-Service-Plan-Linux](/Azure/Azure-CLI-Snippets/App-Services/Create-App-Service-Plan-Linux)
[Create-Web-App-Linux](/Azure/Azure-CLI-Snippets/App-Services/Create-Web-App-Linux)

# Parameters

Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.
| Parameter | Example Value | Description |
|--|--|--|
| AppServiceName | `azuretestapi-$(Release.EnvironmentName)` | The name of the webapp. It's recommended to stick to alphanumeric & hyphens for this. |
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
| ContainerImageName | `thelastpickle/cassandra-reaper:latest` | Docker hub Image name with optional tag. |
| AppServicePlanNumberOfWorkerInstances | `3` | OPTIONAL: The amount of worker instances you want for this appservice plan. For high availability, choose 2 or more. The default value (if you don't pass any value) will be 3. |
| AppServiceNumberOfInstances | `2` | OPTIONAL: You can define how much instances of your appservice will be ran (use 2 or more for HA. use 1 if you have server side sessions/stateful apps). The default value (if you don't pass any value) will be 2. |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Create Web App with App Service Plan Linux"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/App-Services/Create-Web-App-with-App-Service-Plan-Linux.ps1"
    arguments: "-AppServicePrivateEndpointVnetResourceGroupName '$(AppServicePrivateEndpointVnetResourceGroupName)' -AppServicePrivateEndpointVnetName '$(AppServicePrivateEndpointVnetName)' -AppServicePrivateEndpointSubnetName '$(AppServicePrivateEndpointSubnetName)' -AppServicePlanName '$(AppServicePlanName)' -AppServicePlanResourceGroupName '$(AppServicePlanResourceGroupName)' -AppServicePlanSkuName '$(AppServicePlanSkuName)' -ResourceTags $(ResourceTags) -AppServiceResourceGroupName '$(AppServiceResourceGroupName)' -AppServiceName '$(AppServiceName)' -AppServiceRunTime '$(AppServiceRunTime)' -LogAnalyticsWorkspaceResourceId '$(LogAnalyticsWorkspaceResourceId)' -DNSZoneResourceGroupName '$(DNSZoneResourceGroupName)' -AppServicePrivateDnsZoneName '$(AppServicePrivateDnsZoneName)' -AppServicePlanNumberOfWorkerInstances '$(AppServicePlanNumberOfWorkerInstances)' -AppServiceNumberOfInstances '$(AppServiceNumberOfInstances)' -EnableAppServiceDeploymentSlot -AppServiceDeploymentSlotName '$(AppServiceDeploymentSlotName)' -DisablePublicAccessForAppServiceDeploymentSlot $(DisablePublicAccessForAppServiceDeploymentSlot) -ContainerImageName '$(ContainerImageName)'"
```

# Code

The snippet for creating a webapp with linux and using the given runtime environment. This snippet will also create the app service plan if it does not exist (Linux is defined during the AppServiceplan creation). Note that there can be no Windows App Service Plans in the same resourcegroup.

[Click here to download this script](../../../../../src/App-Services/Create-Web-App-with-App-Service-Plan-Linux.ps1)
