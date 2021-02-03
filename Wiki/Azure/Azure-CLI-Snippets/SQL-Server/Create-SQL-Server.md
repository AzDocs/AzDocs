[[_TOC_]]

# Description
This snippet will create a SQL Server if it does not exist within a given subnet. It will also make sure that public access is denied by default. It will whitelist the application subnet so your app can connect to the SQL Server within the vnet. All the needed components (private endpoint, service endpoint etc) will be created too.

IMPORTANT NOTE: Enable the `Access service principal details in script` checkbox in the Azure CLI step. This is needed for the last few lines of script which are built in Azure PowerShell.

# Parameters
Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.

| Parameter | Example Value | Description |
|--|--|--|
| SqlServerSubscriptionId | `2cf65221-ba2c-42ba-987b-ef8981519431` | The subscription ID (or name) on which the SQL Server should be provisioned. |
| SqlServerPrivateEndpointVnetResourceGroupName | `sharedservices-rg` | The ResourceGroup where your VNET, for your SQL Server Private Endpoint, resides in. |
| SqlServerPrivateEndpointVnetName | `my-vnet-$(Release.EnvironmentName)` | The name of the VNET to place the SQL Server Private Endpoint in. |
| SqlServerPrivateEndpointSubnetName | `app-subnet-3` | The name of the subnet you want your sql server's private endpoint to be in |
| ApplicationVnetResourceGroupName | `sharedservices-rg` | The ResourceGroup where your VNET, for your appservice, resides in. |
| ApplicationVnetName | `my-vnet-$(Release.EnvironmentName)` | The name of the VNET the appservice is in|
| ApplicationSubnetName | `app-subnet-4` | The name of the subnet the appservice is in |
| SqlServerPassword | `#$mydatabas**e` | The password for the sqlserverusername |
| SqlServerUsername | `rob` | The admin username for the sqlserver |
| SqlServerName | `somesqlserver$(Release.EnvironmentName)` | The name for the SQL Server resource. It's recommended to use just alphanumerical characters without hyphens etc.|
| SqlServerResourceGroupName | `myteam-testapi-$(Release.EnvironmentName)` | The name of the resourcegroup you want your sql server to be created in |
| DNSZoneResourceGroupName | `MyDNSZones-$(Release.EnvironmentName)` | Make sure to use the shared DNS Zone resource group (you can only register a zone once per subscription). |
| SqlServerPrivateDnsZoneName | `privatelink.database.windows.net` | The name of DNS zone where your private endpoint will be created in. If you are unsure use `privatelink.database.windows.net` |
| LogAnalyticsWorkspaceResourceId | `/subscriptions/<subscriptionid>/resourceGroups/<resourcegroup>/providers/Microsoft.OperationalInsights/workspaces/<loganalyticsworkspacename>` | The log analytics workspace to write the auditing logs to for this SQL Server instance |

# Code
[Click here to download this script](../../../../src/SQL-Server/Create-SQL-Server.ps1)

# Links

[Azure CLI - az-network-private-link-resource-list](https://docs.microsoft.com/en-us/cli/azure/network/private-link-resource?view=azure-cli-latest#az-network-private-link-resource-list)

[Azure CLI - az-sql-server-create](https://docs.microsoft.com/en-us/cli/azure/sql/server?view=azure-cli-latest#az-sql-server-create)

[Azure CLI - az-network-vnet-subnet-update](https://docs.microsoft.com/en-us/cli/azure/network/vnet/subnet?view=azure-cli-latest#az-network-vnet-subnet-update)

[Azure CLI - az-sql-server-show](https://docs.microsoft.com/en-us/cli/azure/sql/server?view=azure-cli-latest#az-sql-server-show)

[Azure CLI - az-network-private-endpoint-create](https://docs.microsoft.com/en-us/cli/azure/network/private-endpoint?view=azure-cli-latest#az-network-private-endpoint-create)

[Azure CLI - az-network-private-dns-zone-show](https://docs.microsoft.com/en-us/cli/azure/ext/privatedns/network/private-dns/zone?view=azure-cli-latest#ext-privatedns-az-network-private-dns-zone-show)

[Azure CLI - az-network-private-dns-zone-create](https://docs.microsoft.com/en-us/cli/azure/ext/privatedns/network/private-dns/zone?view=azure-cli-latest#ext-privatedns-az-network-private-dns-zone-create)

[Azure CLI - az-network-private-dns-link-vnet-show](https://docs.microsoft.com/en-us/cli/azure/network/private-dns/link/vnet?view=azure-cli-latest#az-network-private-dns-link-vnet-show)

[Azure CLI - az-network-private-dns-link-vnet-create](https://docs.microsoft.com/en-us/cli/azure/network/private-dns/link/vnet?view=azure-cli-latest#az-network-private-dns-link-vnet-create)

[Azure CLI - az-network-private-endpoint-dns-zone-group-create](https://docs.microsoft.com/en-us/cli/azure/network/private-endpoint/dns-zone-group?view=azure-cli-latest#az-network-private-endpoint-dns-zone-group-create)

[Azure CLI - az-network-vnet-subnet-show](https://docs.microsoft.com/en-us/cli/azure/network/vnet/subnet?view=azure-cli-latest#az-network-vnet-subnet-show)

[Azure CLI - az-sql-server-vnet-rule-create](https://docs.microsoft.com/en-us/cli/azure/sql/server/vnet-rule?view=azure-cli-latest#az-sql-server-vnet-rule-create)

[Azure CLI - az-sql-server-update](https://docs.microsoft.com/en-us/cli/azure/sql/server?view=azure-cli-latest#az-sql-server-update)