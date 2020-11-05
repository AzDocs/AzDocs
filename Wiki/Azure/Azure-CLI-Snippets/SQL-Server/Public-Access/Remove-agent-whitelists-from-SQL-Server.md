[[_TOC_]]

# Description
This snippet will remove the whitelist rule for the Azure DevOps agent (or actually the executing machine) on the specified SQL Server.

# Parameters
Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.

| Parameter | Example Value | Description |
|--|--|--|
| sqlServerResourceGroupName | `myteam-testapi-$(Release.EnvironmentName)` | The name of the resource group the SQL server is in.|
| sqlServerName | `somesqlserver$(Release.EnvironmentName)` | The name for the SQL Server resource. It's recommended to use just alphanumerical characters without hyphens etc.|

# Code
[Click here to download this script](../../../../src/SQL-Server/Public-Access/Remove-agent-whitelists-from-SQL-Server.ps1)

# Links

[Azure CLI - az-sql-server-firewall-rule-delete](https://docs.microsoft.com/en-us/cli/azure/sql/server/firewall-rule?view=azure-cli-latest#az-sql-server-firewall-rule-delete)