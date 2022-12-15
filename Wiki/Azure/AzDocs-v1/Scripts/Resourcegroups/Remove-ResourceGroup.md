[[_TOC_]]

# Description

This snippet will delete a Resource Group if it exists.

# Parameters

| Parameter          | Required                        | Example Value                               | Description                                                            |
| ------------------ | ------------------------------- | ------------------------------------------- | ---------------------------------------------------------------------- |
| ResourceGroupName  | <input type="checkbox" checked> | `myteam-testapi-$(Release.EnvironmentName)` | The name for the resource group                                        |
| RetryDeletionCount | <input type="checkbox">         | `3`                                         | Retry count for the deletion of the resourcegroup. Default value is 3. |

# YAML task

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Remove ResourceGroup"
  condition: eq(variables['ResourceDeletion.ResourceGroup.Enabled'], 'true')
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/Resourcegroup/Remove-ResourceGroup.ps1"
    arguments: "-ResourceGroupName '$(ResourceGroupName)' -RetryDeletionCount '$(RetryDeletionCount)'"
```

# Code

[Click here to download this script](../../../../../src/Resourcegroup/Remove-ResourceGroup.ps1)

# Links

[Azure CLI - az group create](https://docs.microsoft.com/en-us/cli/azure/group?view=azure-cli-latest#az-group-delete)
