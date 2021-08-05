[[_TOC_]]

# Description

Adding network whitelisting is only possible for Container Registries with the Premium tier at the moment. So deleting can only be done in Container Registries in the Premium Tier.

This snippet will remove the specified IP Range from the Azure Container Registry. If you leave the `CIDRToRemoveFromWhitelist` parameter empty, it will use the outgoing IP from where you execute this script.

> NOTE: It is strongly suggested to set the condition, of this task in the pipeline, to always run. Even if your previous steps have failed. This is to avoid unintended whitelists whenever pipelines crash in the middle of something.

# Parameters

| Parameter                           | Required                        | Example Value                                     | Description                                                                                                                                                                                                                  |
| ----------------------------------- | ------------------------------- | ------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ContainerRegistryResourceGroupName  | <input type="checkbox" checked> | `myteam-testapi-$(Release.EnvironmentName)`       | The name of the resource group the Container Registry is in                                                                                                                                                                  |
| ContainerRegistryName               | <input type="checkbox" checked> | `somecontainerregistry$(Release.EnvironmentName)` | The name for the Container Registry resource. This name is restricted to alphanumerical characters without hyphens etc.                                                                                                      |
| CIDRToRemoveFromWhitelist           | <input type="checkbox">         | `52.43.65.123/32`                                 | The IP range, to remove the whitelist for, in [CIDR notation](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing#CIDR_notation). Leave this field empty to use the outgoing IP from where you execute this script. |
| SubnetToRemoveSubnetName            | <input type="checkbox">         | `gateway2-subnet`                                 | The name of the subnet you want to remove from the whitelist.                                                                                                                                                                |
| SubnetToRemoveVnetName              | <input type="checkbox">         | `sp-dc-dev-001-vnet`                              | The vnetname of the subnet you want to remove from the whitelist.                                                                                                                                                            |
| SubnetToRemoveVnetResourceGroupName | <input type="checkbox">         | `sharedservices-rg`                               | The VnetResourceGroupName your Vnet resides in.                                                                                                                                                                              |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
        - task: AzureCLI@2
           displayName: 'Remove Network Whitelist from Container Registry'
           condition: always()
           inputs:
               azureSubscription: '${{ parameters.SubscriptionName }}'
               scriptType: pscore
               scriptPath: '$(Pipeline.Workspace)/AzDocs/Container-Registry/Remove-Network-Whitelist-from-Container-Registry.ps1'
               arguments: "-ContainerRegistryName '$(ContainerRegistryName)' -ContainerRegistryResourceGroupName '$(ContainerRegistryResourceGroupName)' -CIDRToRemoveFromWhitelist '$(CIDRToRemoveFromWhitelist)' -SubnetToRemoveSubnetName '$(SubnetToRemoveSubnetName)' -SubnetToRemoveVnetName '$(SubnetToRemoveVnetName)' -SubnetToRemoveVnetResourceGroupName '$(SubnetToRemoveVnetResourceGroupName)'"
```

# Code

[Click here to download this script](../../../../src/Container-Registry/Remove-IP-Whitelist-from-Container-Registry.ps1)

# Links

[Azure CLI - az acr network-rule remove](https://docs.microsoft.com/en-us/cli/azure/acr/network-rule?view=azure-cli-latest#az_acr_network_rule_remove)
