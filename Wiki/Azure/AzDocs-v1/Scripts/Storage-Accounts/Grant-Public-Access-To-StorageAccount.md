[[_TOC_]]

# Description

When creating resources inside of your storage account (blobcontainer / queues / fileshare), we recommend creating these inside your application. Find more information here:

- [Blob container creation](https://docs.microsoft.com/en-us/azure/storage/blobs/storage-quickstart-blobs-dotnet#code-examples)
- [Queue creation](https://docs.microsoft.com/en-us/azure/storage/queues/storage-dotnet-how-to-use-queues?tabs=dotnet)
- [Fileshare creation](https://docs.microsoft.com/en-us/azure/storage/files/storage-dotnet-how-to-use-files?tabs=dotnet#access-the-file-share-programmatically)

If you do want to create these resources by using the scripts, we recommend, because of the following [Github issue](https://github.com/MicrosoftDocs/azure-docs/issues/19456), using a selfhosted agent to deploy your storage account when using VNet whitelisting and/or private endpoints. More information about creating a selfhosted agent can be found here [Selfhosted Agents](/Azure/AzDocs-v1/General-Documentation/How-to-use-the-scripts#Deploying-to-SelfHosted-Agents-in-Pool).

If you do want to deploy the resources to the storage account by using the scripts without using vnet whitelisting and/or private endpoints, this snippet will fully open up your storage account to the internet. Again, this is NOT recommended.

# Parameters

Some parameters from [General Parameter](/Azure/AzDocs-v1/Scripts) list.

| Parameter                       | Example Value                                | Description                                                                                                                                                                                                                                      |
| ------------------------------- | -------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| StorageAccountResourceGroupName | `myteam-testapi-$(Release.EnvironmentName)`  | Name of resourcegroup where your storage account is in                                                                                                                                                                                           |
| StorageAccountName              | `myteststgaccount$(Release.EnvironmentName)` | This is the storageaccount name to use.                                                                                                                                                                                                          |
| ForcePublic                     | n.a.                                         | If you want to open your Storage Account publically, you need to pass this boolean to confirm you are willingly creating a public resource (to avoid unintended public resources). You can pass it as a switch without a value (`-ForcePublic`). |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Grant Public Access To Storage Account"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/Storage-Accounts/Grant-Public-Access-to-StorageAccount.ps1"
    arguments: "-StorageAccountResourceGroupName '$(StorageAccountResourceGroupName)'  -StorageAccountName '$(StorageAccountName)' -ForcePublic"
```

# Code

[Click here to download this script](../../../../src/Storage-Accounts/Grant-Public-Access-To-StorageAccount.ps1)

# Links

- [Azure CLI - az storage account update](https://docs.microsoft.com/en-us/cli/azure/storage/account?view=azure-cli-latest#az_storage_account_update)
