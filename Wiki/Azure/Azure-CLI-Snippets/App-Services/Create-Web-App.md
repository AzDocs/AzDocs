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
| Parameter | Required Normal WebApp | Required Container | Example Value | Description |
|--|--|--|--|--|
| AppServiceName | <input type="checkbox" checked> | <input type="checkbox" checked> | `azuretestapi-$(Release.EnvironmentName)` | The name of the webapp. It's recommended to stick to alphanumeric & hyphens for this. |
| AppServicePlanName | <input type="checkbox" checked> | <input type="checkbox" checked> | `Shared-ASP-$(Release.EnvironmentName)-Win-1` \ `Shared-ASP-$(Release.EnvironmentName)-Linux` | The AppService Plan name. Mandatory and and this may be an existing App service plan, Windows App services should use a different App Service Plan then Linux App services. |
| LogAnalyticsWorkspaceResourceId | <input type="checkbox" checked> | <input type="checkbox" checked> | `/subscriptions/<subscriptionid>/resourceGroups/<resourcegroup>/providers/Microsoft.OperationalInsights/workspaces/<loganalyticsworkspacename>` | The log analytics workspace the appservice is using for writing its diagnostics settings). |
| AppServicePlanResourceGroupName | <input type="checkbox" checked> | <input type="checkbox" checked> | `Shared-ASP-$(Release.EnvironmentName)-Win` | The ResourceGroup name where the AppServicePlan resides in. |
| AppServiceResourceGroupName | <input type="checkbox" checked> | <input type="checkbox" checked> | `MyTeam-TestApi-$(Release.EnvironmentName)` | The ResourceGroup where your desired AppService will reside in |
| AppServiceRunTime | <input type="checkbox" checked> | <input type="checkbox"> | `'"DOTNETCORE|3.1"'` | The name of the runtime stack. Note: you need to encapsulate this value (even when you pass it as a variable) with a `' " <value> " '` (without spaces), which is needed to mitigate the parsing of the pipe character in this string. If you forget to do this, you will get an error about the runtime which could not be found. For a list of runtimes please use the `az webapp list-runtimes --linux` or `az webapp list-runtimes` for windows command [(Documentation here)](https://docs.microsoft.com/en-us/cli/azure/webapp?view=azure-cli-latest#az_webapp_list_runtimes). |
| AppServiceAlwaysOn | <input type="checkbox"> | <input type="checkbox"> | `true` | OPTIONAL: by default set to true. |
| AppServiceMinimalTlsVersion | <input type="checkbox"> | <input type="checkbox"> | `1.2` | Set the TLS Version for the app service. Defaults to 1.2 |
| ContainerImageName | <input type="checkbox"> | <input type="checkbox" checked> | `thelastpickle/cassandra-reaper:latest` | Docker hub Image name with optional tag. This can only be used if you use the Linux app service. |
| AppServiceNumberOfInstances | <input type="checkbox"> | <input type="checkbox"> | `2` | OPTIONAL: You can define how much instances of your appservice will be ran (use 2 or more for HA. use 1 if you have server side sessions/stateful apps). The default value (if you don't pass any value) will be 2. |
| EnableAppServiceDeploymentSlot | <input type="checkbox"> | <input type="checkbox"> | If you pass this switch (without value), a deployment slot will be created. |
| AppServiceDeploymentSlotName | <input type="checkbox"> | <input type="checkbox"> | `'staging'` | Name of the slot to create additional to the production slot. Has the default value of "staging". |
| DisablePublicAccessForAppServiceDeploymentSlot | <input type="checkbox"> | <input type="checkbox"> | `true` | The public access can be removed from the deployment slot. By default this has a value of true. |
| StopAppServiceImmediatelyAfterCreation | <input type="checkbox"> | <input type="checkbox"> | `$true`/`$false` | Stop the App Service directly after it is created. This is sometimes needed if you have containers which do database migrations, which don't have the correct appsettings yet. |
| StopAppServiceSlotImmediatelyAfterCreation | <input type="checkbox"> | <input type="checkbox"> | `$true`/`$false` | Stop the App Service Deploymentslot directly after it is created. This is sometimes needed if you have containers which do database migrations, which don't have the correct appsettings yet. |
| ForcePublic | <input type="checkbox"> | <input type="checkbox"> | n.a. | If you are not using any networking settings, you need to pass this boolean to confirm you are willingly creating a public resource (to avoid unintended public resources). You can pass it as a switch without a value (`-ForcePublic`). |

# VNET Whitelisting Parameters

If you want to use "vnet whitelisting" on your resource. Use these parameters. Using VNET Whitelisting is the recommended way of building & connecting your application stack within Azure.

> NOTE: These parameters are only required when you want to use the VNet whitelisting feature for this resource.

| Parameter                    | Required for VNet whitelisting  | Example Value                        | Description                                                              |
| ---------------------------- | ------------------------------- | ------------------------------------ | ------------------------------------------------------------------------ |
| GatewayVnetResourceGroupName | <input type="checkbox" checked> | `sharedservices-rg`                  | The ResourceGroup where your VNET, for your Gateway, resides in.         |
| GatewayVnetName              | <input type="checkbox" checked> | `my-vnet-$(Release.EnvironmentName)` | The name of the VNET the Gateway is in                                   |
| GatewaySubnetName            | <input type="checkbox" checked> | `app-subnet-4`                       | The name of the subnet the Gateway is in                                 |
| GatewayWhitelistRulePriority | <input type="checkbox">         | `20`                                 | The priority of the whitelist rule. Can be left blank. Defaults to `20`. |

# Private Endpoint Parameters

If you want to use private endpoints on your resource. Use these parameters. Private Endpoints are used for connecting to your Azure Resources from on-premises.

> NOTE: These parameters are only required when you want to use a private endpoint for this resource.

| Parameter                                      | Required for Pvt Endpoint       | Example Value                           | Description                                                                                                          |
| ---------------------------------------------- | ------------------------------- | --------------------------------------- | -------------------------------------------------------------------------------------------------------------------- |
| AppServicePrivateEndpointVnetName              | <input type="checkbox" checked> | `my-vnet-$(Release.EnvironmentName)`    | The name of the VNET to place the App Service Private Endpoint in.                                                   |
| AppServicePrivateEndpointVnetResourceGroupName | <input type="checkbox" checked> | `sharedservices-rg`                     | The ResourceGroup where your VNET, for your App Service Private Endpoint, resides in.                                |
| DNSZoneResourceGroupName                       | <input type="checkbox" checked> | `MyDNSZones-$(Release.EnvironmentName)` | Make sure to use the shared DNS Zone resource group (you can only register a zone once per subscription).            |
| AppServicePrivateDnsZoneName                   | <input type="checkbox" checked> | `privatelink.azurewebsites.net`         | The DNS Zone to use. If you are not sure, it's safe to use `privatelink.azurewebsites.net` as value for AppServices. |
| AppServicePrivateEndpointSubnetName            | <input type="checkbox" checked> | `app-subnet-3`                          | The subnet to place the private endpoint for this appservice in                                                      |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Create Web App"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/App-Services/Create-Web-App.ps1"
    arguments: "-AppServicePlanName '$(AppServicePlanName)' -AppServicePlanResourceGroupName '$(AppServicePlanResourceGroupName)' -AppServiceResourceGroupName '$(AppServiceResourceGroupName)' -AppServiceName '$(AppServiceName)' -LogAnalyticsWorkspaceResourceId '$(LogAnalyticsWorkspaceResourceId)' -AppServiceRunTime '$(AppServiceRunTime)' -AppServiceNumberOfInstances '$(AppServiceNumberOfInstances)' -ResourceTags $(ResourceTags) -AppServiceAlwaysOn $(AppServiceAlwaysOn) -EnableAppServiceDeploymentSlot -AppServiceDeploymentSlotName '$(AppServiceDeploymentSlotName)' -DisablePublicAccessForAppServiceDeploymentSlot $(DisablePublicAccessForAppServiceDeploymentSlot) -ContainerImageName '$(ContainerImageName)' -GatewayVnetResourceGroupName '$(GatewayVnetResourceGroupName)' -GatewayVnetName '$(GatewayVnetName)' -GatewaySubnetName '$(GatewaySubnetName)' -GatewayWhitelistRulePriority '$(GatewayWhitelistRulePriority)' -AppServicePrivateEndpointVnetResourceGroupName '$(AppServicePrivateEndpointVnetResourceGroupName)' -AppServicePrivateEndpointVnetName '$(AppServicePrivateEndpointVnetName)' -AppServicePrivateEndpointSubnetName '$(AppServicePrivateEndpointSubnetName)' -DNSZoneResourceGroupName '$(DNSZoneResourceGroupName)' -AppServicePrivateDnsZoneName '$(AppServicePrivateDnsZoneName)' -AppServiceMinimalTlsVersion '$(AppServiceMinimalTlsVersion)'"
```

# Code

The snippet for creating a webapp with linux and using the given runtime environment.

[Click here to download this script](../../../../src/App-Services/Create-Web-App-Linux.ps1)

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
- [Azure CLI - az webapp config](https://docs.microsoft.com/en-us/cli/azure/webapp/config?view=azure-cli-latest#az_webapp_config_set)
