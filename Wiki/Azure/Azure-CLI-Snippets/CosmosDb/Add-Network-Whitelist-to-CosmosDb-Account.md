[[_TOC_]]

# Description

This snippet will whitelist the given source on the Azure CosmosDb account. If you leave the `CIDRToWhitelist`, `SubnetToWhitelistSubnetName`, `SubnetToWhitelistVnetName` & `SubnetToWhitelistVnetResourceGroupName` parameter empty, it will use the outgoing IP from where you execute this script.

# Parameters

| Parameter                              | Required                        | Example Value                               | Description                                                                                                                                                                                                                   |
| -------------------------------------- | ------------------------------- | ------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| CosmosDBAccountResourceGroupName       | <input type="checkbox" checked> | `myteam-testapi-$(Release.EnvironmentName)` | The name of the resource group the CosmosDb account is in.                                                                                                                                                                    |
| CosmosDBAccountName                    | <input type="checkbox" checked> | `somemysqlserver$(Release.EnvironmentName)` | The name for the CosmosDb account resource. It's recommended to use just alphanumerical characters without hyphens etc.                                                                                                       |
| CIDRToWhitelist                        | <input type="checkbox">         | `52.43.65.123/32`                           | IP range in [CIDR](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing) notation that should be whitelisted. If you leave this value empty, it will whitelist the machine's ip where you're running the script from. |
| SubnetToWhitelistSubnetName            | <input type="checkbox">         | `gateway2-subnet`                           | The name of the subnet you want to get whitelisted.                                                                                                                                                                           |
| SubnetToWhitelistVnetName              | <input type="checkbox">         | `sp-dc-dev-001-vnet`                        | The vnetname of the subnet you want to get whitelisted.                                                                                                                                                                       |
| SubnetToWhitelistVnetResourceGroupName | <input type="checkbox">         | `sharedservices-rg`                         | The VnetResourceGroupName your Vnet resides in.                                                                                                                                                                               |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Add Network Whitelist to CosmosDb account"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/CosmosDb/Add-Network-Whitelist-to-CosmosDb-Account.ps1"
    arguments: "-CosmosDBAccountName '$(CosmosDBAccountName)' -CosmosDBAccountResourceGroupName '$(CosmosDBAccountResourceGroupName)' -CIDRToWhitelist '$(CIDRToWhitelist)' -SubnetToWhitelistSubnetName '$(SubnetToWhitelistSubnetName)' -SubnetToWhitelistVnetName '$(SubnetToWhitelistVnetName)' -SubnetToWhitelistVnetResourceGroupName '$(SubnetToWhitelistVnetResourceGroupName)'"
```

# Code

[Click here to download this script](../../../../src/CosmosDb/Add-IP-Whitelist-to-CosmosDb-Account.ps1)

# Links

[Azure CLI - az cosmosdb show](https://docs.microsoft.com/en-us/cli/azure/cosmosdb?view=azure-cli-latest#az_cosmosdb_show)

[Azure CLI - az network vnet subnet show](https://docs.microsoft.com/en-us/cli/azure/network/vnet/subnet?view=azure-cli-latest#az_network_vnet_subnet_show)

[Azure CLI - az cosmosdb network-rule add](https://docs.microsoft.com/en-us/cli/azure/cosmosdb/network-rule?view=azure-cli-latest#az_cosmosdb_network_rule_add)

[Azure CLI - az cosmosdb update](https://docs.microsoft.com/en-us/cli/azure/cosmosdb?view=azure-cli-latest#az_cosmosdb_update)
