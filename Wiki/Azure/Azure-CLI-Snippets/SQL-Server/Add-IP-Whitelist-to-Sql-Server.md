[[_TOC_]]

# Description
This snippet will whitelist the specified IP Range from the Azure SQL Server. If you leave the `CIDRToWhitelist` parameter empty, it will use the outgoing IP from where you execute this script.

# Parameters
| Parameter | Example Value | Description |
|--|--|--|
| SqlServerResourceGroupName | `myteam-testapi-$(Release.EnvironmentName)` | The name of the resource group the SQL Server is in. |
| SqlServerName | `somesqlserver$(Release.EnvironmentName)` | The name for the SQL Server resource. It's recommended to use just alphanumerical characters without hyphens etc. |
| CIDRToWhitelist | `52.43.65.123/32` | The IP range to whitelist in [CIDR notation](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing#CIDR_notation). Leave this field empty to use the outgoing IP from where you execute this script. |

# Code
[Click here to download this script](../../../../src/SQL-Server/Add-IP-Whitelist-to-Sql-Server.ps1)

# Links

[Azure CLI - az sql server firewall-rule create](https://docs.microsoft.com/en-us/cli/azure/sql/server/firewall-rule?view=azure-cli-latest#az_sql_server_firewall_rule_create)