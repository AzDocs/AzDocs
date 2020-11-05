[[_TOC_]]

# Description
This snippet will create a PostgreSQL database on a specified existing PostgreSQL Server (Refer to [Create PostgreSQL Server](/Azure/Azure-CLI-Snippets/PostgreSQL/Create-PostgreSQL-Server) to create a SQL Server instance)

# Parameters
Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.

| Parameter | Example Value | Description |
|--|--|--|
| sqlServerResourceGroupName | `myteam-testapi-$(Release.EnvironmentName)` | The name of the Resource Group the SQL server was created |
| sqlServerName | `somesqlserver$(Release.EnvironmentName)` | The name for the PostgreSQL Server resource. This has to be an existing PostgreSQL Server instance. |
| sqlDatabaseName | `mydatabase` | The name for the PostgreSQL Database to create. Stick to alphanumerical and hyphens etc |

# Code
[Click here to download this script](../../../../src/PostgreSQL/Create-PostgreSQL-Database.ps1)

# Links

[Azure CLI - az postgres db create](https://docs.microsoft.com/en-us/cli/azure/postgres/db?view=azure-cli-latest#az_postgres_db_create)
