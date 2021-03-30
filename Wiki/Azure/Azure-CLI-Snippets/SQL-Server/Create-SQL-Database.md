[[_TOC_]]

# Description
This snippet will create a SQL database on a specified existing SQL Server (Refer to [Create SQL Server](/Azure/Azure-CLI-Snippets/SQL-Server/Create-SQL-Server) to create a SQL Server instance)

# Parameters
Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.

| Parameter | Required Provisioned  | Required Serverless |  Example Value | Description |
|--|--|--|--|--|
| SqlServerResourceGroupName | <input type="checkbox" checked> | <input type="checkbox" checked> | `myteam-testapi-$(Release.EnvironmentName)` | The name of the Resource Group the SQL server was created |
| SqlServerName | <input type="checkbox" checked> | <input type="checkbox" checked> | `somesqlserver$(Release.EnvironmentName)` | The name for the SQL Server resource. This has to be an existing SQL Server instance. |
| SqlDatabaseName | <input type="checkbox" checked> | <input type="checkbox" checked> | `mydatabase` | The name for the SQL Database to create. Stick to alphanumerical and hyphens etc |
| SqlDatabaseSkuName | <input type="checkbox" checked> | <input type="checkbox"> | `S1` | The skuname for the SQL database to use. Information about performance & pricing can be found [here](https://azure.microsoft.com/en-us/pricing/details/sql-database/single/) | `mydatabase` | The name for the SQL Database to create. Stick to alphanumerical and hyphens etc |
| SqlDatabaseEdition | <input type="checkbox"> | <input type="checkbox" checked> |  `GeneralPurpose` | The SQL Database edition you want to use. Options are `Basic`, `Standard`, `Premium`, `GeneralPurpose`, `BusinessCritical` or `Hyperscale` |
| SqDatabaseFamily | <input type="checkbox"> | <input type="checkbox" checked> |  `Gen5` | The Azure SQL offering generation you want to use. Options are: `Gen4` or `Gen5`. |
| SqlDatabaseComputeModel | <input type="checkbox"> | <input type="checkbox" checked> |  `Serverless` | The compute model to use. Options are: `Provisioned` or `Serverless`. |
| SqlDatabaseAutoPauseDelayInMinutes | <input type="checkbox"> | <input type="checkbox" checked> |  `60` | The amount of minutes before the SQL Server goes to sleep mode. This is only recommended for non-production environments. NOTE: The first query after coming out of sleep will fail. |
| SqlDatabaseMinCapacity | <input type="checkbox"> | <input type="checkbox" checked> |  `2` | The minimum capacity of this database. in the vCore model this equals the number of vCores you want. |
| SqlDatabaseMaxCapacity | <input type="checkbox"> | <input type="checkbox" checked> |  `8` | The maximum allowed capacity of this database. in the vCore model this equals the number of vCores you want. |
| SqlDatabaseBackupStorageRedundancy | <input type="checkbox"> | <input type="checkbox" checked> |  `Zone` | The level of backup redundancy you want. Options are `Local`, `Zone`, `Geo`. |
| SqlDatabaseMaxStorageSize | <input type="checkbox"> | <input type="checkbox" checked> |  `50GB` | The amount of storage including the unit of data. Examples: `50GB`, `250GB` or `1TB` |

# Code
[Click here to download this script](../../../../src/SQL-Server/Create-SQL-Database.ps1)

# Links

[Azure CLI - az-sql-db-create](https://docs.microsoft.com/en-us/cli/azure/sql/db?view=azure-cli-latest#az-sql-db-create)
