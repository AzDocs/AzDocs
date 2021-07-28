[[_TOC_]]

# Description

Mutating network rules is only possible for ServiceBus with Premium tier. The script will check if ServiceBus is at Premium tier, if not, the script will fail (to prevent creating a public servicebus by accident).

This snippet will remove the whitelist of the specified IP Range from the ServiceBus. If you leave the `CIDRToWhitelist` parameter empty, it will use the outgoing IP from where you execute this script.

# Parameters

| Parameter                            | Required                        | Example Value                             | Description                                                                                                                                                                                                                  |
| ------------------------------------ | ------------------------------- | ----------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ServiceBusNamespaceResourceGroupName | <input type="checkbox" checked> | `$(ServiceBusNamespaceResourceGroupName)` | The name of the resource group the ServiceBus Namespace is in.                                                                                                                                                               |
| ServiceBusNamespaceName              | <input type="checkbox" checked> | `$(ServiceBusNamespaceName)`              | The name for the ServiceBus Namespace.                                                                                                                                                                                       |
| CIDRToRemove                         | <input type="checkbox">         | `52.43.65.123/32`                         | The IP range, to remove the whitelist for, in [CIDR notation](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing#CIDR_notation). Leave this field empty to use the outgoing IP from where you execute this script. |
| SubnetToRemoveSubnetName             | <input type="checkbox">         | `gateway2-subnet`                         | The name of the subnet you want to remove from the whitelist.                                                                                                                                                                |
| SubnetToRemoveVnetName               | <input type="checkbox">         | `sp-dc-dev-001-vnet`                      | The vnetname of the subnet you want to remove from the whitelist.                                                                                                                                                            |
| SubnetToRemoveVnetResourceGroupName  | <input type="checkbox">         | `sharedservices-rg`                       | The VnetResourceGroupName your Vnet resides in.                                                                                                                                                                              |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
        - task: AzureCLI@2
           displayName: 'Remove Network Whitelist from ServiceBus Namespace'
           condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
           inputs:
               azureSubscription: '${{ parameters.SubscriptionName }}'
               scriptType: pscore
               scriptPath: '$(Pipeline.Workspace)/AzDocs/ServiceBus/Remove-Network-Whitelist-from-ServiceBus-Namespace.ps1'
               arguments: "-ServiceBusNamespaceName '$(ServiceBusNamespaceName)' -ServiceBusNamespaceResourceGroupName '$(ServiceBusNamespaceResourceGroupName)' -CIDRToRemove '$(CIDRToRemove)' -SubnetToRemoveSubnetName '$(SubnetToRemoveSubnetName)' -SubnetToRemoveVnetName '$(SubnetToRemoveVnetName)' -SubnetToRemoveVnetResourceGroupName '$(SubnetToRemoveVnetResourceGroupName)'"
```

# Code

[Click here to download this script](../../../../src/ServiceBus/Add-Network-Whitelist-to-ServiceBus-Namespace.ps1)

# Links

[Azure CLI - az servicebus namespace show](https://docs.microsoft.com/nl-nl/cli/azure/servicebus/namespace?view=azure-cli-latest#az_servicebus_namespace_show)

[Azure CLI - az servicebus namespace network-rule remove](https://docs.microsoft.com/nl-nl/cli/azure/servicebus/namespace/network-rule?view=azure-cli-latest#az_servicebus_namespace_network_rule_add)

[Azure CLI - az-network-vnet-subnet-show](https://docs.microsoft.com/en-us/cli/azure/network/vnet/subnet?view=azure-cli-latest#az-network-vnet-subnet-show)
