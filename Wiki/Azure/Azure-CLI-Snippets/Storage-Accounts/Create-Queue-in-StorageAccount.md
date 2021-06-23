[[_TOC_]]

# Description
This snippet will create a queue inside a specified (pre-existing) storageaccount.

# Parameters
Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.

| Parameter | Example Value | Description |
|--|--|--|
| StorageAccountName | `myteststgaccount$(Release.EnvironmentName)` | The name of the storageaccount which will be used |
| QueueName | `images` | The name of the queue to create |

# Code
[Click here to download this script](../../../../src/Storage-Accounts/Create-Queue-in-Storageaccount.ps1)

# Links

[Azure CLI - az storage queue create](https://docs.microsoft.com/nl-nl/cli/azure/storage/queue?view=azure-cli-latest#az_storage_queue_create)