[[_TOC_]]

# Description

This snippet will give the appservice identity the permissions to read/write data from/to a SQL Database.

# Parameters

Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.

| Parameter | Example Value | Description |
|--|--|--|
| SqlServerResourceGroupName | `myteam-testapi-$(Release.EnvironmentName)` | The name of the resourcegroup where the SQL server was created |
| SqlServerName | `somesqlserver$(Release.EnvironmentName)` | The name of the SQL Server to give permissions on |
| SqlDatabaseName | `mydb` | The name of the SQL Database to give permissions on |
| ServiceUserEmail | `my_user@domain.com` | The emailaddress of the service account to use (this cannot be a service principal unfortunately) |
| ServiceUserObjectId | `ba7d0b10-3bfd-4d40-b6b4-a60b3476582f` | The object ID of the service user. See [Get ObjectID for ServiceUser](/Azure/Azure-CLI-Snippets/Get-ObjectID-for-ServiceUser) for details how to retrieve this ObjectId. |
| ServiceUserPassword | `Th15iSMyP@ssW0rD123!` | The name for the SQL Server resource. It's recommended to use just alphanumerical characters without hyphens etc.|
| AppServiceName | `myappservice-$(Release.EnvironmentName)` | The name of the AppService to give permissions for |
| AppServiceSlotName | `staging` | OPTIONAL Name of the AppService slot to grand permissions to. If not defined. The default production slot will be used. |

# Code

[Click here to download this script](../../../../src/SQL-Server/Grant-AppService-dataread-write-ddladmin-rights-on-SQL-Server.ps1)

# Links

[Azure CLI - az-sql-server-ad-admin-create](https://docs.microsoft.com/en-us/cli/azure/sql/server/ad-admin?view=azure-cli-latest#az-sql-server-ad-admin-create)

[Azure CLI - Secure Azure SQL Database connection from App Service using a managed identity](https://docs.microsoft.com/en-us/azure/app-service/app-service-web-tutorial-connect-msi)

[Azure CLI - az-login](https://docs.microsoft.com/en-us/cli/azure/reference-index?view=azure-cli-latest#az-login)

[Azure CLI - az-account-get-access-token](https://docs.microsoft.com/en-us/cli/azure/account?view=azure-cli-latest#az-account-get-access-token)