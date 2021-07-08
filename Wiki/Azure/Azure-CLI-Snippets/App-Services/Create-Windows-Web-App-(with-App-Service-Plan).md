[[_TOC_]]

# Description

<font color="red">NOTE: This script is now legacy. Please use `Create-App-Service-Plan-Windows` & `Create-Web-App-Windows` instead of this task.</font>

This snippet will create an Web App if it does not exist & create an app service plan if it does not exist. It also adds the mandatory tags to the resources.

This script will call the following 2 scripts in order (please refer to those scripts for information):

[Create-App-Service-Plan-Windows](/Azure/Azure-CLI-Snippets/App-Services/Create-App-Service-Plan-Windows)
[Create-Web-App-Windows](/Azure/Azure-CLI-Snippets/App-Services/Create-Web-App-Windows)

# Parameters

Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.
| Parameter | Example Value | Description |
|--|--|--|
| AppServiceName | `azuretestapi-$(Release.EnvironmentName)` | The name of the webapp. It's recommended to stick to alphanumeric & hyphens for this. |
| AppServiceDiagnosticsName | `azuretestapi-$(Release.EnvironmentName)` | This name will be used as an identifier in the log analytics workspace. It is recommended to use your Application Insights name for this parameter. |
| AppServicePlanName | `Shared-ASP-$(Release.EnvironmentName)-Win-1` | The AppService Plan name. Mandatory and and this may be an existing App service plan, Windows App services should use a different App Service Plan then Linux App services|
| AppServicePlanSkuName | `S1` | The pricing tier that is going to be used. A list can be found here: [App Service Pricing for SKU's](https://azure.microsoft.com/nl-nl/pricing/details/app-service/windows/) |
| LogAnalyticsWorkspaceResourceId | `/subscriptions/<subscriptionid>/resourceGroups/<resourcegroup>/providers/Microsoft.OperationalInsights/workspaces/<loganalyticsworkspacename>` | The log analytics workspace the appservice is using for writing its diagnostics settings) |
| AppServicePrivateEndpointSubnetName | `app-subnet-3` | The subnet to place the private endpoint for this appservice in
| AppServicePlanResourceGroupName | `Shared-ASP-$(Release.EnvironmentName)-Win` | The ResourceGroup name where the AppServicePlan resides in.
| DNSZoneResourceGroupName | `MyDNSZones-$(Release.EnvironmentName)` | Make sure to use the shared DNS Zone resource group (you can only register a zone once per subscription). |
| AppServicePrivateDnsZoneName | `privatelink.azurewebsites.net` | The DNS Zone to use. If you are not sure, it's safe to use `privatelink.azurewebsites.net` as value for AppServices.
| AppServiceResourceGroupName| `MyTeam-TestApi-$(Release.EnvironmentName)` | The ResourceGroup where your desired AppService will reside in |
| EnableAppServiceDeploymentSlot | If you pass this switch (without value), a deployment slot will be created. |
| AppServiceDeploymentSlotName | `'staging'` | Name of the slot to create additional to the production slot. Has the default value of "staging". |
| DisablePublicAccessForAppServiceDeploymentSlot | `true` | The public access can be removed from the deployment slot. By default this has a value of true. |  
| AppServicePrivateEndpointVnetName | `my-vnet-$(Release.EnvironmentName)` | The name of the VNET to place the App Service Private Endpoint in. |
| AppServicePrivateEndpointVnetResourceGroupName | `sharedservices-rg` | The ResourceGroup where your VNET, for your App Service Private Endpoint, resides in. |
| AppServicePlanNumberOfWorkerInstances | `3` | OPTIONAL: The amount of worker instances you want for this appservice plan. For high availability, choose 2 or more. The default value (if you don't pass any value) will be 3. |
| AppServiceNumberOfInstances | `2` | OPTIONAL: You can define how much instances of your appservice will be ran (use 2 or more for HA. use 1 if you have server side sessions/stateful apps). The default value (if you don't pass any value) will be 2. |

# YAML

```yaml
        - task: AzureCLI@2
           displayName: 'Create Web App with App Service Plan Windows'
           condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
           inputs:
               azureSubscription: '${{ parameters.SubscriptionName }}'
               scriptType: pscore
               scriptPath: '$(Pipeline.Workspace)/AzDocs/App-Services/Create-Web-App-with-App-Service-Plan-Windows.ps1'
               arguments: "-AppServicePrivateEndpointVnetResourceGroupName '$(AppServicePrivateEndpointVnetResourceGroupName)' -AppServicePrivateEndpointVnetName '$(AppServicePrivateEndpointVnetName)' -AppServicePrivateEndpointSubnetName '$(AppServicePrivateEndpointSubnetName)' -AppServicePlanName '$(AppServicePlanName)' -AppServicePlanResourceGroupName '$(AppServicePlanResourceGroupName)' -AppServicePlanSkuName '$(AppServicePlanSkuName)' -ResourceTags $(ResourceTags) -AppServiceResourceGroupName '$(AppServiceResourceGroupName)' -AppServiceName '$(AppServiceName)' -AppServiceDiagnosticsName '$(AppServiceDiagnosticsName)' -LogAnalyticsWorkspaceResourceId '$(LogAnalyticsWorkspaceResourceId)' -DNSZoneResourceGroupName '$(DNSZoneResourceGroupName)' -AppServicePrivateDnsZoneName '$(AppServicePrivateDnsZoneName)' -AppServiceRunTime '$(AppServiceRunTime)' -AppServicePlanNumberOfWorkerInstances '$(AppServicePlanNumberOfWorkerInstances)' -AppServiceNumberOfInstances '$(AppServiceNumberOfInstances)' -EnableAppServiceDeploymentSlot '$(EnableAppServiceDeploymentSlot)' -AppServiceDeploymentSlotName '$(AppServiceDeploymentSlotName)' -DisablePublicAccessForAppServiceDeploymentSlot '$(DisablePublicAccessForAppServiceDeploymentSlot)'"
```

# Code

The snippet to create a Windows WebApp & ASP. Note that there can be no Linux App Service Plans in the same resourcegroup. This snippet will also create the app service plan if it does not exist.

[Click here to download this script](../../../../src/App-Services/Create-Web-App-with-App-Service-Plan-Windows.ps1)
