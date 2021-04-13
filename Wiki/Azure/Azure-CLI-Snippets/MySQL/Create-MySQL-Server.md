[[_TOC_]]

# Description

This snippet will create a MySQL Server if it does not exist. There are two options of connecting your application to this MySQL Server.

## VNET Whitelisting (uses the "public interface")
Microsoft does some neat tricks where you can whitelist your vnet/subnet op the MySQL server without your MySQL server having to be inside the vnet itself (public/private address translation).
This script will whitelist the application subnet so your app can connect to the MySQL Server over the public endpoint, while blocking all other traffic (internet traffic for example). Service Endpoints will also be provisioned if needed on the subnet.

## Private Endpoints

There is an option where it will create private endpoints for you & also disables public access if desired. All the needed components (private endpoint, DNS etc.) will be created too.

# Parameters

Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.

| Parameter | Required | Example Value | Description |
|--|--|--|--|
| MySqlServerLocation | <input type="checkbox" checked> | `westeurope` | The location of your MySQL Server. It's very likely you can use `$(Location)` here (see the ) [General Parameter](/Azure/Azure-CLI-Snippets) list. |
| MySqlServerName | <input type="checkbox" checked> | `somemysqlserver$(Release.EnvironmentName)` | The name for the MySQL Server resource. It's recommended to use just alphanumerical characters without hyphens etc.|
| MySqlServerUsername | <input type="checkbox" checked> | `rob` | The admin username for the MySQL Server |
| MySqlServerPassword | <input type="checkbox" checked> | `#$mydatabas**e` | The password corresponding to MySqlServerUsername |
| MySqlServerResourceGroupName | <input type="checkbox" checked> | `myteam-testapi-$(Release.EnvironmentName)` | The name of the resourcegroup you want your MySql server to be created in |
| MySqlServerSkuName | <input type="checkbox" checked> | `GP_Gen5_4` | The name of the sku. Follows the convention {pricing tier}{compute generation}{vCores} in shorthand. Examples: `B_Gen5_1`, `GP_Gen5_4`, `MO_Gen5_16`. |
| MySqlServerStorageSizeInMB | <input type="checkbox" checked> | `51200` | The storage capacity of the server (unit is megabytes). |
| MySqlServerMinimalTlsVersion | <input type="checkbox"> | `TLS1_2` | The minimal TLS version to use. Defaults to `TLS1_2`. Options are `TLS1_0`, `TLS1_1`, `TLS1_2` or `TLSEnforcementDisabled`. It's strongly recommended to use `TLS1_2` at the time of writing. |
| MySqlServerSslEnforcement | <input type="checkbox"> | `Enabled`/`Disabled` | Enables the enforcement of SSL connections. Default value is `Enabled`. It is strongly recommended to leave this `Enabled`. |

# VNET Whitelisting Parameters

If you want to use "vnet whitelisting" on your resource. Use these parameters. Using VNET Whitelisting is the recommended way of building & connecting your application stack within Azure.
| Parameter | Required | Example Value | Description |
|--|--|--|--|
| ApplicationVnetResourceGroupName | <input type="checkbox"> | `sharedservices-rg` | The ResourceGroup where your VNET, for your appservice, resides in. |
| ApplicationVnetName | <input type="checkbox">  | `my-vnet-$(Release.EnvironmentName)` | The name of the VNET the appservice is in|
| ApplicationSubnetName | <input type="checkbox"> | `app-subnet-4` | The name of the subnet the appservice is in |

# Private Endpoint Parameters

If you want to use private endpoints on your resource. Use these parameters. Private Endpoints are used for connecting to your Azure Resources from on-premises.
| Parameter | Required | Example Value | Description |
|--|--|--|--|
| MySqlServerPrivateEndpointVnetResourceGroupName | <input type="checkbox"> | `sharedservices-rg` | The ResourceGroup where your VNET, for your MySql Server Private Endpoint, resides in. |
| MySqlServerPrivateEndpointVnetName | <input type="checkbox"> | `my-vnet-$(Release.EnvironmentName)` | The name of the VNET to place the MySql Server Private Endpoint in. |
| MySqlServerPrivateEndpointSubnetName | <input type="checkbox"> | `app-subnet-3` | The name of the subnet you want your MySql server's private endpoint to be in |
| DNSZoneResourceGroupName | <input type="checkbox"> | `MyDNSZones-$(Release.EnvironmentName)` | Make sure to use the shared DNS Zone resource group (you can only register a zone once per subscription). |
| MySqlServerPrivateDnsZoneName | <input type="checkbox"> | `privatelink.mysql.database.azure.com` | The name of DNS zone where your private endpoint will be created in. If you are unsure use `privatelink.mysql.database.azure.com` |

# Code

[Click here to download this script](../../../../src/MySQL/Create-MySQL-Server.ps1)

# Links

[Azure CLI - az mysql server show](https://docs.microsoft.com/en-us/cli/azure/mysql/server?view=azure-cli-latest#az_mysql_server_show)

[Azure CLI - az mysql server create](https://docs.microsoft.com/en-us/cli/azure/mysql/server?view=azure-cli-latest#az_mysql_server_create)

[Azure CLI - az network vnet show](https://docs.microsoft.com/en-us/cli/azure/network/vnet?view=azure-cli-latest#az_network_vnet_show)

[Azure CLI - az network vnet subnet show](https://docs.microsoft.com/en-us/cli/azure/network/vnet/subnet?view=azure-cli-latest#az_network_vnet_subnet_show)

[Azure CLI - az mysql server vnet-rule create](https://docs.microsoft.com/en-us/cli/azure/mysql/server/vnet-rule?view=azure-cli-latest#az_mysql_server_vnet_rule_create)
