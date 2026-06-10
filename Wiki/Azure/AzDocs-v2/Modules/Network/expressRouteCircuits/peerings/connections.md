# connections

Target Scope: resourceGroup

## Synopsis
Creating an ExpressRoute Circuit Peering Connection.

## Description
Creating an ExpressRoute Circuit Peering Connection (Global Reach) to connect two ExpressRoute circuits via their private peerings.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| expressRouteCircuitName | string | <input type="checkbox" checked> | None | <pre></pre> | Required. The name of the existing ExpressRoute Circuit. |
| peeringName | string | <input type="checkbox" checked> | None | <pre></pre> | Required. The name of the existing peering on the ExpressRoute Circuit. |
| connectionName | string | <input type="checkbox" checked> | None | <pre></pre> | Required. The name of the connection. |
| addressPrefix | string | <input type="checkbox" checked> | None | <pre></pre> | Required. The /29 IP address space to carve out customer addresses for tunnels. |
| authorizationKey | string | <input type="checkbox"> | None | <pre>''</pre> | Optional. The authorization key for the connection. |
| expressRouteCircuitPeeringResourceId | string | <input type="checkbox" checked> | None | <pre></pre> | Required. The resource ID of the Express Route Circuit Private Peering of the circuit initiating the connection. |
| peerExpressRouteCircuitPeeringResourceId | string | <input type="checkbox" checked> | None | <pre></pre> | Required. The resource ID of the Express Route Circuit Private Peering of the peered circuit. |
| ipv6CircuitConnectionAddressPrefix | string | <input type="checkbox"> | None | <pre>''</pre> | Optional. The /125 IPv6 address space to carve out customer addresses for Global Reach. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| connectionResourceId | string | The resource ID of the ExpressRoute Circuit Peering Connection. |
| connectionName | string | The name of the ExpressRoute Circuit Peering Connection. |
| connectionResourceGroupName | string | The resource group the ExpressRoute Circuit Peering Connection was deployed into. |

## Examples
<pre>
module peeringConnection 'br:contosoregistry.azurecr.io/network/expressroutecircuits/peerings/connections:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 60), 'conn')
  params: {
    expressRouteCircuitName: 'my-expressroute-circuit'
    peeringName: 'AzurePrivatePeering'
    connectionName: 'my-global-reach-connection'
    addressPrefix: '192.169.8.0/29'
    expressRouteCircuitPeeringResourceId: initiatingPeering.id
    peerExpressRouteCircuitPeeringResourceId: remotePeering.id
  }
}
</pre>
<p>Creates an ExpressRoute Circuit Peering Connection (Global Reach) between two circuits using IPv4.</p>

---

<pre>
module peeringConnection 'br:contosoregistry.azurecr.io/network/expressroutecircuits/peerings/connections:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 60), 'conn')
  params: {
    expressRouteCircuitName: 'my-expressroute-circuit'
    peeringName: 'AzurePrivatePeering'
    connectionName: 'my-global-reach-connection-ipv6'
    addressPrefix: '192.169.8.0/29'
    expressRouteCircuitPeeringResourceId: initiatingPeering.id
    peerExpressRouteCircuitPeeringResourceId: remotePeering.id
    ipv6CircuitConnectionAddressPrefix: 'aa06::/127'
  }
}
</pre>
<p>Creates an ExpressRoute Circuit Peering Connection (Global Reach) with both IPv4 and IPv6 address prefixes.</p>

## Links
- [Bicep Microsoft.Network expressRouteCircuits/peerings/connections](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/expressroutecircuits/peerings/connections?pivots=deployment-language-bicep)<br>
- [ExpressRoute Global Reach](https://learn.microsoft.com/en-us/azure/expressroute/expressroute-global-reach)
