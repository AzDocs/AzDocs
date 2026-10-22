# expressRouteConnections

Target Scope: resourceGroup

## Synopsis
Creating an ExpressRoute Gateway Connection.

## Description
Creating an ExpressRoute Gateway Connection that wires an ExpressRoute circuit's private peering into a Virtual Hub's ExpressRoute Gateway.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| expressRouteGatewayName | string | <input type="checkbox" checked> | None | <pre></pre> | Required. The name of the existing ExpressRoute Gateway. |
| expressRouteConnectionName | string | <input type="checkbox" checked> | Length between 1-80 | <pre></pre> | Required. The name of the ExpressRoute connection. |
| expressRouteCircuitPeeringId | string | <input type="checkbox" checked> | None | <pre></pre> | Required. The resource ID of the ExpressRoute circuit private peering. |
| routingWeight | int | <input type="checkbox"> | None | <pre>0</pre> | Optional. The routing weight associated to the connection. |
| authorizationKey | string | <input type="checkbox"> | None | <pre>''</pre> | Optional. Authorization key to establish the connection (required for cross-subscription circuits). |
| enableInternetSecurity | bool | <input type="checkbox"> | None | <pre>false</pre> | Optional. Enable internet security (route internet-bound traffic through the hub firewall). |
| enableDirectConnect | bool | <input type="checkbox"> | None | <pre>false</pre> | Optional. Enable FastPath to vNet for the ExpressRoute connection. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| expressRouteConnectionResourceId | string | The resource ID of the ExpressRoute connection. |
| expressRouteConnectionName | string | The name of the ExpressRoute connection. |
| expressRouteConnectionResourceGroupName | string | The resource group the ExpressRoute connection was deployed into. |

## Examples
<pre>
module expressRouteConnection 'br:contosoregistry.azurecr.io/network/expressroutegateways/expressrouteconnections:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 55), 'erconn')
  params: {
    expressRouteGatewayName: 'ergw-vhub-we-01-prd'
    expressRouteConnectionName: 'conn-erc-we-01-prd'
    expressRouteCircuitPeeringId: '/subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.Network/expressRouteCircuits/{circuit}/peerings/AzurePrivatePeering'
  }
}
</pre>
<p>Creates an ExpressRoute connection between a circuit's private peering and an ExpressRoute Gateway in a Virtual Hub.</p>

## Links
- [Bicep Microsoft.Network expressRouteGateways/expressRouteConnections](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/expressroutegateways/expressrouteconnections?pivots=deployment-language-bicep)<br>
- [ExpressRoute connections in Virtual WAN](https://learn.microsoft.com/en-us/azure/virtual-wan/virtual-wan-expressroute-portal)
