[[_TOC_]]

# Description

This snippet will remove the public access on your storage account.

# Parameters

Some parameters from [General Parameter](/Azure/AzDocs-v1/Scripts) list.

| Parameter                       | Example Value                                | Description                                            |
| ------------------------------- | -------------------------------------------- | ------------------------------------------------------ |
| StorageAccountResourceGroupName | `myteam-testapi-$(Release.EnvironmentName)`  | Name of resourcegroup where your storage account is in |
| StorageAccountName              | `myteststgaccount$(Release.EnvironmentName)` | This is the storageaccount name to use.                |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Remove Public Access from Storage Account"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/Storage-Accounts/Remove-Public-Access-from-StorageAccount.ps1"
    arguments: "-StorageAccountResourceGroupName '$(StorageAccountResourceGroupName)'  -StorageAccountName '$(StorageAccountName)'"
```

# Code

[Click here to download this script](../../../../../src/Storage-Accounts/Remove-Public-Access-from-StorageAccount.ps1)

# Links

- [Azure CLI - az storage account update](https://docs.microsoft.com/en-us/cli/azure/storage/account?view=azure-cli-latest#az_storage_account_update)
