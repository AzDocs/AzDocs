[[_TOC_]]

# Description
This snippet will disable public access to an existing SQL Server.

# Parameters
Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.

| Parameter | Example Value | Description |
|--|--|--|
| SqlServerResourceGroupName | `myteam-testapi-$(Release.EnvironmentName)` | The name of the resource group the SQL server is in|
| SqlServerName | `somesqlserver$(Release.EnvironmentName)` | The name for the SQL Server resource. It's recommended to use just alphanumerical characters without hyphens etc.|
	

# Code
[Click here to download this script](../../../../src/SQL-Server/Public-Access/Disable-public-access-for-SQL-Server.ps1)


# Links

[Azure CLI - az-sql-server-show](https://docs.microsoft.com/en-us/cli/azure/sql/server?view=azure-cli-latest#az-sql-server-show)

[Azure CLI - az-sql-server-update](https://docs.microsoft.com/en-us/cli/azure/sql/server?view=azure-cli-latest#az-sql-server-update)