[[_TOC_]]

# Description
This snippet will create a PostgreSQL Server if it does not exist within a given subnet. It will whitelist the application subnet so your app can connect to the SQL Server within the vnet. All the needed components (private endpoint, service endpoint etc) will be created too.

# Parameters
Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.

| Parameter | Example Value | Description |
|--|--|--|
| sqlServerPrivateEndpointSubnetName | `app-subnet-3` | The name of the subnet you want your sql server's private endpoint to be in |
| applicationSubnetName | `app-subnet-4` | The name of the subnet the appservice is in |
| sqlServerPassword | `#$mydatabas**e` | The password for the sqlserverusername |
| sqlServerUsername | `rob` | The admin username for the sqlserver |
| sqlServerName | `somesqlserver$(Release.EnvironmentName)` | The name for the SQL Server resource. It's recommended to use just alphanumerical characters without hyphens etc.|
| sqlServerResourceGroupName | `myteam-testapi-$(Release.EnvironmentName)` | The name of the resourcegroup you want your sql server to be created in |
| DNSZoneResourceGroupName | `MyDNSZones-$(Release.EnvironmentName)` | Make sure to use the shared DNS Zone resource group (you can only register a zone once per subscription). |
| privateDnsZoneName | `privatelink.database.windows.net` | The name of DNS zone where your private endpoint will be created in. If you are unsure use `privatelink.database.windows.net` |
| sqlServerSku | `GP_Gen5_2` | The SKU to use for this server. This will determine the performancetier |
| backupRetentionInDays | `7` | The number of days you want the backup retention to be | 
| sqlServerVersion | `11` | Define the version of postgresql to use. This defaults to v11 |

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
