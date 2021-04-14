[[_TOC_]]

# Description
This snippet will create a storage account if it does not exist within a given subnet. It will also make sure that public access is denied by default. It will whitelist the application subnet so your app can connect to the storageaccount within the vnet. All the needed components (private endpoint, service endpoint etc) will be created too.

NOTE: This step was built with blob storage in mind. If you use anything else please test this extensively. It should work, but it is untested.

# Parameters
Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.

| Parameter | Required | Example Value | Description |
|--|--|--|--|
| StorageAccountResourceGroupName | <input type="checkbox" checked> | `myteam-testapi-$(Release.EnvironmentName)` | ResourceGroupName where the storage account should be created |
| StorageAccountName | <input type="checkbox" checked> | `myteststgaccount$(Release.EnvironmentName)` | This is the storageaccount name to use. |

# VNET Whitelisting Parameters

If you want to use "vnet whitelisting" on your resource. Use these parameters. Using VNET Whitelisting is the recommended way of building & connecting your application stack within Azure.
NOTE: These parameters are only required when you want to use the VNet whitelisting feature for this resource.
| Parameter | Required for VNET Whitelisting | Example Value | Description |
|--|--|--|--|
| ApplicationVnetResourceGroupName | <input type="checkbox" checked> | `sharedservices-rg` | The ResourceGroup where your VNET, for your storage account, resides in. |
| ApplicationVnetName | <input type="checkbox" checked> | `my-vnet-$(Release.EnvironmentName)` | The name of the VNET the storage account is in|
| ApplicationSubnetName | <input type="checkbox" checked> | `app-subnet-4` | The subnetname for the subnet whitelist on the storage account. |

# Private Endpoint Parameters

If you want to use private endpoints on your resource. Use these parameters. Private Endpoints are used for connecting to your Azure Resources from on-premises.
NOTE: These parameters are only required when you want to use a private endpoint for this resource.
| Parameter | Required for Pvt Endpoint | Example Value | Description |
|--|--|--|--|
| StorageAccountPrivateEndpointVnetResourceGroupName | <input type="checkbox" checked> | `sharedservices-rg` | The ResourceGroup where your VNET, for your storage account private endpoint, resides in. |
| StorageAccountPrivateEndpointVnetName | <input type="checkbox" checked> | `my-vnet-$(Release.EnvironmentName)` | The name of the VNET to place the storage account private endpoint in. |
| StorageAccountPrivateEndpointSubnetName | <input type="checkbox" checked> | `app-subnet-3` | The name of the subnet where the storageaccount's private endpoint will reside in. |
| PrivateEndpointGroupId | <input type="checkbox" checked> | `blob` | A privateendpoint per storagetype is needed. Use `az network private-link-resource list` to fetch a list of possible group id's |
| DNSZoneResourceGroupName | <input type="checkbox" checked> | `MyDNSZones-$(Release.EnvironmentName)` | Make sure to use the shared DNS Zone resource group (you can only register a zone once per subscription). |
| StorageAccountPrivateDnsZoneName | <input type="checkbox" checked> | `privatelink.blob.core.windows.net` | Generally this will be `privatelink.blob.core.windows.net`. This defines which DNS Zone to use for the private storage endpoint. |


# Code
[Click here to download this script](../../../../src/Storage-Accounts/Create-Storage-account.ps1)

# Links

[Azure CLI - az-storage-account-create](https://docs.microsoft.com/en-us/cli/azure/storage/account?view=azure-cli-latest#az-storage-account-create)

[Azure CLI - az-network-vnet-subnet-update](https://docs.microsoft.com/en-us/cli/azure/network/vnet/subnet?view=azure-cli-latest#az-network-vnet-subnet-update)

[Azure CLI - az-storage-account-show](https://docs.microsoft.com/en-us/cli/azure/storage/account?view=azure-cli-latest#az-storage-account-show)

[Azure CLI - az-network-private-endpoint-create](https://docs.microsoft.com/en-us/cli/azure/network/private-endpoint?view=azure-cli-latest#az-network-private-endpoint-create)

[Azure CLI - az-network-private-dns-zone-show](https://docs.microsoft.com/en-us/cli/azure/ext/privatedns/network/private-dns/zone?view=azure-cli-latest#ext-privatedns-az-network-private-dns-zone-show)

[Azure CLI - az-network-private-dns-zone-create](https://docs.microsoft.com/en-us/cli/azure/ext/privatedns/network/private-dns/zone?view=azure-cli-latest#ext-privatedns-az-network-private-dns-zone-create)

[Azure CLI - az-network-private-dns-link-vnet-show](https://docs.microsoft.com/en-us/cli/azure/network/private-dns/link/vnet?view=azure-cli-latest#az-network-private-dns-link-vnet-show)

[Azure CLI - az-network-private-dns-link-vnet-create](https://docs.microsoft.com/en-us/cli/azure/network/private-dns/link/vnet?view=azure-cli-latest#az-network-private-dns-link-vnet-create)

[Azure CLI - az-network-private-endpoint-dns-zone-group-create](https://docs.microsoft.com/en-us/cli/azure/network/private-endpoint/dns-zone-group?view=azure-cli-latest#az-network-private-endpoint-dns-zone-group-create)

[Azure CLI - az-network-vnet-subnet-show](https://docs.microsoft.com/en-us/cli/azure/network/vnet/subnet?view=azure-cli-latest#az-network-vnet-subnet-show)

[Azure CLI - az-storage-account-network-rule-add](https://docs.microsoft.com/en-us/cli/azure/storage/account/network-rule?view=azure-cli-latest#az-storage-account-network-rule-add)

[Azure CLI - az-storage-account-update](https://docs.microsoft.com/en-us/cli/azure/storage/account?view=azure-cli-latest#az-storage-account-update)

[Azure CLI - az-network-private-link-resource-list](https://docs.microsoft.com/en-us/cli/azure/network/private-link-resource?view=azure-cli-latest#az-network-private-link-resource-list)