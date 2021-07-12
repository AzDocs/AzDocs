[[_TOC_]]

# Description

This snippet will create a appconfiguration if it does not exist within a given (existing) subnet. It will also make sure that public access is denied by default. All the needed components (private endpoint, service endpoint etc) will be created too.

This snippet also managed the following compliancy rules:

- Enable Diagnostic settings
- Use private endpoint
- block access from the internet
- Assign system managed identity

# Parameters

Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.

| Parameter                                     | Example Value                                                                                                                                   | Description                                                                                                                                                    |
| --------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ApplicationSubnetName                         | `app-subnet-3`                                                                                                                                  | The subnetname for the subnet to set the service endpoint on (this will allow the application to connect over the private endpoint within the azure backbone). |
| DNSZoneResourceGroupName                      | `MyDNSZones-$(Release.EnvironmentName)`                                                                                                         | ResourceGroupName for DNS Zones                                                                                                                                |
| AppConfigPrivateDnsZoneName                   | `privatelink.azconfig.io`                                                                                                                       | Generally this will be `privatelink.azconfig.io`. This defines which DNS Zone to use for the private app configuration endpoint.                               |
| AppConfigDiagnosticsName                      | `myappconfig-$(Release.EnvironmentName)`                                                                                                        | This name will be used as an identifier in the log analytics workspace. It is recommended to use your Application Insights name for this parameter.            |
| AppConfigName                                 | `myappconfig-$(Release.EnvironmentName)`                                                                                                        | This is the app configuration name to use.                                                                                                                     |
| AppConfigPrivateEndpointSubnetName            | `app-subnet-3`                                                                                                                                  | The name of the subnet where the app configurations private endpoint will reside in.                                                                           |
| LogAnalyticsWorkspaceName                     | `/subscriptions/<subscriptionid>/resourceGroups/<resourcegroup>/providers/Microsoft.OperationalInsights/workspaces/<loganalyticsworkspacename>` | The name of the Log Analytics Workspace for the diagnostics settings of the app configuration.                                                                 |
| AppConfigResourceGroup                        | `MyTeam-TestApi-$(Release.EnvironmentName)`                                                                                                     | The ResourceGroup where your app configuration will reside in.                                                                                                 |
| AppConfigPrivateEndpointVnetName              | `my-vnet-$(Release.EnvironmentName)`                                                                                                            | The name of the VNET to use for creating the App Config private endpoint in.                                                                                   |
| AppConfigPrivateEndpointVnetResourceGroupName | `sharedservices-rg`                                                                                                                             | The ResourceGroup where the AppConfig PrivateEndpoint VNET resides in.                                                                                         |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
        - task: AzureCLI@2
           displayName: 'Create App Configuration'
           condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
           inputs:
               azureSubscription: '${{ parameters.SubscriptionName }}'
               scriptType: pscore
               scriptPath: '$(Pipeline.Workspace)/AzDocs/App-Configuration/Create-App-Configuration.ps1'
               arguments: "-AppConfigPrivateEndpointVnetResourceGroupName '$(AppConfigPrivateEndpointVnetResourceGroupName)' -AppConfigPrivateEndpointVnetName '$(AppConfigPrivateEndpointVnetName)' -AppConfigPrivateEndpointSubnetName '$(AppConfigPrivateEndpointSubnetName)' -ApplicationSubnetName '$(ApplicationSubnetName)' -AppConfigName '$(AppConfigName)' -AppConfigLocation '$(AppConfigLocation)' -AppConfigResourceGroupName '$(AppConfigResourceGroupName)' -AppConfigDiagnosticsName '$(AppConfigDiagnosticsName)' -LogAnalyticsWorkspaceName '$(LogAnalyticsWorkspaceName)' -DNSZoneResourceGroupName '$(DNSZoneResourceGroupName)' -AppConfigPrivateDnsZoneName '$(AppConfigPrivateDnsZoneName)'"
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
