[[_TOC_]]

# Description
This snippet will whitelist the specified IP Range from the Azure SQL Server. If you leave the `CIDRToWhitelist` parameter empty, it will use the outgoing IP from where you execute this script.

# Parameters
| Parameter | Required | Example Value | Description |
|--|--|--|--|
| SqlServerResourceGroupName | <input type="checkbox" checked> | `myteam-testapi-$(Release.EnvironmentName)` | The name of the resource group the SQL Server is in. |
| SqlServerName | <input type="checkbox" checked> | `somesqlserver$(Release.EnvironmentName)` | The name for the SQL Server resource. It's recommended to use just alphanumerical characters without hyphens etc. |
| AccessRuleName | <input type="checkbox"> | `company hq` | You can override the name for this accessrule. If you leave this empty, the `CIDRToWhitelist` will be used for the naming (automatically). We recommend to leave this empty for ephemeral whitelists like Azure DevOps Hosted Agent ip's. |
| CIDRToWhitelist | <input type="checkbox"> | `52.43.65.123/32` | IP range in [CIDR](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing) notation that should be whitelisted. If you leave this value empty, it will whitelist the machine's ip where you're running the script from. |

# Code
[Click here to download this script](../../../../src/SQL-Server/Add-IP-Whitelist-to-Sql-Server.ps1)

# Links

[Azure CLI - az sql server firewall-rule create](https://docs.microsoft.com/en-us/cli/azure/sql/server/firewall-rule?view=azure-cli-latest#az_sql_server_firewall_rule_create)