/*
.SYNOPSIS
Creating an ExpressRoute Circuit Peering Connection.
.DESCRIPTION
Creating an ExpressRoute Circuit Peering Connection (Global Reach) to connect two ExpressRoute circuits via their private peerings.
.EXAMPLE
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
.LINKS
- [Bicep Microsoft.Network expressRouteCircuits/peerings/connections](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/expressroutecircuits/peerings/connections?pivots=deployment-language-bicep)
- [ExpressRoute Global Reach](https://learn.microsoft.com/en-us/azure/expressroute/expressroute-global-reach)
*/
metadata name = 'Express Route Circuit Peering Connections'
metadata description = 'This module deploys an ExpressRoute Circuit Peering Connection (Global Reach).'

// ================================================= Parameters =================================================

@description('Required. The name of the existing ExpressRoute Circuit.')
param expressRouteCircuitName string

@description('Required. The name of the existing peering on the ExpressRoute Circuit.')
param peeringName string

@description('Required. The name of the connection.')
param connectionName string

@description('Required. The /29 IP address space to carve out customer addresses for tunnels.')
param addressPrefix string

@description('Optional. The authorization key for the connection.')
param authorizationKey string = ''

@description('Required. The resource ID of the Express Route Circuit Private Peering of the circuit initiating the connection.')
param expressRouteCircuitPeeringResourceId string

@description('Required. The resource ID of the Express Route Circuit Private Peering of the peered circuit.')
param peerExpressRouteCircuitPeeringResourceId string

@description('Optional. The /125 IPv6 address space to carve out customer addresses for Global Reach.')
param ipv6CircuitConnectionAddressPrefix string = ''

// ================================================= Resources =================================================

@description('Reference to the existing ExpressRoute Circuit.')
resource expressRouteCircuit 'Microsoft.Network/expressRouteCircuits@2024-05-01' existing = {
  name: expressRouteCircuitName
}

@description('Reference to the existing peering on the ExpressRoute Circuit.')
resource existingPeering 'Microsoft.Network/expressRouteCircuits/peerings@2024-05-01' existing = {
  parent: expressRouteCircuit
  name: peeringName
}

@description('Upsert the ExpressRoute Circuit Peering Connection with the given parameters.')
resource connection 'Microsoft.Network/expressRouteCircuits/peerings/connections@2024-05-01' = {
  parent: existingPeering
  name: connectionName
  properties: {
    addressPrefix: addressPrefix
    authorizationKey: !empty(authorizationKey) ? authorizationKey : null
    expressRouteCircuitPeering: {
      id: expressRouteCircuitPeeringResourceId
    }
    ipv6CircuitConnectionConfig: !empty(ipv6CircuitConnectionAddressPrefix) ? {
      addressPrefix: ipv6CircuitConnectionAddressPrefix
    } : null
    peerExpressRouteCircuitPeering: {
      id: peerExpressRouteCircuitPeeringResourceId
    }
  }
}

// ================================================= Outputs =================================================

@description('The resource ID of the ExpressRoute Circuit Peering Connection.')
output connectionResourceId string = connection.id

@description('The name of the ExpressRoute Circuit Peering Connection.')
output connectionName string = connection.name

@description('The resource group the ExpressRoute Circuit Peering Connection was deployed into.')
output connectionResourceGroupName string = resourceGroup().name
