[[_TOC_]]

# Description

This snippet will create a ServiceBus namespace if it does not exists.

# Parameters

Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.

| Parameter                              | Required                        | Example Value                                       | Description                                                                                                             |
| -------------------------------------- | ------------------------------- | --------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------|
| ServiceBusNamespaceResourceGroupName   | <input type="checkbox" checked> | `myteam-shared-$(Release.EnvironmentName)`          | ResourceGroupName where the ServiceBus Namespace should be created                                                      |
| ServiceBusNamespaceName                | <input type="checkbox" checked> | `myteam-servicebusns-$(Release.EnvironmentName)`    | This is the ServiceBus Namespace name to use.                                                                           |
| ServiceBusNamespaceSku                 | <input type="checkbox" checked> | `Standard`                                          | This is the sku you can choose for your ServiceBus Namespace. You have a choice between 'Basic', 'Standard', 'Premium'. |

# VNET Whitelisting Parameters

If you want to use "vnet whitelisting" on your resource. Use these parameters. Using VNET Whitelisting is the recommended way of building & connecting your application stack within Azure.

> NOTE: These parameters are only required when you want to use the VNet whitelisting feature for this resource.

| Parameter                        | Required for VNET Whitelisting  | Example Value                        | Description                                                              |
| -------------------------------- | ------------------------------- | ------------------------------------ | ------------------------------------------------------------------------ |
| ApplicationVnetResourceGroupName | <input type="checkbox" checked> | `sharedservices-rg`                  | The ResourceGroup where your VNET, for your storage account, resides in. |
| ApplicationVnetName              | <input type="checkbox" checked> | `my-vnet-$(Release.EnvironmentName)` | The name of the VNET the storage account is in                           |
| ApplicationSubnetName            | <input type="checkbox" checked> | `app-subnet-4`                       | The subnetname for the subnet whitelist on the storage account.          |

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
                arguments: "-ServiceBusNamespaceName '$(ServiceBusNamespaceName)' -ServiceBusNamespaceResourceGroupName '$(ServiceBusNamespaceResourceGroupName)' -ServiceBusNamespaceSku '$(ServiceBusNamespaceSku)' -ApplicationVnetResourceGroupName $(ApplicationVnetResourceGroupName) -ApplicationVnetName '$(ApplicationVnetName)' -ApplicationSubnetName '$(ServiceBusApplicationSubnetName)' -ResourceTags $(Resource.Tags)"
```

# Code

[Click here to download this script](../../../../src/ServiceBus/Create-ServiceBus-Namespace.ps1)

# Links

[Azure CLI - az servicebus namespace create](https://docs.microsoft.com/nl-nl/cli/azure/servicebus/namespace?view=azure-cli-latest#az_servicebus_namespace_create)

[Azure CLI - az servicebus namespace network-rule add](https://docs.microsoft.com/nl-nl/cli/azure/servicebus/namespace/network-rule?view=azure-cli-latest#az_servicebus_namespace_network_rule_add)

[Azure CLI - az-network-vnet-subnet-show](https://docs.microsoft.com/en-us/cli/azure/network/vnet/subnet?view=azure-cli-latest#az-network-vnet-subnet-show)

[Azure CLI - az-network-vnet-subnet-update](https://docs.microsoft.com/en-us/cli/azure/network/vnet/subnet?view=azure-cli-latest#az-network-vnet-subnet-update)
