# expressRouteGateways

Target Scope: resourceGroup

## Synopsis
Creating an Express Route Gateway.

## Description
Creating an Express Route Gateway with the given specs.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| expressRouteGatewayName | string | <input type="checkbox" checked> | Length between 1-80 | <pre></pre> | Required. Name of the Express Route Gateway. |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Optional. Location for all resources. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | Optional. Tags of the Express Route Gateway resource. |
| allowNonVirtualWanTraffic | bool | <input type="checkbox"> | None | <pre>false</pre> | Optional. Configures this gateway to accept traffic from non Virtual WAN networks. |
| autoScaleConfigurationBoundsMax | int | <input type="checkbox"> | None | <pre>2</pre> | Optional. Maximum number of scale units deployed for ExpressRoute gateway. |
| autoScaleConfigurationBoundsMin | int | <input type="checkbox"> | None | <pre>2</pre> | Optional. Minimum number of scale units deployed for ExpressRoute gateway. |
| expressRouteConnections | resourceInput<'Microsoft.Network/expressRouteGateways@2025-07-01'>.properties.expressRouteConnections | <input type="checkbox"> | None | <pre>[]</pre> | Optional. List of ExpressRoute connections to the ExpressRoute gateway. **Note:** This parameter will overwrite existing connections, including deleting any that are not provided. This is by-design behavior of the resource provider. |
| virtualHubResourceId | string | <input type="checkbox" checked> | None | <pre></pre> | Required. Resource ID of the Virtual Wan Hub. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| expressRouteGatewayResourceId | string | The resource ID of the ExpressRoute Gateway. |
| expressRouteGatewayResourceGroupName | string | The resource group of the ExpressRoute Gateway was deployed into. |
| expressRouteGatewayName | string | The name of the ExpressRoute Gateway. |
| expressRouteGatewayLocation | string | The location the resource was deployed into. |

## Examples
<pre>
module expressRouteGateway 'br:contosoregistry.azurecr.io/network/expressRouteGateways:latest' = {
  name: '${deployment().name}-ergw'
  params: {
    name: expressRouteGatewayName
    location: location
    virtualHubResourceId: virtualHub.id
    autoScaleConfigurationBoundsMax: 4
    autoScaleConfigurationBoundsMin: 2
  }
}
</pre>
<p>Creates an Express Route Gateway with the specified configuration.</p>

## Links
- [Bicep Microsoft.Network expressRouteGateways](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/expressroutegateways?pivots=deployment-language-bicep)<br>
- [ExpressRoute Gateway](https://learn.microsoft.com/en-us/azure/expressroute/expressroute-about-virtual-network-gateways)
