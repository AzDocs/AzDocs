/*
.SYNOPSIS
Creating an ExpressRoute Gateway Connection.
.DESCRIPTION
Creating an ExpressRoute Gateway Connection that wires an ExpressRoute circuit's private peering into a Virtual Hub's ExpressRoute Gateway.
.EXAMPLE
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
.LINKS
- [Bicep Microsoft.Network expressRouteGateways/expressRouteConnections](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/expressroutegateways/expressrouteconnections?pivots=deployment-language-bicep)
- [ExpressRoute connections in Virtual WAN](https://learn.microsoft.com/en-us/azure/virtual-wan/virtual-wan-expressroute-portal)
*/
metadata name = 'Express Route Gateway Connections'
metadata description = 'This module deploys an ExpressRoute connection to an existing ExpressRoute Gateway in a Virtual Hub.'

// ================================================= Parameters =================================================

@description('Required. The name of the existing ExpressRoute Gateway.')
param expressRouteGatewayName string

@description('Required. The name of the ExpressRoute connection.')
@minLength(1)
@maxLength(80)
param expressRouteConnectionName string

@description('Required. The resource ID of the ExpressRoute circuit private peering.')
param expressRouteCircuitPeeringId string

@description('Optional. The routing weight associated to the connection.')
param routingWeight int = 0

@description('Optional. Authorization key to establish the connection (required for cross-subscription circuits).')
@secure()
param authorizationKey string = ''

@description('Optional. Enable internet security (route internet-bound traffic through the hub firewall).')
param enableInternetSecurity bool = false

@description('Optional. Enable FastPath to vNet for the ExpressRoute connection.')
param enableDirectConnect bool = false

// ================================================= Resources =================================================

resource expressRouteGateway 'Microsoft.Network/expressRouteGateways@2025-07-01' existing = {
  name: expressRouteGatewayName
}

resource expressRouteConnection 'Microsoft.Network/expressRouteGateways/expressRouteConnections@2025-07-01' = {
  name: expressRouteConnectionName
  parent: expressRouteGateway
  properties: {
    expressRouteCircuitPeering: {
      id: expressRouteCircuitPeeringId
    }
    routingWeight: routingWeight
    authorizationKey: !empty(authorizationKey) ? authorizationKey : null
    enableInternetSecurity: enableInternetSecurity
    routingConfiguration: enableDirectConnect ? {
      associatedRouteTable: {
        id: '${expressRouteGateway.id}/hubRouteTables/defaultRouteTable'
      }
      propagatedRouteTables: {
        ids: [
          {
            id: '${expressRouteGateway.id}/hubRouteTables/defaultRouteTable'
          }
        ]
        labels: [
          'default'
        ]
      }
    } : null
  }
}

// ================================================= Outputs =================================================

@description('The resource ID of the ExpressRoute connection.')
output expressRouteConnectionResourceId string = expressRouteConnection.id

@description('The name of the ExpressRoute connection.')
output expressRouteConnectionName string = expressRouteConnection.name

@description('The resource group the ExpressRoute connection was deployed into.')
output expressRouteConnectionResourceGroupName string = resourceGroup().name
