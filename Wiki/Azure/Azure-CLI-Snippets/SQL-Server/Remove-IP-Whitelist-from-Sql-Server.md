[[_TOC_]]

# Description
This snippet will remove the specified IP Range from the Azure SQL Server. If you leave the `CIDRToRemoveFromWhitelist` parameter empty, it will use the outgoing IP from where you execute this script.

> NOTE: It is strongly suggested to set the condition, of this task in the pipeline, to always run. Even if your previous steps have failed. This is to avoid unintended whitelists whenever pipelines crash in the middle of something.

# Parameters
| Parameter | Example Value | Description |
|--|--|--|
| SqlServerResourceGroupName | `myteam-testapi-$(Release.EnvironmentName)` | The name of the resource group the SQL Server is in|
| SqlServerName | `somesqlserver$(Release.EnvironmentName)` | The name for the SQL Server resource. It's recommended to use just alphanumerical characters without hyphens etc. |
| CIDRToRemoveFromWhitelist | `52.43.65.123/32` | The IP range, to remove the whitelist for, in [CIDR notation](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing#CIDR_notation). Leave this field empty to use the outgoing IP from where you execute this script. |

# Code
[Click here to download this script](../../../../src/SQL-Server/Remove-IP-Whitelist-from-Sql-Server.ps1)

# Links

[Azure CLI - az sql server firewall-rule delete](https://docs.microsoft.com/en-us/cli/azure/sql/server/firewall-rule?view=azure-cli-latest#az_sql_server_firewall_rule_delete)