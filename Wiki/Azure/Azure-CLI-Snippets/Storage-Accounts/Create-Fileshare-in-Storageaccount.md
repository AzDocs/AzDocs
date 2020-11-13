[[_TOC_]]

# Description
This snippet will create a fileshare inside a specified (pre-existing) storageaccount.

# Parameters
Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.

| Parameter | Example Value | Description |
|--|--|--|
| storageAccountResourceGroupname | `MyTeam-TestApi-$(Release.EnvironmentName)` | The resourcegroup where the storageaccount resides in |
| storageAccountName | `myteststgaccount$(Release.EnvironmentName)` | The name of the storageaccount which will be used |
| shareName | `images` | The name of the fileshare |

# Code
[Click here to download this script](../../../../src/Storage-Accounts/Create-Fileshare-in-Storageaccount.ps1)

# Links

[Azure CLI - az storage share create](https://docs.microsoft.com/en-us/cli/azure/storage/share?view=azure-cli-latest#az_storage_share_create)
