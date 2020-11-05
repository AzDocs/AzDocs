[[_TOC_]]

# Description
This snippet will create a SQL database on a specified existing SQL Server (Refer to [Create SQL Server](/Azure/Azure-CLI-Snippets/SQL-Server/Create-SQL-Server) to create a SQL Server instance)

# Parameters
Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.

| Parameter | Example Value | Description |
|--|--|--|
| sqlServerResourceGroupName | `myteam-testapi-$(Release.EnvironmentName)` | The name of the Resource Group the SQL server was created |
| sqlServerName | `somesqlserver$(Release.EnvironmentName)` | The name for the SQL Server resource. This has to be an existing SQL Server instance. |
| sqlDatabaseName | `mydatabase` | The name for the SQL Database to create. Stick to alphanumerical and hyphens etc |
| sqlDatabaseSkuName | `S1` | The skuname for the SQL database to use. Information about performance & pricing can be found [here](https://azure.microsoft.com/en-us/pricing/details/sql-database/single/) |

# Code
[Click here to download this script](../../../../src/SQL-Server/Create-SQL-Database.ps1)

# Links

[Azure CLI - az-sql-db-create](https://docs.microsoft.com/en-us/cli/azure/sql/db?view=azure-cli-latest#az-sql-db-create)
