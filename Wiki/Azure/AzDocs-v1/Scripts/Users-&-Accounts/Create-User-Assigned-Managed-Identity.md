[[_TOC_]]

# Description

This snippet will create a user assigned managed identity. 

# Parameters

| Parameter                  | Required                        | Example Value              | Description                                                                                                                                |
| -------------------------- | ------------------------------- | -------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| UserAssignedManagedIdentityName           | <input type="checkbox" checked  | `my-managed-identity`       | The name for the user assigned managed identity.                                                                                                     |
| UserAssignedManagedIdentityResourceGroupName        | <input type="checkbox" checked> | `my-resource-group` | The resourcegroup for the user assigned managed identity.                                                                                                         |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Create User Assigned Managed Identity"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/Users-and-Accounts/Create-User-Assigned-Managed-Identity.ps1"
    arguments: "-UserAssignedManagedIdentityName '$(UserAssignedManagedIdentityName)' -UserAssignedManagedIdentityResourceGroupName '$(UserAssignedManagedIdentityResourceGroupName)'"
```

# Code

[Click here to download this script](../../../../src/Users-and-Accounts/Create-User-Assigned-Managed-Identity.ps1)

# Links

[Azure CLI - az identity create](https://learn.microsoft.com/en-us/cli/azure/identity?view=azure-cli-latest#az-identity-create)