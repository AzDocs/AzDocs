# expressRouteCircuits

Target Scope: resourceGroup

## Synopsis
Creating an ExpressRoute Circuit.

## Description
Creating an ExpressRoute Circuit with the given specs and secure defaults.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| expressRouteCircuitName | string | <input type="checkbox" checked> | Length between 1-80 | <pre></pre> | Required. The name of the ExpressRoute Circuit. |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Optional. Location for all resources. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | Optional. Tags of the ExpressRoute Circuit resource. |
| skuName | string | <input type="checkbox" checked> | None | <pre></pre> | Required. The name of the SKU. Follows the format {tier}_{family}, e.g. Standard_MeteredData. |
| skuTier | string | <input type="checkbox" checked> | `'Basic'` or `'Local'` or `'Premium'` or `'Standard'` | <pre></pre> | Required. The tier of the SKU. |
| skuFamily | string | <input type="checkbox" checked> | `'MeteredData'` or `'UnlimitedData'` | <pre></pre> | Required. The family of the SKU. |
| serviceProviderName | string | <input type="checkbox"> | None | <pre>''</pre> | Optional. The name of the service provider. Required when provisioning through a service provider. |
| peeringLocation | string | <input type="checkbox"> | None | <pre>''</pre> | Optional. The peering location. Required when provisioning through a service provider. |
| bandwidthInMbps | int | <input type="checkbox"> | None | <pre>0</pre> | Optional. The bandwidth in Mbps. Required when provisioning through a service provider. |
| bandwidthInGbps | int | <input type="checkbox"> | None | <pre>0</pre> | Optional. The bandwidth of the circuit in Gbps. Used when the circuit is provisioned on an ExpressRoutePort resource. |
| expressRoutePortResourceId | string | <input type="checkbox"> | None | <pre>''</pre> | Optional. The resource ID of the ExpressRoutePort resource when the circuit is provisioned on an ExpressRoutePort resource. |
| allowClassicOperations | bool | <input type="checkbox"> | None | <pre>false</pre> | Optional. Allow classic operations on the circuit. |
| authorizationKey | string | <input type="checkbox"> | None | <pre>''</pre> | Optional. The authorization key for the circuit. |
| authorizations | array | <input type="checkbox"> | None | <pre>[]</pre> | Optional. The list of authorizations for the circuit. |
| circuitProvisioningState | string | <input type="checkbox"> | None | <pre>''</pre> | Optional. The circuit provisioning state. |
| enableDirectPortRateLimit | bool | <input type="checkbox"> | None | <pre>false</pre> | Optional. Flag denoting rate-limiting status of the ExpressRoute direct-port circuit. |
| gatewayManagerEtag | string | <input type="checkbox"> | None | <pre>''</pre> | Optional. The GatewayManager Etag. |
| globalReachEnabled | bool | <input type="checkbox"> | None | <pre>false</pre> | Optional. Flag denoting global reach status. |
| peerings | array | <input type="checkbox"> | None | <pre>[]</pre> | Optional. The list of peerings for the circuit. |
| serviceKey | string | <input type="checkbox"> | None | <pre>''</pre> | Optional. The ServiceKey of the circuit. |
| serviceProviderNotes | string | <input type="checkbox"> | None | <pre>''</pre> | Optional. The service provider notes. |
| serviceProviderProvisioningState | string | <input type="checkbox"> | `''` or `'Deprovisioning'` or `'NotProvisioned'` or `'Provisioned'` or `'Provisioning'` | <pre>''</pre> | Optional. The service provider provisioning state. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| expressRouteCircuitResourceId | string | The resource ID of the ExpressRoute Circuit. |
| expressRouteCircuitResourceGroupName | string | The resource group the ExpressRoute Circuit was deployed into. |
| expressRouteCircuitName | string | The name of the ExpressRoute Circuit. |
| expressRouteCircuitServiceKey | string | The service key of the ExpressRoute Circuit. |

## Examples
<pre>
module expressRouteCircuit 'br:contosoregistry.azurecr.io/network/expressroutecircuits:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 60), 'erc')
  params: {
    expressRouteCircuitName: 'my-expressroute-circuit'
    location: location
    skuName: 'Standard_MeteredData'
    skuTier: 'Standard'
    skuFamily: 'MeteredData'
    serviceProviderName: 'Equinix'
    peeringLocation: 'Silicon Valley'
    bandwidthInMbps: 200
  }
}
</pre>
<p>Creates an ExpressRoute Circuit provisioned through a service provider.</p>

---

<pre>
module expressRouteCircuit 'br:contosoregistry.azurecr.io/network/expressroutecircuits:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 60), 'erc')
  params: {
    expressRouteCircuitName: 'my-direct-expressroute-circuit'
    location: location
    skuName: 'Premium_UnlimitedData'
    skuTier: 'Premium'
    skuFamily: 'UnlimitedData'
    bandwidthInGbps: 10
    expressRoutePortResourceId: expressRoutePort.id
  }
}
</pre>
<p>Creates an ExpressRoute Circuit provisioned on an ExpressRoute Direct port.</p>

## Links
- [Bicep Microsoft.Network expressRouteCircuits](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/expressroutecircuits?pivots=deployment-language-bicep)<br>
- [ExpressRoute Overview](https://learn.microsoft.com/en-us/azure/expressroute/expressroute-introduction)
