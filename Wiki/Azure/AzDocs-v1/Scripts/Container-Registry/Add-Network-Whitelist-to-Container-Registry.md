[[_TOC_]]

# Description

Adding network whitelisting is only possible for Container Registries with the Premium tier.
This snippet will whitelist the specified IP Range from the Azure Container Registry. If you leave the `CIDRToWhitelist` parameter empty, it will use the outgoing IP from where you execute this script.

# Parameters

| Parameter                              | Required                        | Example Value                                     | Description                                                                                                                                                                                                                                                                      |
| -------------------------------------- | ------------------------------- | ------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ContainerRegistryResourceGroupName     | <input type="checkbox" checked> | `myteam-testapi-$(Release.EnvironmentName)`       | The name of the resource group the Container Registry is in                                                                                                                                                                                                                      |
| ContainerRegistryName                  | <input type="checkbox" checked> | `somecontainerregistry$(Release.EnvironmentName)` | The name for the Container Registry resource. This name is restricted to alphanumerical characters without hyphens etc.                                                                                                                                                          |
| CIDRToWhitelist                        | <input type="checkbox">         | `52.43.65.123/32`                                 | The IP range to whitelist in [CIDR notation](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing#CIDR_notation). Leave this field empty to use the outgoing IP from where you execute this script. Be aware that only public ip's can be whitelisted for this resource. |
| SubnetToWhitelistSubnetName            | <input type="checkbox">         | `gateway2-subnet`                                 | The name of the subnet you want to get whitelisted.                                                                                                                                                                                                                              |
| SubnetToWhitelistVnetName              | <input type="checkbox">         | `sp-dc-dev-001-vnet`                              | The vnetname of the subnet you want to get whitelisted.                                                                                                                                                                                                                          |
| SubnetToWhitelistVnetResourceGroupName | <input type="checkbox">         | `sharedservices-rg`                               | The VnetResourceGroupName your Vnet resides in.                                                                                                                                                                                                                                  |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Add Network Whitelist to Container Registry"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/Container-Registry/Add-Network-Whitelist-to-Container-Registry.ps1"
    arguments: "-ContainerRegistryName '$(ContainerRegistryName)' -ContainerRegistryResourceGroupName '$(ContainerRegistryResourceGroupName)' -CIDRToWhitelist '$(CIDRToWhitelist)' -SubnetToWhitelistSubnetName '$(SubnetToWhitelistSubnetName)' -SubnetToWhitelistVnetName '$(SubnetToWhitelistVnetName)' -SubnetToWhitelistVnetResourceGroupName '$(SubnetToWhitelistVnetResourceGroupName)'"
```

# Code

[Click here to download this script](../../../../../src/Container-Registry/Add-IP-Whitelist-to-Container-Registry.ps1)

# Links

[Azure CLI - az acr network-rule add](https://docs.microsoft.com/en-us/cli/azure/acr/network-rule?view=azure-cli-latest#az_acr_network_rule_add)
