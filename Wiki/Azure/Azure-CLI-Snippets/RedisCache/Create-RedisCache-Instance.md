[[_TOC_]]

# Description

This snippet will create a RedisCache instance if it does not exist. 

## VNET / VNET Whitelisting

Currently RedisCache does not support VNET whitelisting unfortunately. There is a "VNET mode" available for the premium SKU, but this delegates a whole subnet to Redis, which is (in our eyes) to heavy on the amount of IP's you need to use for redis. Next to this; it is only available for the premium SKU. Therefore we decided not to support this method.

## Private Endpoints

There is an option where it will create private endpoints for you & also disables public access if desired. All the needed components (private endpoint, DNS etc.) will be created too.

# Parameters

Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.

| Parameter | Required | Example Value | Description |
|--|--|--|--|
| RedisInstanceLocation | <input type="checkbox" checked> | `westeurope` | The location for your RedisInstance. This can likely be filled with the `$(Location)` variable. |
| RedisInstanceName | <input type="checkbox" checked> | `somerediscache$(Release.EnvironmentName)` | The name for the Redis Cache resource. It's recommended to use just alphanumerical characters without hyphens etc.|
| RedisInstanceResourceGroupName | <input type="checkbox" checked> | `myteam-testapi-$(Release.EnvironmentName)` | The name of the resourcegroup you want your Redis Cache to be created in |
| RedisInstanceSkuName | <input type="checkbox" checked> | `Standard` | The skuname for the Redis Instance to use. Options are: `Basic`, `Standard`, `Premium`. More information can be found [here](https://azure.microsoft.com/en-us/pricing/details/cache/). |
| RedisInstanceVmSize | <input type="checkbox" checked> | `C1` | This says something about the performance of your Redis Cache. Options are: `C0`, `C1`, `C2`, `C3`, `C4`, `C5`, `C6`, `P1`, `P2`, `P3`, `P4`, `P5`. More information can be found [here](https://azure.microsoft.com/en-us/pricing/details/cache/). |
| RedisInstanceEnableNonSslPort | <input type="checkbox"> | `$true`/`$false` | Enable or disable the non-SSL port. This is by default (and recommended) disabled (`$false`). |
| RedisInstanceMinimalTlsVersion | <input type="checkbox"> | `1.2` | The minimal TLS version to use. Defaults to `1.2`. Options are `1.0`, `1.1`, `1.2` |


# Private Endpoint Parameters

If you want to use private endpoints on your resource. Use these parameters. Private Endpoints are used for connecting to your Azure Resources from on-premises or within the VNet you are using.
> NOTE: These parameters are only required when you want to use a private endpoint for this resource.

| Parameter | Required for Pvt Endpoint | Example Value | Description |
|--|--|--|--|
| RedisInstancePrivateEndpointVnetResourceGroupName | <input type="checkbox" checked> | `sharedservices-rg` | The ResourceGroup where your VNET, for your RedisCache Instance Private Endpoint, resides in. |
| RedisInstancePrivateEndpointVnetName | <input type="checkbox" checked> | `my-vnet-$(Release.EnvironmentName)` | The name of the VNET to place the RedisCache Instance Private Endpoint in. |
| RedisInstancePrivateEndpointSubnetName | <input type="checkbox" checked> | `app-subnet-3` | The name of the subnet you want your RedisCache Instance's private endpoint to be in. |
| DNSZoneResourceGroupName | <input type="checkbox" checked> | `MyDNSZones-$(Release.EnvironmentName)` | Make sure to use the shared DNS Zone resource group (you can only register a zone once per subscription). |
| RedisInstancePrivateDnsZoneName | <input type="checkbox" checked> | `privatelink.redis.cache.windows.net` | The name of DNS zone where your private endpoint will be created in. If you are unsure use `privatelink.redis.cache.windows.net` |

# Code

[Click here to download this script](../../../../src/RedisCache/Create-RedisCache-Instance.ps1)

# Links

[Azure CLI - az redis show](https://docs.microsoft.com/en-us/cli/azure/redis?view=azure-cli-latest#az_redis_show)

[Azure CLI - az redis create](https://docs.microsoft.com/en-us/cli/azure/redis?view=azure-cli-latest#az_redis_create)

[Azure CLI - az network vnet show](https://docs.microsoft.com/en-us/cli/azure/network/vnet?view=azure-cli-latest#az_network_vnet_show)

[Azure CLI - az network vnet subnet show](https://docs.microsoft.com/en-us/cli/azure/network/vnet/subnet?view=azure-cli-latest#az-network-vnet-subnet-show)
