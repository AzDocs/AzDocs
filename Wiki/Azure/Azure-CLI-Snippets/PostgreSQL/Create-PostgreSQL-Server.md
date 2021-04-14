[[_TOC_]]

# Description
This snippet will create a PostgreSQL Server if it does not exist within a given subnet. It will whitelist the application subnet so your app can connect to the SQL Server within the vnet. All the needed components (private endpoint, service endpoint etc) will be created too.

# Parameters
Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.

| Parameter | Required | Example Value | Description |
|--|--|--|--|
| PostgreSqlServerPassword | <input type="checkbox" checked> | `#$mydatabas**e` | The password for the PostgreSql server username |
| PostgreSqlServerUsername | <input type="checkbox" checked> | `rob` | The admin username for the PostgreSql server |
| PostgreSqlServerName | <input type="checkbox" checked> | `somesqlserver$(Release.EnvironmentName)` | The name for the PostgreSQL Server resource. It's recommended to use just alphanumerical characters without hyphens etc.|
| PostgreSqlServerResourceGroupName | <input type="checkbox" checked> | `myteam-testapi-$(Release.EnvironmentName)` | The name of the resourcegroup you want your PostgreSql server to be created in |
| PostgreSqlServerSku | <input type="checkbox" checked> | `GP_Gen5_2` | The SKU to use for this server. This will determine the performancetier |
| BackupRetentionInDays | <input type="checkbox"> | `7` | The number of days you want the backup retention to be | 
| PostgreSqlServerVersion | <input type="checkbox"> | `11` | Define the version of postgresql to use. This defaults to v11 |
| PostgreSqlServerPublicNetworkAccess | <input type="checkbox"> | `Enabled`/`Disabled` | Enable or disable the public endpoint. When using VNet Whitelisting this will forcefully be enabled. In this case the VNet whitelist will only allow access from your VNets via the public interface (this might be confusing). If you are ONLY using Private Endpoints, you can disable public access. The default value is set to `Disabled` with an forced override to `Enabled` if you use VNet whitelisting. |


# VNET Whitelisting Parameters

If you want to use "vnet whitelisting" on your resource. Use these parameters. Using VNET Whitelisting is the recommended way of building & connecting your application stack within Azure.
NOTE: These parameters are only required when you want to use the VNet whitelisting feature for this resource.
| Parameter | Required for VNET Whitelisting | Example Value | Description |
|--|--|--|--|
| ApplicationVnetName | <input type="checkbox" checked> | `my-vnet-$(Release.EnvironmentName)` | The name of the VNET the appservice is in|
| ApplicationVnetResourceGroupName | <input type="checkbox" checked> | `sharedservices-rg` | The ResourceGroup where your VNET, for your appservice, resides in. |
| ApplicationSubnetName | <input type="checkbox" checked> | `app-subnet-4` | The name of the subnet the appservice is in |

# Private Endpoint Parameters

If you want to use private endpoints on your resource. Use these parameters. Private Endpoints are used for connecting to your Azure Resources from on-premises.
NOTE: These parameters are only required when you want to use a private endpoint for this resource.
| Parameter | Required for Pvt Endpoint | Example Value | Description |
|--|--|--|--|
| PostgreSqlServerPrivateEndpointVnetResourceGroupName | <input type="checkbox" checked> | `sharedservices-rg` | The ResourceGroup where your VNET, for your PostgreSQL Server Private Endpoint, resides in. |
| PostgreSqlServerPrivateEndpointVnetName | <input type="checkbox" checked> | `my-vnet-$(Release.EnvironmentName)` | The name of the VNET to place the PostgreSQL Server Private Endpoint in. |
| PostgreSqlServerPrivateEndpointSubnetName | <input type="checkbox" checked> | `app-subnet-3` | The name of the subnet you want your sql server's private endpoint to be in |
| DNSZoneResourceGroupName | <input type="checkbox" checked> | `MyDNSZones-$(Release.EnvironmentName)` | Make sure to use the shared DNS Zone resource group (you can only register a zone once per subscription). |
| PostgreSqlServerPrivateDnsZoneName | <input type="checkbox" checked> | `privatelink.postgres.database.windows.net` | The name of DNS zone where your private endpoint will be created in. If you are unsure use `privatelink.database.windows.net` |


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
