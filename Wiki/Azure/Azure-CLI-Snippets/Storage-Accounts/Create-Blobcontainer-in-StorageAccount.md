[[_TOC_]]

# Description

This snippet will create a blobcontainer inside a specified (pre-existing) storageaccount.

# Parameters

Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.

| Parameter          | Example Value                                | Description                                       |
| ------------------ | -------------------------------------------- | ------------------------------------------------- |
| StorageAccountName | `myteststgaccount$(Release.EnvironmentName)` | The name of the storageaccount which will be used |
| BlobContainerName  | `images`                                     | The name of the blobcontainer                     |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
        - task: AzureCLI@2
           displayName: 'Create Blobcontainer in StorageAccount'
           condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
           inputs:
               azureSubscription: '${{ parameters.SubscriptionName }}'
               scriptType: pscore
               scriptPath: '$(Pipeline.Workspace)/AzDocs/Storage-Accounts/Create-Blobcontainer-in-StorageAccount.ps1'
               arguments: "-StorageAccountName '$(StorageAccountName)' -BlobContainerName '$(BlobContainerName)'"
```

# Code

[Click here to download this script](../../../../src/Storage-Accounts/Create-Blobcontainer-in-Storageaccount.ps1)

# Links

[Azure CLI - az storage container create](https://docs.microsoft.com/en-us/cli/azure/storage/container?view=azure-cli-latest#az-storage-container-create)
