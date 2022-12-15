[[_TOC_]]

# Description

Adding network rules is only possible for ServiceBus with Premium tier. The script will check if ServiceBus is at Premium tier, if not, the script will fail (to prevent creating a public servicebus by accident).

This snippet will whitelist the specified IP Range from the ServiceBus. If you leave the `CIDRToWhitelist` parameter empty, it will use the outgoing IP from where you execute this script.

If the given CIDR is already present, the script will not re-add the same CIDR.

# Parameters

| Parameter                              | Required                        | Example Value                             | Description                                                                                                                                                                                                                   |
| -------------------------------------- | ------------------------------- | ----------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ServiceBusNamespaceResourceGroupName   | <input type="checkbox" checked> | `$(ServiceBusNamespaceResourceGroupName)` | The name of the resource group the ServiceBus Namespace is in.                                                                                                                                                                |
| ServiceBusNamespaceName                | <input type="checkbox" checked> | `$(ServiceBusNamespaceName)`              | The name for the ServiceBus Namespace.                                                                                                                                                                                        |
| CIDRToWhitelist                        | <input type="checkbox">         | `52.43.65.123/32`                         | IP range in [CIDR](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing) notation that should be whitelisted. If you leave this value empty, it will whitelist the machine's ip where you're running the script from. |
| SubnetToWhitelistSubnetName            | <input type="checkbox">         | `gateway2-subnet`                         | The name of the subnet you want to get whitelisted.                                                                                                                                                                           |
| SubnetToWhitelistVnetName              | <input type="checkbox">         | `sp-dc-dev-001-vnet`                      | The vnetname of the subnet you want to get whitelisted.                                                                                                                                                                       |
| SubnetToWhitelistVnetResourceGroupName | <input type="checkbox">         | `sharedservices-rg`                       | The VnetResourceGroupName your Vnet resides in.                                                                                                                                                                               |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Add Network Whitelist to ServiceBus Namespace"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/ServiceBus/Add-Network-Whitelist-to-ServiceBus-Namespace.ps1"
    arguments: "-ServiceBusNamespaceName '$(ServiceBusNamespaceName)' -ServiceBusNamespaceResourceGroupName '$(ServiceBusNamespaceResourceGroupName)' -CIDRToWhitelist '$(CIDRToWhitelist)' -SubnetToWhitelistSubnetName '$(SubnetToWhitelistSubnetName)' -SubnetToWhitelistVnetName '$(SubnetToWhitelistVnetName)' -SubnetToWhitelistVnetResourceGroupName '$(SubnetToWhitelistVnetResourceGroupName)'"
```

# Code

[Click here to download this script](../../../../../src/ServiceBus/Add-Network-Whitelist-to-ServiceBus-Namespace.ps1)

# Links

[Azure CLI - az servicebus namespace show](https://docs.microsoft.com/nl-nl/cli/azure/servicebus/namespace?view=azure-cli-latest#az_servicebus_namespace_show)

[Azure CLI - az servicebus namespace network-rule add](https://docs.microsoft.com/nl-nl/cli/azure/servicebus/namespace/network-rule?view=azure-cli-latest#az_servicebus_namespace_network_rule_add)

[Azure CLI - az servicebus namespace network-rule list](https://docs.microsoft.com/nl-nl/cli/azure/servicebus/namespace/network-rule?view=azure-cli-latest#az_servicebus_namespace_network_rule_list)

[Azure CLI - az-network-vnet-subnet-show](https://docs.microsoft.com/en-us/cli/azure/network/vnet/subnet?view=azure-cli-latest#az-network-vnet-subnet-show)

[Azure CLI - az-network-vnet-subnet-update](https://docs.microsoft.com/en-us/cli/azure/network/vnet/subnet?view=azure-cli-latest#az-network-vnet-subnet-update)
