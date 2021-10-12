[[_TOC_]]

# Description

This snippet will remove the specified IP Range from the Azure CosmosDb Account. If you leave the `CIDRToRemoveFromWhitelist` parameter empty, it will use the outgoing IP from where you execute this script.

> NOTE: It is strongly suggested to set the condition, of this task in the pipeline, to always run. Even if your previous steps have failed. This is to avoid unintended whitelists whenever pipelines crash in the middle of something.

# Parameters

| Parameter | Required | Example Value  | Description |
|----|----|----|----|
| CosmosDBAccountResourceGroupName    | <input type="checkbox" checked> | `myteam-testapi-$(Release.EnvironmentName)` | The name of the resource group the CosmosDb account resides in. |
| CosmosDBAccountName                 | <input type="checkbox" checked> | `somecosmosdb$(Release.EnvironmentName)`    | The name for the CosmosDb Account resource. |
| CIDRToRemoveFromWhitelist           | <input type="checkbox"> | `52.43.65.123/32` | The IP range, to remove the whitelist for, in [CIDR notation](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing#CIDR_notation). Leave this field empty to use the outgoing IP from where you execute this script. NOTE: if you want to add a `/32`, make sure to omit the `/32` (for example: `123.123.123.123` instead of `123.123.123.123/32`). |
| SubnetToRemoveSubnetName            | <input type="checkbox"> | `gateway2-subnet` | The name of the subnet you want to remove from the whitelist.     |
| SubnetToRemoveVnetName              | <input type="checkbox">  | `sp-dc-dev-001-vnet` | The vnetname of the subnet you want to remove from the whitelist. |
| SubnetToRemoveVnetResourceGroupName | <input type="checkbox">  | `sharedservices-rg` | The VnetResourceGroupName your Vnet resides in.                   |


# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Remove Network Whitelist from CosmosDb Account"
  condition: always()
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/CosmosDb/Remove-Network-Whitelist-from-CosmosDb-Account.ps1"
    arguments: "-CosmosDBAccountName '$(CosmosDBAccountName)' -CosmosDBAccountResourceGroupName '$(CosmosDBAccountResourceGroupName)' -CIDRToRemoveFromWhitelist '$(CIDRToRemoveFromWhitelist)' -SubnetToRemoveSubnetName '$(SubnetToRemoveSubnetName)' -SubnetToRemoveVnetName '$(SubnetToRemoveVnetName)' -SubnetToRemoveVnetResourceGroupName '$(SubnetToRemoveVnetResourceGroupName)'"
```

# Code

[Click here to download this script](../../../../src/CosmosDb/Remove-IP-Whitelist-from-CosmosDb-Account.ps1)

# Links

[Azure CLI - az cosmosdb show](https://docs.microsoft.com/en-us/cli/azure/cosmosdb?view=azure-cli-latest#az_cosmosdb_show)

[Azure CLI - az network vnet subnet show](https://docs.microsoft.com/en-us/cli/azure/network/vnet/subnet?view=azure-cli-latest#az_network_vnet_subnet_show)

[Azure CLI - az cosmosdb network-rule remove](https://docs.microsoft.com/en-us/cli/azure/cosmosdb/network-rule?view=azure-cli-latest#az_cosmosdb_network_rule_remove)

[Azure CLI - az cosmosdb update](https://docs.microsoft.com/en-us/cli/azure/cosmosdb?view=azure-cli-latest#az_cosmosdb_update)
