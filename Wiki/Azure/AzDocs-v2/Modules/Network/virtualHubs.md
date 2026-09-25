# virtualHubs

Target Scope: resourceGroup

> [!NOTE]
> This module uses Bicep resource-derived types (`resourceInput<>` / `resourceOutput<>`).
> - [Resource-derived types](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/user-defined-data-types#resource-derived-types)
> - [Bicep data types](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/data-types)

## Synopsis
Creating a Virtual Hub.

## Description
Creating a Virtual Hub with the given specs. If you are planning to deploy a Secure Virtual Hub (with an Azure Firewall integrated), please refer to the Azure Firewall module.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| virtualHubName | string | <input type="checkbox" checked> | None | <pre></pre> | Required. The virtual hub name. |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Optional. Location for all resources. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | Optional. Tags of the resource. |
| addressPrefix | string | <input type="checkbox" checked> | None | <pre></pre> | Required. Address-prefix for this VirtualHub. |
| allowBranchToBranchTraffic | bool | <input type="checkbox"> | None | <pre>true</pre> | Optional. Flag to control transit for VirtualRouter hub. |
| azureFirewallResourceId | string | <input type="checkbox"> | None | <pre>''</pre> | Optional. Resource ID of the Azure Firewall to link to. |
| expressRouteGatewayResourceId | string | <input type="checkbox"> | None | <pre>''</pre> | Optional. Resource ID of the Express Route Gateway to link to. |
| p2SVpnGatewayResourceId | string | <input type="checkbox"> | None | <pre>''</pre> | Optional. Resource ID of the Point-to-Site VPN Gateway to link to. |
| hubRoutingPreference | [resourceInput<'Microsoft.Network/virtualHubs@2025-01-01'>.properties.hubRoutingPreference](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/2025-01-01/virtualhubs?pivots=deployment-language-bicep)? | <input type="checkbox" checked> | Schema-constrained (resource-derived type) | <pre></pre> | Optional. The preferred routing preference for this virtual hub. |
| preferredRoutingGateway | [resourceInput<'Microsoft.Network/virtualHubs@2025-01-01'>.properties.preferredRoutingGateway](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/2025-01-01/virtualhubs?pivots=deployment-language-bicep)? | <input type="checkbox" checked> | Schema-constrained (resource-derived type) | <pre></pre> | Optional. The preferred routing gateway types. |
| routeTableRoutes | [resourceInput<'Microsoft.Network/virtualHubs@2025-01-01'>.properties.routeTable.routes](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/2025-01-01/virtualhubs?pivots=deployment-language-bicep)? | <input type="checkbox" checked> | Schema-constrained (resource-derived type) | <pre></pre> | Optional. The VirtualHub route tables. |
| securityPartnerProviderResourceId | string | <input type="checkbox"> | None | <pre>''</pre> | Optional. ID of the Security Partner Provider to link to. |
| securityProviderName | string | <input type="checkbox"> | None | <pre>''</pre> | Optional. The Security Provider name. |
| sku | string | <input type="checkbox"> | `'Basic'` or `'Standard'` | <pre>'Standard'</pre> | Optional. The sku of this VirtualHub. |
| virtualHubRouteTableV2s | [resourceInput<'Microsoft.Network/virtualHubs@2025-01-01'>.properties.virtualHubRouteTableV2s](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/2025-01-01/virtualhubs?pivots=deployment-language-bicep)? | <input type="checkbox" checked> | Schema-constrained (resource-derived type) | <pre></pre> | Optional. List of all virtual hub route table v2s associated with this VirtualHub. |
| virtualRouterAsn | [resourceInput<'Microsoft.Network/virtualHubs@2025-01-01'>.properties.virtualRouterAsn](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/2025-01-01/virtualhubs?pivots=deployment-language-bicep)? | <input type="checkbox" checked> | Value between 0-4294967295 | <pre></pre> | Optional. VirtualRouter ASN. |
| virtualRouterIps | [resourceInput<'Microsoft.Network/virtualHubs@2025-01-01'>.properties.virtualRouterIps](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/2025-01-01/virtualhubs?pivots=deployment-language-bicep)? | <input type="checkbox" checked> | Schema-constrained (resource-derived type) | <pre></pre> | Optional. VirtualRouter IPs. |
| virtualRouterAutoScaleConfiguration | [resourceInput<'Microsoft.Network/virtualHubs@2025-01-01'>.properties.virtualRouterAutoScaleConfiguration](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/2025-01-01/virtualhubs?pivots=deployment-language-bicep)? | <input type="checkbox" checked> | Schema-constrained (resource-derived type) | <pre></pre> | Optional. The auto scale configuration for the virtual router. |
| virtualWanResourceId | string | <input type="checkbox" checked> | None | <pre></pre> | Required. Resource ID of the virtual WAN to link to. |
| vpnGatewayResourceId | string | <input type="checkbox"> | None | <pre>''</pre> | Optional. Resource ID of the VPN Gateway to link to. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| virtualHubName | string | Outputs the resource name of the Virtual Hub. |
| virtualHubResourceId | string | Outputs the Resource ID of the Virtual Hub. |
| virtualHubResourceGroupName | string | Outputs the resource group the Virtual Hub was deployed into. |
| virtualHubLocation | string | Outputs the location the Virtual Hub was deployed into. |

## Examples
<pre>
module virtualHub 'br:contosoregistry.azurecr.io/network/virtualHubs:latest' = {
  name: '${deployment().name}-vhub'
  params: {
    name: virtualHubName
    location: location
    addressPrefix: '10.0.0.0/24'
    virtualWanResourceId: virtualWan.id
    allowBranchToBranchTraffic: true
    sku: 'Standard'
  }
}
</pre>
<p>Creates a Virtual Hub with the specified address prefix and links it to a Virtual WAN.</p>

## Links
- [Bicep Microsoft.Network virtualHubs](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/virtualhubs?pivots=deployment-language-bicep)<br>
- [Virtual Hub overview](https://learn.microsoft.com/en-us/azure/virtual-wan/virtual-wan-about)
