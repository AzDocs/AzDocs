[[_TOC_]]

# Description
This snippet will mount a blob container or fileshare in your WebApp Container. This is especially useful if you run your own custom container within a webapp and you need persistent storage.

We'd always recommend to try to communicate with Azure Storage Accounts from your code instead of trying to mount it within you infra level, but this is a good fallback.

# Parameters
Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.
| Parameter | Required | Example Value | Description |
|--|--|--|--|
| AppServiceResourceGroupName | <input type="checkbox" checked> | `MyTeam-SomeApi-$(Release.EnvironmentName)` | The resourcegroup where the AppService resides in. |
| AppServiceName | <input type="checkbox" checked> | `App-Service-name` | Name of the app service to bind the domainname to. | 
| StorageAccountResourceGroupname | <input type="checkbox" checked> | `MyTeam-TestApi-$(Release.EnvironmentName)`  | The resourcegroup where the storageaccount resides in. |
| StorageAccountName | <input type="checkbox" checked> | `myteststgaccount$(Release.EnvironmentName)` | The name of the storageaccount which will be used. |
| BlobOrFileShareName | <input type="checkbox" checked> | `mysharename` | The name of the fileshare (when using StorageShareType=`AzureFiles`) or blobcontainer (when using StorageShareType=`AzureBlob`). |
| ContainerMountPath | <input type="checkbox" checked> | `/my/mount/point` | The point inside your container to mount the blobcontainer/fileshare. |
| StorageShareType | <input type="checkbox"> | `AzureFiles` | The type of storage to mount. Options are `AzureFiles` for Fileshares (read/write) and `AzureBlob` for Blobstorage (read-only). Defaults to `AzureFiles`. |
| AppServiceDeploymentSlotName | <input type="checkbox"> | `staging` |  Name of the deployment slot to add the binding to. This is an optional field. |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
        - task: AzureCLI@2
          displayName: 'Mount Persistent Fileshare in Container'
          inputs:
            azureSubscription: '${{ parameters.SubscriptionName }}'
            scriptType: pscore
            scriptPath: '$(Pipeline.Workspace)/AzDocs/App-Services/Mount-StorageAccount-In-Container.ps1'
            arguments: '-AppServiceResourceGroupName "$(AppServiceResourceGroupName)" -AppServiceName "$(AppServiceName)" -StorageAccountResourceGroupname "$(StorageAccountResourceGroupname)" -StorageAccountName "$(StorageAccountName)" -BlobOrFileShareName "$(BlobOrFileShareName)" -ContainerMountPath "$(ContainerMountPath)" -StorageShareType "$(StorageShareType)" -AppServiceDeploymentSlotName "$(AppServiceDeploymentSlotName)"'
```

# Code

[Click here to download this script](../../../../src/App-Services/Mount-StorageAccount-In-Container.ps1)

# Links

[Azure CLI - az storage account keys list](https://docs.microsoft.com/en-us/cli/azure/storage/account/keys?view=azure-cli-latest#az_storage_account_keys_list)

[Azure CLI - az webapp config storage-account add](https://docs.microsoft.com/en-us/cli/azure/webapp/config/storage-account?view=azure-cli-latest#az_webapp_config_storage_account_add)

