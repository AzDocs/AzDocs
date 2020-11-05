[[_TOC_]]

# Description
This snippet will create a blobcontainer inside a specified (pre-existing) storageaccount.

# Parameters
Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.

| Parameter | Example Value | Description |
|--|--|--|
| storageAccountResourceGroupname | `MyTeam-TestApi-$(Release.EnvironmentName)` | The resourcegroup where the storageaccount resides in |
| storageAccountName | `myteststgaccount$(Release.EnvironmentName)` | The name of the storageaccount which will be used |
| containerName | `images` | The name of the blobcontainer |

# Code
[Click here to download this script](../../../../src/Storage-Accounts/Create-Blobcontainer-in-Storageaccount.ps1)

# Links

[Azure CLI - az-storage-container-create](https://docs.microsoft.com/en-us/cli/azure/storage/container?view=azure-cli-latest#az-storage-container-create)

[Azure CLI - az-storage-account-keys-list](https://docs.microsoft.com/en-us/cli/azure/storage/account/keys?view=azure-cli-latest#az-storage-account-keys-list)