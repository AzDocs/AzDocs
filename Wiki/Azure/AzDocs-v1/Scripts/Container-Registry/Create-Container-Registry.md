[[_TOC_]]

# Description

This snippet will create an Azure Container Instances instance for you. It will be integrated into the given subnet.
Adding VNet whitelisting is only possible for Container Registries with Premium tier.

# Parameters

Some parameters from [General Parameter](/Azure/AzDocs-v1/Scripts) list.

| Parameter                          | Required                        | Example Value                                                                                                                                   | Description                                                                                                                                                                                                                               |
| ---------------------------------- | ------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ContainerRegistryName              | <input type="checkbox" checked> | `customershared$(Release.EnvironmentName)`                                                                                                      | The name of the container registry.                                                                                                                                                                                                       |
| ContainerRegistryResourceGroupName | <input type="checkbox" checked> | `Customer-Shared-$(Release.EnvironmentName)`                                                                                                    | The resourcegroup where the container registry should be.                                                                                                                                                                                 |
| ContainerRegistrySku               | <input type="checkbox">         | `Premium`                                                                                                                                       | The sku for this registry. Note that for networking options other than "public" you will need the `Premium` sku. Options are `Basic`, `Standar` or `Premium`.                                                                             |
| ContainerRegistryEnableAdminUser   | <input type="checkbox">         | `$true`/`$false`                                                                                                                                | Enable the non-ad admin with username & password authentication for this Container Registry. For example: when you use containers in appservices you need this, because it does not support managed identities yet.                       |
| LogAnalyticsWorkspaceResourceId    | <input type="checkbox" checked> | `/subscriptions/<subscriptionid>/resourceGroups/<resourcegroup>/providers/Microsoft.OperationalInsights/workspaces/<loganalyticsworkspacename>` | The Log Analytics Workspace the diagnostic setting will be linked to.                                                                                                                                                                     |
| ForcePublic                        | <input type="checkbox">         | n.a.                                                                                                                                            | If you are not using any networking settings, you need to pass this boolean to confirm you are willingly creating a public resource (to avoid unintended public resources). You can pass it as a switch without a value (`-ForcePublic`). |
| DiagnosticSettingsLogs             | <input type="checkbox">         | `@('Requests';'MongoRequests';)`                                                                                                                | If you want to enable a specific set of diagnostic settings for the category 'Logs'. By default, all categories for 'Logs' will be enabled.                                                                                               |
| DiagnosticSettingsMetrics          | <input type="checkbox">         | `@('Requests';'MongoRequests';)`                                                                                                                | If you want to enable a specific set of diagnostic settings for the category 'Metrics'. By default, all categories for 'Metrics' will be enabled.                                                                                         |
| DiagnosticSettingsDisabled         | <input type="checkbox">         | n.a.                                                                                                                                            | If you don't want to enable any diagnostic settings, you can pass this as a switch witout a value(`-DiagnosticsettingsDisabled`).                                                                                                         |

# VNET Whitelisting Parameters

If you want to use "VNet whitelisting" on your resource. Use these parameters. Using VNET Whitelisting is the recommended way of building & connecting your application stack within Azure.

> NOTE: These parameters are only required when you want to use the VNet whitelisting feature for this resource.

| Parameter                        | Required for VNet whitelisting  | Example Value                        | Description                                                                                                          |
| -------------------------------- | ------------------------------- | ------------------------------------ | -------------------------------------------------------------------------------------------------------------------- |
| ApplicationVnetResourceGroupName | <input type="checkbox" checked> | `sharedservices-rg`                  | The ResourceGroup where your VNET, for your container, resides in.                                                   |
| ApplicationVnetName              | <input type="checkbox" checked> | `my-vnet-$(Release.EnvironmentName)` | The name of the VNET the container is in                                                                             |
| ApplicationSubnetName            | <input type="checkbox" checked> | `app-subnet-1`                       | The name of the subnet where the containers will be spun up (This subnet will get access to the container registry). |

# Private Endpoint Parameters

If you want to use private endpoints on your resource. Use these parameters. Private Endpoints are used for connecting to your Azure Resources from on-premises.

> NOTE: These parameters are only required when you want to use a private endpoint for this resource.

| Parameter                                             | Required for Pvt Endpoint       | Example Value                                  | Description                                                                                                              |
| ----------------------------------------------------- | ------------------------------- | ---------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| ContainerRegistryPrivateEndpointVnetResourceGroupName | <input type="checkbox" checked> | `sharedservices-rg`                            | The ResourceGroup where your VNET, for your Container Registry Private Endpoint, resides in.                             |
| ContainerRegistryPrivateEndpointVnetName              | <input type="checkbox" checked> | `my-vnet-$(Release.EnvironmentName)`           | The name of the VNET to place the Container Registry Private Endpoint in.                                                |
| ContainerRegistryPrivateEndpointSubnetName            | <input type="checkbox" checked> | `app-subnet-3`                                 | The subnetname where the private endpoint for this container registry should be created.                                 |
| DNSZoneResourceGroupName                              | <input type="checkbox" checked> | `Customer-DNSZones-$(Release.EnvironmentName)` | The resourcegroup where the DNS Zones reside in. This is generally a tenant-wide shared resourcegroup.                   |
| PrivateEndpointGroupId                                | <input type="checkbox">         | `registry`                                     | The Group ID for the registry. You can safely use `registry` here. This defaults to `registry`.                          |
| ContainerRegistryPrivateDnsZoneName                   | <input type="checkbox">         | `privatelink.azurecr.io`                       | The privatelink DNS Zone to use. `privatelink.azurecr.io` can be safely used here. Defaults to `privatelink.azurecr.io`. |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Create Container Registry"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/Container-Registry/Create-Container-Registry.ps1"
    arguments: "-ContainerRegistryName '$(ContainerRegistryName)' -ContainerRegistryResourceGroupName '$(ContainerRegistryResourceGroupName)' -ApplicationVnetResourceGroupName '$(ApplicationVnetResourceGroupName)' -ApplicationVnetName '$(ApplicationVnetName)' -ApplicationSubnetName '$(ApplicationSubnetName)' -ContainerRegistryPrivateEndpointVnetName '$(ContainerRegistryPrivateEndpointVnetName)' -ContainerRegistryPrivateEndpointVnetResourceGroupName '$(ContainerRegistryPrivateEndpointVnetResourceGroupName)' -ContainerRegistryPrivateEndpointSubnetName '$(ContainerRegistryPrivateEndpointSubnetName)' -PrivateEndpointGroupId '$(PrivateEndpointGroupId)' -DNSZoneResourceGroupName '$(DNSZoneResourceGroupName)' -ContainerRegistryPrivateDnsZoneName '$(ContainerRegistryPrivateDnsZoneName)' -LogAnalyticsWorkspaceResourceId '$(LogAnalyticsWorkspaceResourceId)' -DiagnosticSettingsLogs $(DiagnosticSettingsLogs) -DiagnosticSettingsDisabled $(DiagnosticSettingsDisabled)"
```

# Code

[Click here to download this script](../../../../src/Container-Registry/Create-Container-Registry.ps1)

# Links

[Azure CLI - az network vnet show](https://docs.microsoft.com/en-us/cli/azure/network/vnet?view=azure-cli-latest#az_network_vnet_show)

[Azure CLI - az acr create](https://docs.microsoft.com/en-us/cli/azure/acr?view=azure-cli-latest#az_acr_create)

[Azure CLI - az network vnet subnet update](https://docs.microsoft.com/en-us/cli/azure/network/vnet/subnet?view=azure-cli-latest#az_network_vnet_subnet_update)

[Azure CLI - az acr show](https://docs.microsoft.com/en-us/cli/azure/acr?view=azure-cli-latest#az_acr_show)

[Azure CLI - az network private-endpoint create](https://docs.microsoft.com/en-us/cli/azure/network/private-endpoint?view=azure-cli-latest#az_network_private_endpoint_create)

[Azure CLI - az network private-dns zone show](https://docs.microsoft.com/en-us/cli/azure/ext/privatedns/network/private-dns/zone?view=azure-cli-latest#ext_privatedns_az_network_private_dns_zone_show)

[Azure CLI - az network private-dns zone create](https://docs.microsoft.com/en-us/cli/azure/ext/privatedns/network/private-dns/zone?view=azure-cli-latest#ext_privatedns_az_network_private_dns_zone_create)

[Azure CLI - az network private-dns link vnet show](https://docs.microsoft.com/en-us/cli/azure/network/private-dns/link/vnet?view=azure-cli-latest#az_network_private_dns_link_vnet_show)

[Azure CLI - az network private-dns link vnet create](https://docs.microsoft.com/en-us/cli/azure/network/private-dns/link/vnet?view=azure-cli-latest#az_network_private_dns_link_vnet_create)

[Azure CLI - az network private-endpoint dns-zone-group create](https://docs.microsoft.com/en-us/cli/azure/network/private-endpoint/dns-zone-group?view=azure-cli-latest#az_network_private_endpoint_dns_zone_group_create)

[Azure CLI - az acr network-rule add](https://docs.microsoft.com/en-us/cli/azure/acr/network-rule?view=azure-cli-latest#az_acr_network_rule_add)

[Azure CLI - az acr update](https://docs.microsoft.com/en-us/cli/azure/acr?view=azure-cli-latest#az_acr_update)

[Azure CLI - az monitor diagnostic-settings-create](https://docs.microsoft.com/nl-nl/cli/azure/monitor/diagnostic-settings?view=azure-cli-latest#az_monitor_diagnostic_settings_create)
