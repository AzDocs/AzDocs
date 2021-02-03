[[_TOC_]]

# Description
This snippet will whitelist a subnet on the defined storage account.

# Parameters
Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.

| Parameter | Example Value | Description |
|--|--|--|
| StorageResourceGroupName | `myteam-testapi-$(Release.EnvironmentName)` | ResourceGroupName where (pre-existing) the storage account is location |
| StorageAccountVnetName | `my-vnet-$(Release.EnvironmentName)` | The name of the VNET to use for where the storage account has been created. |
| StorageAccountVnetResourceGroupName | `sharedservices-rg` | The ResourceGroup where the storage account VNET resides in. |
| SubnetToWhiteListOnStorageAccount | `app-subnet-4` | The name for the subnet to whitelist on the storage account. |
| StorageAccountName | `myteststgaccount$(Release.EnvironmentName)` | The name of the (pre-existing) storage account you want to whitelist the subnet on |

# Code
[Click here to download this script](../../../../src/Storage-Accounts/Whitelist-Subnet-for-Storageaccount.ps1)

# Links

[Azure CLI - az-network-vnet-subnet-show](https://docs.microsoft.com/en-us/cli/azure/network/vnet/subnet?view=azure-cli-latest#az-network-vnet-subnet-show)

[Azure CLI - az-storage-account-network-rule-add](https://docs.microsoft.com/en-us/cli/azure/storage/account/network-rule?view=azure-cli-latest#az-storage-account-network-rule-add)
