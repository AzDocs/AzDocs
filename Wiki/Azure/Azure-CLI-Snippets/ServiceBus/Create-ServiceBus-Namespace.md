[[_TOC_]]

# Description

This snippet will create a ServiceBus namespace if it does not exist.

# Parameters

Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.

| Parameter                            | Required                        | Example Value                                    | Description                                                                                                                                                                                                                               |
| ------------------------------------ | ------------------------------- | ------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ServiceBusNamespaceResourceGroupName | <input type="checkbox" checked> | `myteam-shared-$(Release.EnvironmentName)`       | ResourceGroupName where the ServiceBus Namespace should be created                                                                                                                                                                        |
| ServiceBusNamespaceName              | <input type="checkbox" checked> | `myteam-servicebusns-$(Release.EnvironmentName)` | This is the ServiceBus Namespace name to use.                                                                                                                                                                                             |
| ServiceBusNamespaceSku               | <input type="checkbox" checked> | `Standard`                                       | This is the sku you can choose for your ServiceBus Namespace. You have a choice between 'Basic', 'Standard', 'Premium'.                                                                                                                   |
| ForcePublic                          | <input type="checkbox">         | n.a.                                             | If you are not using any networking settings, you need to pass this boolean to confirm you are willingly creating a public resource (to avoid unintended public resources). You can pass it as a switch without a value (`-ForcePublic`). |

# VNET Whitelisting Parameters

If you want to use "vnet whitelisting" on your resource. Use these parameters. Using VNET Whitelisting is the recommended way of building & connecting your application stack within Azure.

> NOTE: These parameters are only required when you want to use the VNet whitelisting feature for this resource.

| Parameter                        | Required for VNET Whitelisting  | Example Value                              | Description                                                                   |
| -------------------------------- | ------------------------------- | ------------------------------------------ | ----------------------------------------------------------------------------- |
| ApplicationVnetResourceGroupName | <input type="checkbox" checked> | `myteam-shared-$(Release.EnvironmentName)` | The ResourceGroup where your VNET, for your ServiceBus Namespace, resides in. |
| ApplicationVnetName              | <input type="checkbox" checked> | `my-vnet-$(Release.EnvironmentName)`       | The name of the VNET the ServiceBus Namespace is in                           |
| ApplicationSubnetName            | <input type="checkbox" checked> | `app-subnet-4`                             | The subnetname for the subnet whitelist on the ServiceBus Namespace.          |

# Private Endpoint Parameters

If you want to use private endpoints on your resource. Use these parameters. Private Endpoints are used for connecting to your Azure Resources from on-premises.

> NOTE: These parameters are only required when you want to use a private endpoint for this resource.

| Parameter                                               | Required for Pvt Endpoint       | Example Value                              | Description                                                                                                                                    |
| ------------------------------------------------------- | ------------------------------- | ------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| ServiceBusNamespacePrivateEndpointVnetResourceGroupName | <input type="checkbox" checked> | `myteam-shared-$(Release.EnvironmentName)` | The ResourceGroup where your VNET, for your ServiceBus Namespace private endpoint, resides in.                                                 |
| ServiceBusNamespacePrivateEndpointVnetName              | <input type="checkbox" checked> | `my-vnet-$(Release.EnvironmentName)`       | The name of the VNET to place the ServiceBus Namespace private endpoint in.                                                                    |
| ServiceBusNamespacePrivateEndpointSubnetName            | <input type="checkbox" checked> | `app-subnet-3`                             | The name of the subnet where the ServiceBus Namespace's private endpoint will reside in.                                                       |
| DNSZoneResourceGroupName                                | <input type="checkbox" checked> | `MyDNSZones-$(Release.EnvironmentName)`    | Make sure to use the shared DNS Zone resource group (you can only register a zone once per subscription).                                      |
| ServiceBusNamespacePrivateDnsZoneName                   | <input type="checkbox" checked> | `privatelink.servicebus.windows.net`       | Generally this will be `privatelink.servicebus.windows.net`. This defines which DNS Zone to use for the private ServiceBus Namespace endpoint. |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Create ServiceBus Namespace"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/ServiceBus/Create-ServiceBus-Namespace.ps1"
    arguments: "-ServiceBusNamespaceName '$(ServiceBusNamespaceName)' -ServiceBusNamespaceResourceGroupName '$(ServiceBusNamespaceResourceGroupName)' -ServiceBusNamespaceSku '$(ServiceBusNamespaceSku)' -ApplicationVnetResourceGroupName '$(ApplicationVnetResourceGroupName)' -ApplicationVnetName '$(ApplicationVnetName)' -ApplicationSubnetName '$(ServiceBusApplicationSubnetName)' -ServiceBusNamespacePrivateEndpointVnetResourceGroupName '$(ServiceBusNamespacePrivateEndpointVnetResourceGroupName)' -ServiceBusNamespacePrivateEndpointVnetName '$(ServiceBusNamespacePrivateEndpointVnetName)' -ServiceBusNamespacePrivateEndpointSubnetName '$(ServiceBusNamespacePrivateEndpointSubnetName)' -DNSZoneResourceGroupName '$(DNSZoneResourceGroupName)' -ServiceBusNamespacePrivateDnsZoneName '$(ServiceBusNamespacePrivateDnsZoneName)' -ResourceTags $(Resource.Tags)"
```

# Code

[Click here to download this script](../../../../src/ServiceBus/Create-ServiceBus-Namespace.ps1)

# Links

[Azure CLI - az servicebus namespace create](https://docs.microsoft.com/nl-nl/cli/azure/servicebus/namespace?view=azure-cli-latest#az_servicebus_namespace_create)

[Azure CLI - az servicebus namespace network-rule add](https://docs.microsoft.com/nl-nl/cli/azure/servicebus/namespace/network-rule?view=azure-cli-latest#az_servicebus_namespace_network_rule_add)

[Azure CLI - az-network-vnet-subnet-show](https://docs.microsoft.com/en-us/cli/azure/network/vnet/subnet?view=azure-cli-latest#az-network-vnet-subnet-show)

[Azure CLI - az-network-vnet-subnet-update](https://docs.microsoft.com/en-us/cli/azure/network/vnet/subnet?view=azure-cli-latest#az-network-vnet-subnet-update)

[Azure - ServiceBus network security](https://docs.microsoft.com/en-us/azure/service-bus-messaging/network-security)

[Azure - ServiceBus Namespace Tiers](https://docs.microsoft.com/en-us/azure/service-bus-messaging/service-bus-create-namespace-portal)
