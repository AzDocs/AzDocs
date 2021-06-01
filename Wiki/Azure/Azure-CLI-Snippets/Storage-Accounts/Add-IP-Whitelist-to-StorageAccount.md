[[_TOC_]]

# Description
This snippet will whitelist the specified IP Range from the Azure Storage Account. If you leave the `CIDRToWhitelist` parameter empty, it will use the outgoing IP from where you execute this script.

# Parameters
| Parameter | Example Value | Description |
|--|--|--|
| StorageAccountResourceGroupName | `myteam-testapi-$(Release.EnvironmentName)` | The name of the resource group the Storage Account is in. |
| StorageAccountName | `somestorageaccount$(Release.EnvironmentName)` | The name for the Storage Account resource. This name is restricted to alphanumerical characters without hyphens etc. |
| CIDRToWhitelist | `52.43.65.123/32` | The IP range to whitelist in [CIDR notation](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing#CIDR_notation). Leave this field empty to use the outgoing IP from where you execute this script. |

# Code
[Click here to download this script](../../../../src/Storage-Accounts/Add-IP-Whitelist-to-StorageAccount)

# Links

[Azure CLI - az storage account network-rule add](https://docs.microsoft.com/en-us/cli/azure/storage/account/network-rule?view=azure-cli-latest#az_storage_account_network_rule_add)