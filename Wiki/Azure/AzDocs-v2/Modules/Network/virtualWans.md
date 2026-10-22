# virtualWans

Target Scope: resourceGroup

## Synopsis
Creating a Virtual WAN.

## Description
Creating a Virtual WAN with the given specs.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Optional. Location where all resources will be created. |
| virtualWanName | string | <input type="checkbox" checked> | Length between 1-80 | <pre></pre> | Required. Name of the Virtual WAN. |
| type | string | <input type="checkbox"> | `'Standard'` or `'Basic'` | <pre>'Standard'</pre> | Optional. The type of the Virtual WAN. |
| allowBranchToBranchTraffic | bool | <input type="checkbox"> | None | <pre>true</pre> | Optional. True if branch to branch traffic is allowed. |
| vWanAllowVnetToVnetTraffic | bool | <input type="checkbox"> | None | <pre>true</pre> | Allow VNet-to-VNet traffic. |
| vWanDisableVpnEncryption | bool | <input type="checkbox"> | None | <pre>false</pre> | Disable VPN encryption. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | Optional. Tags of the resource. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| virtualWanName | string | Outputs the resource name of the Virtual WAN. |
| virtualWanResourceId | string | Outputs the Resource ID of the Virtual WAN. |
| virtualWanResourceGroupName | string | Outputs the resource group the Virtual WAN was deployed into. |
| virtualWanLocation | string | Outputs the location the Virtual WAN was deployed into. |

## Examples
<pre>
module virtualWan 'br:contosoregistry.azurecr.io/network/virtualWans:latest' = {
  name: '${deployment().name}-vwan'
  params: {
    name: virtualWanName
    location: location
    type: 'Standard'
    allowBranchToBranchTraffic: true
  }
}
</pre>
<p>Creates a Virtual WAN with Standard type and branch-to-branch traffic enabled.</p>

## Links
- [Bicep Microsoft.Network virtualWans](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/virtualwans?pivots=deployment-language-bicep)<br>
- [Virtual WAN overview](https://learn.microsoft.com/en-us/azure/virtual-wan/virtual-wan-about)
