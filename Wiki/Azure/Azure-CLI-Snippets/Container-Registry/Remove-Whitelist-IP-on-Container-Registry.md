[[_TOC_]]

# Description
This snippet will remove the specified IP Range from the Azure Container Registry. If you leave the `CIDRToRemoveFromWhitelist` parameter empty, it will use the outgoing IP from where you execute this script.

# Parameters
| Parameter | Example Value | Description |
|--|--|--|
| ContainerRegistryResourceGroupName | `myteam-testapi-$(Release.EnvironmentName)` | The name of the resource group the Container Registry is in|
| ContainerRegistryName | `somecontainerregistry$(Release.EnvironmentName)` | The name for the Container Registry resource. This name is restricted to alphanumerical characters without hyphens etc. |
| CIDRToRemoveFromWhitelist | `52.43.65.123/32` | The IP range, to remove the whitelist for, in [CIDR notation](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing#CIDR_notation). Leave this field empty to use the outgoing IP from where you execute this script. |

# Code
[Click here to download this script](../../../../src/Container-Registry/Remove-Whitelist-IP-on-Container-Registry.ps1)

# Links

[Azure CLI - az acr network-rule remove](https://docs.microsoft.com/en-us/cli/azure/acr/network-rule?view=azure-cli-latest#az_acr_network_rule_remove)