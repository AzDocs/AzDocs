[[_TOC_]]

# Description
This snippet will create a PostgreSQL Server if it does not exist within a given subnet. It will whitelist the application subnet so your app can connect to the SQL Server within the vnet. All the needed components (private endpoint, service endpoint etc) will be created too.

# Parameters
Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.

| Parameter | Example Value | Description |
|--|--|--|
| PostgreSqlServerPrivateEndpointVnetResourceGroupName | `sharedservices-rg` | The ResourceGroup where your VNET, for your PostgreSQL Server Private Endpoint, resides in. |
| PostgreSqlServerPrivateEndpointVnetName | `my-vnet-$(Release.EnvironmentName)` | The name of the VNET to place the PostgreSQL Server Private Endpoint in. |
| PostgreSqlServerPrivateEndpointSubnetName | `app-subnet-3` | The name of the subnet you want your sql server's private endpoint to be in |
| ApplicationVnetName | `my-vnet-$(Release.EnvironmentName)` | The name of the VNET the appservice is in|
| ApplicationVnetResourceGroupName | `sharedservices-rg` | The ResourceGroup where your VNET, for your appservice, resides in. |
| ApplicationSubnetName | `app-subnet-4` | The name of the subnet the appservice is in |
| PostgreSqlServerPassword | `#$mydatabas**e` | The password for the PostgreSql server username |
| PostgreSqlServerUsername | `rob` | The admin username for the PostgreSql server |
| PostgreSqlServerName | `somesqlserver$(Release.EnvironmentName)` | The name for the PostgreSQL Server resource. It's recommended to use just alphanumerical characters without hyphens etc.|
| PostgreSqlServerResourceGroupName | `myteam-testapi-$(Release.EnvironmentName)` | The name of the resourcegroup you want your PostgreSql server to be created in |
| DNSZoneResourceGroupName | `MyDNSZones-$(Release.EnvironmentName)` | Make sure to use the shared DNS Zone resource group (you can only register a zone once per subscription). |
| PostgreSqlServerPrivateDnsZoneName | `privatelink.postgres.database.windows.net` | The name of DNS zone where your private endpoint will be created in. If you are unsure use `privatelink.database.windows.net` |
| PostgreSqlServerSku | `GP_Gen5_2` | The SKU to use for this server. This will determine the performancetier |
| BackupRetentionInDays | `7` | The number of days you want the backup retention to be | 
| PostgreSqlServerVersion | `11` | Define the version of postgresql to use. This defaults to v11 |

# Code
[Click here to download this script](../../../../src/PostgreSQL/Create-PostgreSQL-Server.ps1)

# Links

[Azure CLI - az network vnet show](https://docs.microsoft.com/en-us/cli/azure/network/vnet?view=azure-cli-latest#az_network_vnet_show)

[Azure CLI - az network vnet subnet show](https://docs.microsoft.com/en-us/cli/azure/network/vnet/subnet?view=azure-cli-latest#az-network-vnet-subnet-show)

[Azure CLI - az postgres server create](https://docs.microsoft.com/en-us/cli/azure/postgres/server?view=azure-cli-latest#az_postgres_server_create)

[Azure CLI - az network vnet subnet update](https://docs.microsoft.com/en-us/cli/azure/network/vnet/subnet?view=azure-cli-latest#az-network-vnet-subnet-update)

[Azure CLI - az postgres server show](https://docs.microsoft.com/en-us/cli/azure/postgres/server?view=azure-cli-latest#az_postgres_server_show)

[Azure CLI - az network private-endpoint create](https://docs.microsoft.com/en-us/cli/azure/network/private-endpoint?view=azure-cli-latest#az-network-private-endpoint-create)

[Azure CLI - az network private-dns zone show](https://docs.microsoft.com/en-us/cli/azure/ext/privatedns/network/private-dns/zone?view=azure-cli-latest#ext-privatedns-az-network-private-dns-zone-show)

[Azure CLI - az network private-dns zone create](https://docs.microsoft.com/en-us/cli/azure/ext/privatedns/network/private-dns/zone?view=azure-cli-latest#ext-privatedns-az-network-private-dns-zone-create)

[Azure CLI - az network private-dns link vnet show](https://docs.microsoft.com/en-us/cli/azure/network/private-dns/link/vnet?view=azure-cli-latest#az-network-private-dns-link-vnet-show)

[Azure CLI - az network private-dns link vnet create](https://docs.microsoft.com/en-us/cli/azure/network/private-dns/link/vnet?view=azure-cli-latest#az-network-private-dns-link-vnet-create)

[Azure CLI - az network private-endpoint dns-zone-group create](https://docs.microsoft.com/en-us/cli/azure/network/private-endpoint/dns-zone-group?view=azure-cli-latest#az-network-private-endpoint-dns-zone-group-create)
