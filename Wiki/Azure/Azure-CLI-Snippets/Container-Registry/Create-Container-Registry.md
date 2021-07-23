[[_TOC_]]

# Description

This snippet will create an Azure Container Instances instance for you. It will be integrated into the given subnet.

# Parameters

Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.

| Parameter                          | Required                        | Example Value                                | Description                                               |
| ---------------------------------- | ------------------------------- | -------------------------------------------- | --------------------------------------------------------- |
| ContainerRegistryName              | <input type="checkbox" checked> | `customershared$(Release.EnvironmentName)`   | The name of the container registry.                       |
| ContainerRegistryResourceGroupName | <input type="checkbox" checked> | `Customer-Shared-$(Release.EnvironmentName)` | The resourcegroup where the container registry should be. |
| ContainerRegistrySku | <input type="checkbox"> | `Premium` | The sku for this registry. Note that for networking options other than "public" you will need the `Premium` sku. Options are `Basic`, `Standar` or `Premium`. |
| ContainerRegistryEnableAdminUser | <input type="checkbox"> | `$true`/`$false` | Enable the non-ad admin with username & password authentication for this Container Registry. For example: when you use containers in appservices you need this, because it does not support managed identities yet. |

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

| Parameter                                             | Required for Pvt Endpoint       | Example Value                                  | Description                                                                                            |
| ----------------------------------------------------- | ------------------------------- | ---------------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| ContainerRegistryPrivateEndpointVnetResourceGroupName | <input type="checkbox" checked> | `sharedservices-rg`                            | The ResourceGroup where your VNET, for your Container Registry Private Endpoint, resides in.           |
| ContainerRegistryPrivateEndpointVnetName              | <input type="checkbox" checked> | `my-vnet-$(Release.EnvironmentName)`           | The name of the VNET to place the Container Registry Private Endpoint in.                              |
| ContainerRegistryPrivateEndpointSubnetName            | <input type="checkbox" checked> | `app-subnet-3`                                 | The subnetname where the private endpoint for this container registry should be created.               |
| PrivateEndpointGroupId                                | <input type="checkbox" checked> | `registry`                                     | The Group ID for the registry. You can safely use `registry` here.                                     |
| DNSZoneResourceGroupName                              | <input type="checkbox" checked> | `Customer-DNSZones-$(Release.EnvironmentName)` | The resourcegroup where the DNS Zones reside in. This is generally a tenant-wide shared resourcegroup. |
| ContainerRegistryPrivateDnsZoneName                   | <input type="checkbox" checked> | `privatelink.azurecr.io`                       | The privatelink DNS Zone to use. `privatelink.azurecr.io` can be safely used here.                     |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
        - task: AzureCLI@2
           displayName: 'Create Container Registry'
           condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
           inputs:
               azureSubscription: '${{ parameters.SubscriptionName }}'
               scriptType: pscore
               scriptPath: '$(Pipeline.Workspace)/AzDocs/Container-Registry/Create-Container-Registry.ps1'
               arguments: "-ContainerRegistryName '$(ContainerRegistryName)' -ContainerRegistryResourceGroupName '$(ContainerRegistryResourceGroupName)' -ApplicationVnetResourceGroupName '$(ApplicationVnetResourceGroupName)' -ApplicationVnetName '$(ApplicationVnetName)' -ApplicationSubnetName '$(ApplicationSubnetName)' -ContainerRegistryPrivateEndpointVnetName '$(ContainerRegistryPrivateEndpointVnetName)' -ContainerRegistryPrivateEndpointVnetResourceGroupName '$(ContainerRegistryPrivateEndpointVnetResourceGroupName)' -ContainerRegistryPrivateEndpointSubnetName '$(ContainerRegistryPrivateEndpointSubnetName)' -PrivateEndpointGroupId '$(PrivateEndpointGroupId)' -DNSZoneResourceGroupName '$(DNSZoneResourceGroupName)' -ContainerRegistryPrivateDnsZoneName '$(ContainerRegistryPrivateDnsZoneName)'"
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
