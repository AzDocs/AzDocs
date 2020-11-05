[[_TOC_]]

# Description
This snippet will create a VNET if it does not exist with a subnet if it doesnt exist. It also adds the mandatory tags to the VNET

# Parameters
Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.

| Parameter | Example Value | Description |
|--|--|--|
| subnet | `10.0.0.0/24` | The subnet identifier for the subnet to create. This is done using the CIDR notation. |
| subnetName | `app-subnet-3` | The name to use for the subnet to create.  |


# Code
[Click here to download this script](../../../../src/Networking/Create-subnet-with-VNET-if-needed.ps1)

# Links

[Azure CLI - az-network-vnet-create](https://docs.microsoft.com/en-us/cli/azure/network/vnet?view=azure-cli-latest#az-network-vnet-create)

[Azure CLI - az-network-vnet-show](https://docs.microsoft.com/en-us/cli/azure/network/vnet?view=azure-cli-latest#az-network-vnet-show)

[Azure CLI - az-network-vnet-subnet-create](https://docs.microsoft.com/en-us/cli/azure/network/vnet/subnet?view=azure-cli-latest#az-network-vnet-subnet-create)

[Azure CLI - az-network-vnet-subnet-show](https://docs.microsoft.com/en-us/cli/azure/network/vnet/subnet?view=azure-cli-latest#az-network-vnet-subnet-show)