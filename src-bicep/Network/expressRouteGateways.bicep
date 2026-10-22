/*
.SYNOPSIS
Creating an Express Route Gateway.
.DESCRIPTION
Creating an Express Route Gateway with the given specs.
.EXAMPLE
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
.LINKS
- [Bicep Microsoft.Network expressRouteGateways](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/expressroutegateways?pivots=deployment-language-bicep)
- [ExpressRoute Gateway](https://learn.microsoft.com/en-us/azure/expressroute/expressroute-about-virtual-network-gateways)
*/
metadata name = 'Express Route Gateways'
metadata description = 'This module deploys an Express Route Gateway.'

@description('Required. Name of the Express Route Gateway.')
@minLength(1)
@maxLength(80)
param expressRouteGatewayName string

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

@description('Optional. Tags of the Express Route Gateway resource.')
param tags object = {}

@description('Optional. Configures this gateway to accept traffic from non Virtual WAN networks.')
param allowNonVirtualWanTraffic bool = false

@description('Optional. Maximum number of scale units deployed for ExpressRoute gateway.')
param autoScaleConfigurationBoundsMax int = 2

@description('Optional. Minimum number of scale units deployed for ExpressRoute gateway.')
param autoScaleConfigurationBoundsMin int = 2

@description('Optional. List of ExpressRoute connections to the ExpressRoute gateway. **Note:** This parameter will overwrite existing connections, including deleting any that are not provided. This is by-design behavior of the resource provider.')
param expressRouteConnections resourceInput<'Microsoft.Network/expressRouteGateways@2025-07-01'>.properties.expressRouteConnections = []

@description('Required. Resource ID of the Virtual Wan Hub.')
param virtualHubResourceId string

resource expressRouteGateway 'Microsoft.Network/expressRouteGateways@2025-07-01' = {
  name: expressRouteGatewayName
  location: location
  tags: tags
  properties: {
    allowNonVirtualWanTraffic: allowNonVirtualWanTraffic
    autoScaleConfiguration: {
      bounds: {
        max: autoScaleConfigurationBoundsMax
        min: autoScaleConfigurationBoundsMin
      }
    }
    expressRouteConnections: expressRouteConnections
    virtualHub: {
      id: virtualHubResourceId
    }
  }
}


@description('The resource ID of the ExpressRoute Gateway.')
output expressRouteGatewayResourceId string = expressRouteGateway.id

@description('The resource group of the ExpressRoute Gateway was deployed into.')
output expressRouteGatewayResourceGroupName string = resourceGroup().name

@description('The name of the ExpressRoute Gateway.')
output expressRouteGatewayName string = expressRouteGateway.name

@description('The location the resource was deployed into.')
output expressRouteGatewayLocation string = expressRouteGateway.location
