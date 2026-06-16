# peerings

Target Scope: resourceGroup

## Synopsis
Creating an ExpressRoute Circuit Peering.

## Description
Creating an ExpressRoute Circuit Peering with the given specs. Supports Azure Private Peering, Azure Public Peering, and Microsoft Peering types.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| expressRouteCircuitName | string | <input type="checkbox" checked> | None | <pre></pre> | Required. The name of the existing ExpressRoute Circuit. |
| peeringName | string | <input type="checkbox" checked> | None | <pre></pre> | Required. The name of the peering. |
| peeringType | string | <input type="checkbox" checked> | `'AzurePrivatePeering'` or `'AzurePublicPeering'` or `'MicrosoftPeering'` | <pre></pre> | Required. The peering type. |
| azureASN | int | <input type="checkbox"> | None | <pre>0</pre> | Optional. The Azure ASN. |
| peerASN | int | <input type="checkbox" checked> | Value between 1-* | <pre></pre> | Required. The peer ASN. |
| primaryPeerAddressPrefix | string | <input type="checkbox" checked> | None | <pre></pre> | Required. The primary address prefix (CIDR notation, e.g. 192.168.1.0/30). |
| secondaryPeerAddressPrefix | string | <input type="checkbox" checked> | None | <pre></pre> | Required. The secondary address prefix (CIDR notation, e.g. 192.168.2.0/30). |
| vlanId | int | <input type="checkbox" checked> | None | <pre></pre> | Required. The VLAN ID. |
| state | string | <input type="checkbox"> | `'Disabled'` or `'Enabled'` | <pre>'Enabled'</pre> | Optional. The peering state. |
| sharedKey | string | <input type="checkbox"> | None | <pre>''</pre> | Optional. The shared key for the peering. |
| primaryAzurePort | string | <input type="checkbox"> | None | <pre>''</pre> | Optional. The primary Azure port. |
| secondaryAzurePort | string | <input type="checkbox"> | None | <pre>''</pre> | Optional. The secondary Azure port. |
| gatewayManagerEtag | string | <input type="checkbox"> | None | <pre>''</pre> | Optional. The GatewayManager Etag. |
| routeFilterResourceId | string | <input type="checkbox"> | None | <pre>''</pre> | Optional. The resource ID of the RouteFilter to apply to the peering. |
| microsoftPeeringConfig | object | <input type="checkbox"> | None | <pre>{}</pre> | Optional. The Microsoft peering configuration. Required for MicrosoftPeering type. |
| ipv6PeeringConfig | object | <input type="checkbox"> | None | <pre>{}</pre> | Optional. The IPv6 peering configuration. |
| connections | array | <input type="checkbox"> | None | <pre>[]</pre> | Optional. The list of circuit connections associated with Azure Private Peering for this circuit. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| peeringResourceId | string | The resource ID of the ExpressRoute Circuit Peering. |
| peeringName | string | The name of the ExpressRoute Circuit Peering. |
| peeringResourceGroupName | string | The resource group the ExpressRoute Circuit Peering was deployed into. |
| peeringType | string | The peering type of the ExpressRoute Circuit Peering. |

## Examples
<pre>
module peering 'br:contosoregistry.azurecr.io/network/expressroutecircuits/peerings:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 60), 'peer')
  params: {
    expressRouteCircuitName: 'my-expressroute-circuit'
    peeringName: 'AzurePrivatePeering'
    peeringType: 'AzurePrivatePeering'
    peerASN: 65515
    primaryPeerAddressPrefix: '192.168.1.0/30'
    secondaryPeerAddressPrefix: '192.168.2.0/30'
    vlanId: 100
    state: 'Enabled'
  }
}
</pre>
<p>Creates an Azure Private Peering on an ExpressRoute Circuit.</p>

---

<pre>
module peering 'br:contosoregistry.azurecr.io/network/expressroutecircuits/peerings:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 60), 'mspeer')
  params: {
    expressRouteCircuitName: 'my-expressroute-circuit'
    peeringName: 'MicrosoftPeering'
    peeringType: 'MicrosoftPeering'
    peerASN: 65515
    primaryPeerAddressPrefix: '123.0.0.0/30'
    secondaryPeerAddressPrefix: '123.0.0.4/30'
    vlanId: 200
    state: 'Enabled'
    microsoftPeeringConfig: {
      advertisedPublicPrefixes: [
        '123.1.0.0/24'
      ]
      customerASN: 65515
      legacyMode: 0
      routingRegistryName: 'ARIN'
    }
  }
}
</pre>
<p>Creates a Microsoft Peering on an ExpressRoute Circuit with advertised public prefixes.</p>

## Links
- [Bicep Microsoft.Network expressRouteCircuits/peerings](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/expressroutecircuits/peerings?pivots=deployment-language-bicep)<br>
- [ExpressRoute Peering](https://learn.microsoft.com/en-us/azure/expressroute/expressroute-circuit-peerings)
