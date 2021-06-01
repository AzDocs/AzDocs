[[_TOC_]]

# Description
This snippet will remove the specified IP Range from the Azure Storage Account. If you leave the `CIDRToRemoveFromWhitelist` parameter empty, it will use the outgoing IP from where you execute this script.

> NOTE: It is strongly suggested to set the condition, of this task in the pipeline, to always run. Even if your previous steps have failed. This is to avoid unintended whitelists whenever pipelines crash in the middle of something.

# Parameters
| Parameter | Example Value | Description |
|--|--|--|
| StorageAccountResourceGroupName | `myteam-testapi-$(Release.EnvironmentName)` | The name of the resource group the Storage Account is in. |
| StorageAccountName | `somestorageaccount$(Release.EnvironmentName)` | The name for the Storage Account resource. This name is restricted to alphanumerical characters without hyphens etc. |
| CIDRToRemoveFromWhitelist | `52.43.65.123/32` | The IP range, to remove the whitelist for, in [CIDR notation](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing#CIDR_notation). Leave this field empty to use the outgoing IP from where you execute this script. |

# Code
[Click here to download this script](../../../../src/Storage-Accounts/Remove-IP-Whitelist-from-StorageAccount.ps1)

# Links

[Azure CLI - az storage account network-rule remove](https://docs.microsoft.com/en-us/cli/azure/storage/account/network-rule?view=azure-cli-latest#az_storage_account_network_rule_remove)