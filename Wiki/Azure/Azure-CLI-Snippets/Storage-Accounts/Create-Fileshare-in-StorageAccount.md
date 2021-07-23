[[_TOC_]]

# Description

This snippet will create a fileshare inside a specified (pre-existing) storageaccount.

# Parameters

Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.

| Parameter                       | Example Value                                | Description                                           |
| ------------------------------- | -------------------------------------------- | ----------------------------------------------------- |
| StorageAccountResourceGroupname | `MyTeam-TestApi-$(Release.EnvironmentName)`  | The resourcegroup where the storageaccount resides in |
| StorageAccountName              | `myteststgaccount$(Release.EnvironmentName)` | The name of the storageaccount which will be used     |
| FileshareName                   | `images`                                     | The name of the fileshare                             |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
        - task: AzureCLI@2
           displayName: 'Create Fileshare in StorageAccount'
           condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
           inputs:
               azureSubscription: '${{ parameters.SubscriptionName }}'
               scriptType: pscore
               scriptPath: '$(Pipeline.Workspace)/AzDocs/Storage-Accounts/Create-Fileshare-in-StorageAccount.ps1'
               arguments: "-StorageAccountResourceGroupname '$(StorageAccountResourceGroupname)' -StorageAccountName '$(StorageAccountName)' -FileshareName '$(FileshareName)'"
```

# Code

[Click here to download this script](../../../../src/Storage-Accounts/Create-Fileshare-in-Storageaccount.ps1)

# Links

[Azure CLI - az storage share create](https://docs.microsoft.com/en-us/cli/azure/storage/share?view=azure-cli-latest#az_storage_share_create)
