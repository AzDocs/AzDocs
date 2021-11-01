[[_TOC_]]

# Description

This snippet will create a queue inside a specified (pre-existing) storageaccount.

# Parameters

Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.

| Parameter                       | Required                        | Example Value                                                                                                                                   | Description                                                           |
| ------------------------------- | ------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------- |
| StorageAccountName              | <input type="checkbox" checked> | `myteststgaccount$(Release.EnvironmentName)`                                                                                                    | The name of the storageaccount which will be used                     |
| QueueName                       | <input type="checkbox" checked> | `images`                                                                                                                                        | The name of the queue to create.                                      |
| StorageAccountResourceGroupName | <input type="checkbox" checked> | `my-resource-group`                                                                                                                             | The name of the resourcegroup in which the storage account resides.   |
| LogAnalyticsWorkspaceResourceId | <input type="checkbox" checked> | `/subscriptions/<subscriptionid>/resourceGroups/<resourcegroup>/providers/Microsoft.OperationalInsights/workspaces/<loganalyticsworkspacename>` | The Log Analytics Workspace the diagnostic setting will be linked to. |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Create Queue in StorageAccount"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/Storage-Accounts/Create-Queue-in-StorageAccount.ps1"
    arguments: "-StorageAccountName '$(StorageAccountName)' -QueueName '$(QueueName)' -StorageAccountResourceGroupName '$(StorageAccountResourceGroupName)' -LogAnalyticsWorkspaceResourceId '$(LogAnalyticsWorkspaceResourceId)'"
```

# Code

[Click here to download this script](../../../../src/Storage-Accounts/Create-Queue-in-Storageaccount.ps1)

# Links

[Azure CLI - az storage queue create](https://docs.microsoft.com/nl-nl/cli/azure/storage/queue?view=azure-cli-latest#az_storage_queue_create)

[Azure CLI - az monitor diagnostic-settings-create](https://docs.microsoft.com/nl-nl/cli/azure/monitor/diagnostic-settings?view=azure-cli-latest#az_monitor_diagnostic_settings_create)
