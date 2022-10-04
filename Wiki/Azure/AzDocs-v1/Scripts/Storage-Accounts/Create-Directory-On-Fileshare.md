[[_TOC_]]

# Description

This snippet will create a directory inside a fileshare (on a storageaccount).

# Parameters

Some parameters from [General Parameter](/Azure/AzDocs-v1/Scripts) list.

| Parameter                       | Required                        | Example Value                                | Description                                            |
| ------------------------------- | ------------------------------- | -------------------------------------------- | ------------------------------------------------------ |
| StorageAccountResourceGroupname | <input type="checkbox" checked> | `MyTeam-TestApi-$(Release.EnvironmentName)`  | The resourcegroup where the storageaccount resides in. |
| StorageAccountName              | <input type="checkbox" checked> | `myteststgaccount$(Release.EnvironmentName)` | The name of the storageaccount which will be used      |
| FileshareName                   | <input type="checkbox" checked> | `images`                                     | The name of the fileshare                              |
| DirectoryPath                   | <input type="checkbox" checked> | `some/file/path`                             | The path of the directory to create.                   |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Create Directory on Fileshare"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/Storage-Accounts/Create-Directory-On-Fileshare.ps1"
    arguments: "-StorageAccountName '$(StorageAccountName)' -FileshareName '$(FileshareName)' -DirectoryPath '$(DirectoryPath)' -StorageAccountResourceGroupname '$(StorageAccountResourceGroupname)'"
```

# Code

[Click here to download this script](../../../../src/Storage-Accounts/Create-Directory-On-Fileshare.ps1)

# Links

[Azure CLI - az storage directory create](https://docs.microsoft.com/en-us/cli/azure/storage/directory?view=azure-cli-latest#az_storage_directory_create)
