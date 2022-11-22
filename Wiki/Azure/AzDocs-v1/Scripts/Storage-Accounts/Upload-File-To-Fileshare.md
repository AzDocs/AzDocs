[[_TOC_]]

# Description

This snippet will upload a file to a fileshare.

# Parameters

Some parameters from [General Parameter](/Azure/AzDocs-v1/Scripts) list.

| Parameter                       | Required                        | Example Value                                | Description                                            |
| ------------------------------- | ------------------------------- | -------------------------------------------- | ------------------------------------------------------ |
| StorageAccountResourceGroupname | <input type="checkbox" checked> | `MyTeam-TestApi-$(Release.EnvironmentName)`  | The resourcegroup where the storageaccount resides in. |
| StorageAccountName              | <input type="checkbox" checked> | `myteststgaccount$(Release.EnvironmentName)` | The name of the storageaccount which will be used      |
| FileshareName                   | <input type="checkbox" checked> | `images`                                     | The name of the fileshare                              |
| SourceFilePath                  | <input type="checkbox" checked> | `some/file/path`                             | The path of the source file to upload.                        |
| DestinationPath                 | <input type="checkbox">         | `some/file/path`                             | The path on the fileshare to upload the file to.                        |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Upload file to Fileshare"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/Storage-Accounts/Upload-File-To-Fileshare.ps1"
    arguments: "-StorageAccountName '$(StorageAccountName)' -StorageAccountResourceGroupname '$(StorageAccountResourceGroupname)' -FileshareName '$(FileshareName)' -SourceFilePath '$(SourceFilePath)' -DestinationPath '$(DestinationPath)'"
```

# Code

[Click here to download this script](../../../../src/Storage-Accounts/Upload-file-to-file-share.ps1)

# Links

[Azure CLI - az storage file upload](https://learn.microsoft.com/en-us/cli/azure/storage/file?view=azure-cli-latest#az-storage-file-upload)
