[[_TOC_]]

# Description

This snippet will remove a management lock from a resourcegroup and/or resource.

# Parameters

Some parameters from [General Parameter](/Azure/AzDocs-v1/Scripts) list.

| Parameter                | Required                        | Example Value                     | Description                                                                                                                                                                                                                                                     |
| ------------------------ | ------------------------------- | --------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ResourceName             | <input type="checkbox">         | `myapp$(Release.EnvironmentName)` | The name of the Azure Resource to remove the lock from. Make sure to pass `-IncludeResourceLock` when trying to remove a lock from a resource. If there are multiple resources with this name, the specified locks from all of these resources will be removed. |
| ResourceGroupName        | <input type="checkbox" checked> | `myrg$(Release.EnvironmentName)`  | The name of the resourcegroup to remove the lock from. Make sure to pass `-IncludeResourceGroupLock` when you want to remove a lock from a resourcegroup.                                                                                                       |
| IncludeResourceGroupLock | <input type="checkbox">         | `n.a.`                            | Switch to pass when you want to remove a lock from a resourcegroup.                                                                                                                                                                                             |
| IncludeResourceLock      | <input type="checkbox">         | `n.a.`                            | Switch to pass if you want to remove a lock from a resource.                                                                                                                                                                                                    |
| LockType                 | <input type="checkbox">         | `CanNotDelete`/`ReadOnly`         | The type of lock to remove. There are currently two options: `CanNotDelete` and `ReadOnly`. This defaults to `CanNotDelete`.                                                                                                                                    |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Delete Resource Lock"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/Generic/Delete-Resource-Lock.ps1"
    arguments: "-ResourceName '$(ResourceName)' -ResourceGroupName '$(ResourceGroupName)' -IncludeResourceGroupLock -IncludeResourceLock -LockType '$(LockType)'"
```

# Code

[Click here to download this script](../../../../src/Generic/Delete-Resource-Lock.ps1)

# Links

[Azure CLI - az group lock delete](https://docs.microsoft.com/en-us/cli/azure/group/lock?view=azure-cli-latest#az_group_lock_delete)

[Azure CLI - az resource list](https://docs.microsoft.com/en-us/cli/azure/resource?view=azure-cli-latest#az_resource_list)

[Azure CLI - az resource lock delete](https://docs.microsoft.com/en-us/cli/azure/resource/lock?view=azure-cli-latest#az_resource_lock_delete)
