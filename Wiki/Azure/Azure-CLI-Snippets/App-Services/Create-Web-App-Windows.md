[[_TOC_]]

# Description

This snippet will create an Web App if it does not exist. It also adds the mandatory tags to the resources.

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
| Parameter | Required | Example Value | Description |
|--|--|--|--|
| AppServiceName | <input type="checkbox" checked> | `azuretestapi-$(Release.EnvironmentName)` | The name of the webapp. It's recommended to stick to alphanumeric & hyphens for this. |
| AppServiceDiagnosticsName | <input type="checkbox" checked> | `azuretestapi-$(Release.EnvironmentName)` | This name will be used as an identifier in the log analytics workspace. It is recommended to use your Application Insights name for this parameter. |
| AppServicePlanName | <input type="checkbox" checked> | `Shared-ASP-$(Release.EnvironmentName)-Win-1` | The AppService Plan name. Mandatory and and this may be an existing App service plan, Windows App services should use a different App Service Plan then Linux App services|
| LogAnalyticsWorkspaceResourceId | <input type="checkbox" checked> | `/subscriptions/<subscriptionid>/resourceGroups/<resourcegroup>/providers/Microsoft.OperationalInsights/workspaces/<loganalyticsworkspacename>` | The log analytics workspace the appservice is using for writing its diagnostics settings) |
| AppServicePlanResourceGroupName | <input type="checkbox" checked> | `Shared-ASP-$(Release.EnvironmentName)-Win` | The ResourceGroup name where the AppServicePlan resides in.
| AppServiceResourceGroupName| <input type="checkbox" checked> | `MyTeam-TestApi-$(Release.EnvironmentName)` | The ResourceGroup where your desired AppService will reside in |
| EnableAppServiceDeploymentSlot | <input type="checkbox"> | | If you pass this switch (without value), a deployment slot will be created. |
| AppServiceDeploymentSlotName | <input type="checkbox"> | `'staging'` | Name of the slot to create additional to the production slot. Has the default value of "staging". |
| DisablePublicAccessForAppServiceDeploymentSlot | <input type="checkbox"> | `true` | The public access can be removed from the deployment slot. By default this has a value of true. |  
| AppServiceNumberOfInstances | <input type="checkbox"> | `2` | OPTIONAL: You can define how much instances of your appservice will be ran (use 2 or more for HA. use 1 if you have server side sessions/stateful apps). The default value (if you don't pass any value) will be 2. |
| AppServiceAlwaysOn | <input type="checkbox"> | <input type="checkbox"> | `true` | OPTIONAL: by default set to true. |

# VNET Whitelisting Parameters

If you want to use "VNet whitelisting" on your resource. Use these parameters. Using VNET Whitelisting is the recommended way of building & connecting your application stack within Azure.

> NOTE: These parameters are only required when you want to use the VNet whitelisting feature for this resource.
> | Parameter | Required for VNet whitelisting | Example Value | Description |
> |--|--|--|--|
> | GatewayVnetResourceGroupName | <input type="checkbox" checked> | `sharedservices-rg` | The ResourceGroup where your VNET, for your Gateway, resides in. |
> | GatewayVnetName | <input type="checkbox" checked> | `my-vnet-$(Release.EnvironmentName)` | The name of the VNET the Gateway is in|
> | GatewaySubnetName | <input type="checkbox" checked> | `app-subnet-4` | The name of the subnet the Gateway is in |
> | GatewayWhitelistRulePriority | <input type="checkbox" checked> | `20` | The priority of the whitelist rule. Can be left blank. Defaults to `20`. |

# Private Endpoint Parameters

If you want to use private endpoints on your resource. Use these parameters. Private Endpoints are used for connecting to your Azure Resources from on-premises.

> NOTE: These parameters are only required when you want to use a private endpoint for this resource.
> | Parameter | Required for Pvt Endpoint | Example Value | Description |
> |--|--|--|--|
> | AppServicePrivateEndpointSubnetName | <input type="checkbox" checked> | `app-subnet-3` | The subnet to place the private endpoint for this appservice in
> | DNSZoneResourceGroupName | <input type="checkbox" checked> | `MyDNSZones-$(Release.EnvironmentName)` | Make sure to use the shared DNS Zone resource group (you can only register a zone once per subscription). |
> | AppServicePrivateDnsZoneName | <input type="checkbox" checked> | `privatelink.azurewebsites.net` | The DNS Zone to use. If you are not sure, it's safe to use `privatelink.azurewebsites.net` as value for AppServices.
> | AppServicePrivateEndpointVnetName | <input type="checkbox" checked> | `my-vnet-$(Release.EnvironmentName)` | The name of the VNET to place the App Service Private Endpoint in. |
> | AppServicePrivateEndpointVnetResourceGroupName | <input type="checkbox" checked> | `sharedservices-rg` | The ResourceGroup where your VNET, for your App Service Private Endpoint, resides in. |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
        - task: AzureCLI@2
           displayName: 'Create Web App Windows'
           condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
           inputs:
               azureSubscription: '${{ parameters.SubscriptionName }}'
               scriptType: pscore
               scriptPath: '$(Pipeline.Workspace)/AzDocs/App-Services/Create-Web-App-Windows.ps1'
               arguments: "-AppServicePlanName '$(AppServicePlanName)' -AppServicePlanResourceGroupName '$(AppServicePlanResourceGroupName)' -AppServiceResourceGroupName '$(AppServiceResourceGroupName)' -AppServiceName '$(AppServiceName)' -AppServiceDiagnosticsName '$(AppServiceDiagnosticsName)' -LogAnalyticsWorkspaceResourceId '$(LogAnalyticsWorkspaceResourceId)' -AppServiceRunTime '$(AppServiceRunTime)' -AppServiceNumberOfInstances '$(AppServiceNumberOfInstances)' -ResourceTags $(ResourceTags) -AppServiceAlwaysOn $(AppServiceAlwaysOn) -EnableAppServiceDeploymentSlot -AppServiceDeploymentSlotName '$(AppServiceDeploymentSlotName)' -DisablePublicAccessForAppServiceDeploymentSlot '$(DisablePublicAccessForAppServiceDeploymentSlot)' -GatewayVnetResourceGroupName '$(GatewayVnetResourceGroupName)' -GatewayVnetName '$(GatewayVnetName)' -GatewaySubnetName '$(GatewaySubnetName)' -GatewayWhitelistRulePriority '$(GatewayWhitelistRulePriority)' -AppServicePrivateEndpointVnetResourceGroupName '$(AppServicePrivateEndpointVnetResourceGroupName)' -AppServicePrivateEndpointVnetName '$(AppServicePrivateEndpointVnetName)' -AppServicePrivateEndpointSubnetName '$(AppServicePrivateEndpointSubnetName)' -DNSZoneResourceGroupName '$(DNSZoneResourceGroupName)' -AppServicePrivateDnsZoneName '$(AppServicePrivateDnsZoneName)'"
```

# Code

The snippet to create a Windows WebApp.

[Click here to download this script](../../../../src/App-Services/Create-Web-App-with-App-Service-Plan-Windows.ps1)

# Links

- [Azure CLI - az webapp create](https://docs.microsoft.com/en-us/cli/azure/webapp?view=azure-cli-latest#az-webapp-create)
- [Azure CLI - az webapp identity](https://docs.microsoft.com/en-us/cli/azure/webapp/identity?view=azure-cli-latest)
- [Azure CLI - az appservice plan show](https://docs.microsoft.com/en-us/cli/azure/appservice/plan?view=azure-cli-latest#az_appservice_plan_show)
- [App Service Create Diagnostics settings](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/diagnostic-settings)
- [App Service Az Monitor Diagnostics settings](https://docs.microsoft.com/en-us/cli/azure/monitor/diagnostic-settings?view=azure-cli-latest#az-monitor-diagnostic-settings-update)
- [App Service Enable Diagnostics Logging](https://docs.microsoft.com/en-us/azure/app-service/troubleshoot-diagnostic-logs)
- [Template settings for Diagnostics settings](https://docs.microsoft.com/en-us/azure/azure-monitor/samples/resource-manager-diagnostic-settings)
- [Azure CLI for Diagnostics settings](http://techgenix.com/azure-diagnostic-settings/)
- [Azure CLI - az webapp deployment slot create](https://docs.microsoft.com/en-us/cli/azure/webapp/deployment/slot?view=azure-cli-latest#az_webapp_deployment_slot_create)
