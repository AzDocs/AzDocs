/*
.SYNOPSIS
Creating an ExpressRoute Circuit Peering.
.DESCRIPTION
Creating an ExpressRoute Circuit Peering with the given specs. Supports Azure Private Peering, Azure Public Peering, and Microsoft Peering types.
.EXAMPLE
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
.LINKS
- [Bicep Microsoft.Network expressRouteCircuits/peerings](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/expressroutecircuits/peerings?pivots=deployment-language-bicep)
- [ExpressRoute Peering](https://learn.microsoft.com/en-us/azure/expressroute/expressroute-circuit-peerings)
*/
metadata name = 'Express Route Circuit Peerings'
metadata description = 'This module deploys an ExpressRoute Circuit Peering.'

// ================================================= Parameters =================================================

@description('Required. The name of the existing ExpressRoute Circuit.')
param expressRouteCircuitName string

@description('Required. The name of the peering.')
param peeringName string

@description('Required. The peering type.')
@allowed([
  'AzurePrivatePeering'
  'AzurePublicPeering'
  'MicrosoftPeering'
])
param peeringType string

@description('Optional. The Azure ASN.')
param azureASN int = 0

@description('Required. The peer ASN.')
@minValue(1)
param peerASN int

@description('Required. The primary address prefix (CIDR notation, e.g. 192.168.1.0/30).')
param primaryPeerAddressPrefix string

@description('Required. The secondary address prefix (CIDR notation, e.g. 192.168.2.0/30).')
param secondaryPeerAddressPrefix string

@description('Required. The VLAN ID.')
param vlanId int

@description('Optional. The peering state.')
@allowed([
  'Disabled'
  'Enabled'
])
param state string = 'Enabled'

@description('Optional. The shared key for the peering.')
@secure()
param sharedKey string = ''

@description('Optional. The primary Azure port.')
param primaryAzurePort string = ''

@description('Optional. The secondary Azure port.')
param secondaryAzurePort string = ''

@description('Optional. The GatewayManager Etag.')
param gatewayManagerEtag string = ''

@description('Optional. The resource ID of the RouteFilter to apply to the peering.')
param routeFilterResourceId string = ''

@description('Optional. The Microsoft peering configuration. Required for MicrosoftPeering type.')
param microsoftPeeringConfig object = {}

@description('Optional. The IPv6 peering configuration.')
param ipv6PeeringConfig object = {}

@description('Optional. The list of circuit connections associated with Azure Private Peering for this circuit.')
param connections array = []

@description('Optional. The peering stats of the ExpressRoute circuit.')
param stats object = {}

// ================================================= Resources =================================================

@description('Reference to the existing ExpressRoute Circuit.')
resource expressRouteCircuit 'Microsoft.Network/expressRouteCircuits@2024-05-01' existing = {
  name: expressRouteCircuitName
}

@description('Upsert the ExpressRoute Circuit Peering with the given parameters.')
resource peering 'Microsoft.Network/expressRouteCircuits/peerings@2024-05-01' = {
  parent: expressRouteCircuit
  name: peeringName
  properties: {
    azureASN: azureASN > 0 ? azureASN : null
    connections: !empty(connections) ? connections : null
    gatewayManagerEtag: !empty(gatewayManagerEtag) ? gatewayManagerEtag : null
    ipv6PeeringConfig: !empty(ipv6PeeringConfig) ? ipv6PeeringConfig : null
    microsoftPeeringConfig: !empty(microsoftPeeringConfig) ? microsoftPeeringConfig : null
    peerASN: peerASN
    peeringType: peeringType
    primaryAzurePort: !empty(primaryAzurePort) ? primaryAzurePort : null
    primaryPeerAddressPrefix: primaryPeerAddressPrefix
    routeFilter: !empty(routeFilterResourceId) ? { id: routeFilterResourceId } : null
    secondaryAzurePort: !empty(secondaryAzurePort) ? secondaryAzurePort : null
    secondaryPeerAddressPrefix: secondaryPeerAddressPrefix
    sharedKey: !empty(sharedKey) ? sharedKey : null
    state: state
    stats: !empty(stats) ? stats : null
    vlanId: vlanId
  }
}

// ================================================= Outputs =================================================

@description('The resource ID of the ExpressRoute Circuit Peering.')
output peeringResourceId string = peering.id

@description('The name of the ExpressRoute Circuit Peering.')
output peeringName string = peering.name

@description('The resource group the ExpressRoute Circuit Peering was deployed into.')
output peeringResourceGroupName string = resourceGroup().name

@description('The peering type of the ExpressRoute Circuit Peering.')
output peeringType string = peering.properties.peeringType
