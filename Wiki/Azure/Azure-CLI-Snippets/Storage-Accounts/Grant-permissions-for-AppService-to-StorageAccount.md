[[_TOC_]]

# Description
This snippet will create assign a role to the given appservice identity for a existing storageaccount. This is needed for when you want to assign permissions to a managed identity for example.

# Parameters
Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.

| Parameter | Example Value | Description |
|--|--|--|
| storageResourceGroupName | `myteam-testapi-$(Release.EnvironmentName)` | Name of resourcegroup where your storage account is in |
| appServiceResourceGroupName | `myteam-testapi-$(Release.EnvironmentName)` | Name of resourcegroup where your AppService is in |
| appServiceName | `mytestapp-$(Release.EnvironmentName)` | Name of the appservice to grant permissions for |
| roleToAssign | `Storage Blob Data Contributor` | This is the rolename to assign. Please refer to "Roles" under "Access control (IAM)" in your Storage Account for role names. |
| storageAccountName | `myteststgaccount$(Release.EnvironmentName)` | This is the storageaccount name to use. |

# Code
[Click here to download this script](../../../../src/Storage-Accounts/Grant-permissions-for-AppService-to-StorageAccount.ps1)

# Links

- [Azure CLI - az-webapp-identity-show](https://docs.microsoft.com/en-us/cli/azure/webapp/identity?view=azure-cli-latest#az-webapp-identity-show)

- [Azure CLI - az-storage-account-show](https://docs.microsoft.com/en-us/cli/azure/storage/account?view=azure-cli-latest#az-storage-account-show)

- [Azure CLI - az-role-assignment-create](https://docs.microsoft.com/en-us/cli/azure/role/assignment?view=azure-cli-latest#az-role-assignment-create)

- [Authorize access to blobs and queues using Azure Active Directory](https://docs.microsoft.com/en-us/azure/storage/common/storage-auth-aad)

- [Using the Microsoft.Azure.Services.AppAuthentication library for .NET](https://docs.microsoft.com/en-us/azure/app-service/overview-managed-identity?tabs=dotnet#asal)
