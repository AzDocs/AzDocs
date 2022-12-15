[[_TOC_]]

# Description

This snippet will create assign a role to the given appservice identity for a existing storageaccount. This is needed for when you want to assign permissions to a managed identity for example.

# Parameters

Some parameters from [General Parameter](/Azure/AzDocs-v1/Scripts) list.

| Parameter                   | Example Value                                | Description                                                                                                                  |
| --------------------------- | -------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| StorageResourceGroupName    | `myteam-testapi-$(Release.EnvironmentName)`  | Name of resourcegroup where your storage account is in                                                                       |
| AppServiceResourceGroupName | `myteam-testapi-$(Release.EnvironmentName)`  | Name of resourcegroup where your AppService is in                                                                            |
| AppServiceName              | `mytestapp-$(Release.EnvironmentName)`       | Name of the appservice to grant permissions for                                                                              |
| AppServiceSlotName          | `staging`                                    | OPTIONAL By default the production slot is used, use this variable to use a different slot.                                  |
| RoleToAssign                | `Storage Blob Data Contributor`              | This is the rolename to assign. Please refer to "Roles" under "Access control (IAM)" in your Storage Account for role names. |
| StorageAccountName          | `myteststgaccount$(Release.EnvironmentName)` | This is the storageaccount name to use.                                                                                      |
| ApplyToAllSlots             | `$true`/`$false`                             | Applies the current script to all slots revolving the appservice                                                             |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Grant Permissions for AppService to StorageAccount"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/Storage-Accounts/Grant-Permissions-for-AppService-to-StorageAccount.ps1"
    arguments: "-StorageResourceGroupName '$(StorageResourceGroupName)' -AppServiceResourceGroupName '$(AppServiceResourceGroupName)' -AppServiceName '$(AppServiceName)' -StorageAccountName '$(StorageAccountName)' -RoleToAssign '$(RoleToAssign)' -AppServiceSlotName '$(AppServiceSlotName)' -ApplyToAllSlots $(ApplyToAllSlots)"
```

# Code

[Click here to download this script](../../../../../src/Storage-Accounts/Grant-permissions-for-AppService-to-StorageAccount.ps1)

# Links

- [Azure CLI - az-webapp-identity-show](https://docs.microsoft.com/en-us/cli/azure/webapp/identity?view=azure-cli-latest#az-webapp-identity-show)

- [Azure CLI - az-storage-account-show](https://docs.microsoft.com/en-us/cli/azure/storage/account?view=azure-cli-latest#az-storage-account-show)

- [Azure CLI - az-role-assignment-create](https://docs.microsoft.com/en-us/cli/azure/role/assignment?view=azure-cli-latest#az-role-assignment-create)

- [Authorize access to blobs and queues using Azure Active Directory](https://docs.microsoft.com/en-us/azure/storage/common/storage-auth-aad)

- [Using the Microsoft.Azure.Services.AppAuthentication library for .NET](https://docs.microsoft.com/en-us/azure/app-service/overview-managed-identity?tabs=dotnet#asal)
