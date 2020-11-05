[[_TOC_]]

# Description
This snippet will create a Resource Group if it does not exist. It also adds the mandatory tags to the resource group

# Parameters
| Parameter | Example Value | Description |
|--|--|--|
| location | `westeurope` | The location in Azure the resource group should be created |
| resourceGroupName | `myteam-testapi-$(Release.EnvironmentName)` | The name for the resource group |


# Code
[Click here to download this script](../../../../src/Resourcegroup/Create-ResourceGroup.ps1)


# Links

[Azure CLI - az group create](https://docs.microsoft.com/en-us/cli/azure/group?view=azure-cli-latest#az-group-create)