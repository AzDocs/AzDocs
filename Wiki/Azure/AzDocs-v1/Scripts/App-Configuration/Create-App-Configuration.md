[[_TOC_]]

# Description

This snippet will create a appconfiguration if it does not exist within a given (existing) subnet. It will also make sure that public access is denied by default. All the needed components (private endpoint, service endpoint etc) will be created too.

This snippet also managed the following compliancy rules:

- Enable Diagnostic settings
- Use private endpoint
- block access from the internet
- Assign system managed identity

# Parameters

Some parameters from [General Parameter](/Azure/AzDocs-v1/Scripts) list.

| Parameter                                     | Required                        | Example Value                                                                                                                                   | Description                                                                                                                                                                                                                               |
| --------------------------------------------- | ------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| DNSZoneResourceGroupName                      | <input type="checkbox" checked> | `MyDNSZones-$(Release.EnvironmentName)`                                                                                                         | ResourceGroupName for DNS Zones                                                                                                                                                                                                           |
| AppConfigPrivateDnsZoneName                   | <input type="checkbox">         | `privatelink.azconfig.io`                                                                                                                       | Generally this will be `privatelink.azconfig.io`. This defines which DNS Zone to use for the private app configuration endpoint.                                                                                                          |
| AppConfigName                                 | <input type="checkbox" checked> | `myappconfig-$(Release.EnvironmentName)`                                                                                                        | This is the app configuration name to use.                                                                                                                                                                                                |
| AppConfigPrivateEndpointSubnetName            | <input type="checkbox" checked> | `app-subnet-3`                                                                                                                                  | The name of the subnet where the app configurations private endpoint will reside in.                                                                                                                                                      |
| LogAnalyticsWorkspaceResourceId               | <input type="checkbox">         | `/subscriptions/<subscriptionid>/resourceGroups/<resourcegroup>/providers/Microsoft.OperationalInsights/workspaces/<loganalyticsworkspacename>` | The name of the Log Analytics Workspace for the diagnostics settings of the app configuration.                                                                                                                                            |
| AppConfigResourceGroupName                    | <input type="checkbox" checked> | `MyTeam-TestApi-$(Release.EnvironmentName)`                                                                                                     | The ResourceGroup where your app configuration will reside in.                                                                                                                                                                            |
| AppConfigPrivateEndpointVnetName              | <input type="checkbox" checked> | `my-vnet-$(Release.EnvironmentName)`                                                                                                            | The name of the VNET to use for creating the App Config private endpoint in.                                                                                                                                                              |
| AppConfigPrivateEndpointVnetResourceGroupName | <input type="checkbox" checked> | `sharedservices-rg`                                                                                                                             | The ResourceGroup where the AppConfig PrivateEndpoint VNET resides in.                                                                                                                                                                    |
| AppConfigSku                                  | <input type="checkbox">         | `Standard`                                                                                                                                      | The tier to choose for the app configuration. 'Free' or 'Standard' can be used.                                                                                                                                                           |
| AppConfigAllowPublicAccess                    | <input type="checkbox">         | `true`/`false`                                                                                                                                  | If the app configuration is publicly accessible. Has a standard value of `false`.                                                                                                                                                         |
| ForcePublic                                   | <input type="checkbox">         | n.a.                                                                                                                                            | If you are not using any networking settings, you need to pass this boolean to confirm you are willingly creating a public resource (to avoid unintended public resources). You can pass it as a switch without a value (`-ForcePublic`). |
| DiagnosticSettingsLogs                        | <input type="checkbox">         | `@('Requests';'MongoRequests';)`                                                                                                                | If you want to enable a specific set of diagnostic settings for the category 'Logs'. By default, all categories for 'Logs' will be enabled.                                                                                               |
| DiagnosticSettingsMetrics                     | <input type="checkbox">         | `@('Requests';'MongoRequests';)`                                                                                                                | If you want to enable a specific set of diagnostic settings for the category 'Metrics'. By default, all categories for 'Metrics' will be enabled.                                                                                         |
| DiagnosticSettingsDisabled                    | <input type="checkbox">         | n.a.                                                                                                                                            | If you don't want to enable any diagnostic settings, you can pass this as a switch witout a value(`-DiagnosticsettingsDisabled`).                                                                                                         |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Create App Configuration"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/App-Configuration/Create-App-Configuration.ps1"
    arguments: "-AppConfigPrivateEndpointVnetResourceGroupName '$(AppConfigPrivateEndpointVnetResourceGroupName)' -AppConfigPrivateEndpointVnetName '$(AppConfigPrivateEndpointVnetName)' -AppConfigPrivateEndpointSubnetName '$(AppConfigPrivateEndpointSubnetName)' -AppConfigName '$(AppConfigName)' -AppConfigLocation '$(AppConfigLocation)' -AppConfigResourceGroupName '$(AppConfigResourceGroupName)' -LogAnalyticsWorkspaceResourceId '$(LogAnalyticsWorkspaceResourceId)' -DNSZoneResourceGroupName '$(DNSZoneResourceGroupName)' -AppConfigPrivateDnsZoneName '$(AppConfigPrivateDnsZoneName)' -AppConfigSku '$(AppConfigSku)' -AppConfigAllowPublicAccess $(AppConfigAllowPublicAccess)" -DiagnosticSettingsLogs $(DiagnosticSettingsLogs) -DiagnosticSettingsMetrics $(DiagnosticSettingsMetrics)
```

# Code

[Click here to download this script](../../../../src/App-Configuration/Create-App-Configuration.ps1)

# Links

[Azure CLI - az appconfig create](https://docs.microsoft.com/en-us/cli/azure/appconfig?view=azure-cli-latest#az_appconfig_create)

[Azure CLI - az-network-vnet-subnet-update](https://docs.microsoft.com/en-us/cli/azure/network/vnet/subnet?view=azure-cli-latest#az-network-vnet-subnet-update)

[Azure CLI - az appconfig show](https://docs.microsoft.com/en-us/cli/azure/appconfig?view=azure-cli-latest#az_appconfig_show)

[Azure CLI - az-network-private-endpoint-create](https://docs.microsoft.com/en-us/cli/azure/network/private-endpoint?view=azure-cli-latest#az-network-private-endpoint-create)

[Azure CLI - az-network-private-dns-zone-show](https://docs.microsoft.com/en-us/cli/azure/ext/privatedns/network/private-dns/zone?view=azure-cli-latest#ext-privatedns-az-network-private-dns-zone-show)

[Azure CLI - az-network-private-dns-zone-create](https://docs.microsoft.com/en-us/cli/azure/ext/privatedns/network/private-dns/zone?view=azure-cli-latest#ext-privatedns-az-network-private-dns-zone-create)

[Azure CLI - az-network-private-dns-link-vnet-show](https://docs.microsoft.com/en-us/cli/azure/network/private-dns/link/vnet?view=azure-cli-latest#az-network-private-dns-link-vnet-show)

[Azure CLI - az-network-private-dns-link-vnet-create](https://docs.microsoft.com/en-us/cli/azure/network/private-dns/link/vnet?view=azure-cli-latest#az-network-private-dns-link-vnet-create)

[Azure CLI - az-network-private-endpoint-dns-zone-group-create](https://docs.microsoft.com/en-us/cli/azure/network/private-endpoint/dns-zone-group?view=azure-cli-latest#az-network-private-endpoint-dns-zone-group-create)

[Azure CLI - az-network-vnet-subnet-show](https://docs.microsoft.com/en-us/cli/azure/network/vnet/subnet?view=azure-cli-latest#az-network-vnet-subnet-show)

[Azure CLI - az-network-private-link-resource-list](https://docs.microsoft.com/en-us/cli/azure/network/private-link-resource?view=azure-cli-latest#az-network-private-link-resource-list)

[Azure CLI - az appconfig identity assign](https://docs.microsoft.com/en-us/cli/azure/appconfig/identity?view=azure-cli-latest#az_appconfig_identity_assign)

[Azure CLI - az appconfig update](https://docs.microsoft.com/en-us/cli/azure/appconfig?view=azure-cli-latest#az_appconfig_update)

[Create Diagnostics settings](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/diagnostic-settings)

[Azure CLI - Create Diagnostics settings](http://techgenix.com/azure-diagnostic-settings/)

[Azure CLI - App Configuration Tier](https://azure.microsoft.com/en-us/pricing/details/app-configuration/)
