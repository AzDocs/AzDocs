[[_TOC_]]

# Description

This snippet will whitelist the specified IP Range from the Azure Storage Account. If you leave the `CIDRToWhitelist` parameter empty, it will use the outgoing IP from where you execute this script.

# Parameters

| Parameter                              | Example Value                                  | Description                                                                                                                                                                                                                                                                                                                                                                                                      |
| -------------------------------------- | ---------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------- |
| StorageAccountResourceGroupName        | `myteam-testapi-$(Release.EnvironmentName)`    | The name of the resource group the Storage Account is in.                                                                                                                                                                                                                                                                                                                                                        |
| StorageAccountName                     | `somestorageaccount$(Release.EnvironmentName)` | The name for the Storage Account resource. This name is restricted to alphanumerical characters without hyphens etc.                                                                                                                                                                                                                                                                                             |
| CIDRToWhitelist                        | `52.43.65.123/24`                              | The IP range to whitelist in [CIDR notation](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing#CIDR_notation). Leave this field empty to use the outgoing IP from where you execute this script. NOTE: if you want to add a `/32`, make sure to omit the `/32` (for example: `123.123.123.123` instead of `123.123.123.123/32`). Be aware that only public ip's can be whitelisted for this resource. |
| SubnetToWhitelistSubnetName            | <input type="checkbox">                        | `gateway2-subnet`                                                                                                                                                                                                                                                                                                                                                                                                | The name of the subnet you want to get whitelisted.     |
| SubnetToWhitelistVnetName              | <input type="checkbox">                        | `sp-dc-dev-001-vnet`                                                                                                                                                                                                                                                                                                                                                                                             | The vnetname of the subnet you want to get whitelisted. |
| SubnetToWhitelistVnetResourceGroupName | <input type="checkbox">                        | `sharedservices-rg`                                                                                                                                                                                                                                                                                                                                                                                              | The VnetResourceGroupName your Vnet resides in.         |

# YAML

```yaml
        - task: AzureCLI@2
           displayName: 'Add Network Whitelist to StorageAccount'
           condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
           inputs:
               azureSubscription: '${{ parameters.SubscriptionName }}'
               scriptType: pscore
               scriptPath: '$(Pipeline.Workspace)/AzDocs/Storage-Accounts/Add-Network-Whitelist-to-StorageAccount.ps1'
               arguments: "-StorageAccountName '$(StorageAccountName)' -StorageAccountResourceGroupName '$(StorageAccountResourceGroupName)' -CIDRToWhitelist '$(CIDRToWhitelist)' -SubnetToWhitelistSubnetName '$(SubnetToWhitelistSubnetName)' -SubnetToWhitelistVnetName '$(SubnetToWhitelistVnetName)' -SubnetToWhitelistVnetResourceGroupName '$(SubnetToWhitelistVnetResourceGroupName)'"
```

# Code

[Click here to download this script](../../../../src/Storage-Accounts/Add-IP-Whitelist-to-StorageAccount)

# Links

[Azure CLI - az storage account network-rule add](https://docs.microsoft.com/en-us/cli/azure/storage/account/network-rule?view=azure-cli-latest#az_storage_account_network_rule_add)
