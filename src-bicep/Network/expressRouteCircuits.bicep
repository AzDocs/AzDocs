/*
.SYNOPSIS
Creating an ExpressRoute Circuit.
.DESCRIPTION
Creating an ExpressRoute Circuit with the given specs and secure defaults.
.EXAMPLE
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
.LINKS
- [Bicep Microsoft.Network expressRouteCircuits](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/expressroutecircuits?pivots=deployment-language-bicep)
- [ExpressRoute Overview](https://learn.microsoft.com/en-us/azure/expressroute/expressroute-introduction)
*/
metadata name = 'Express Route Circuits'
metadata description = 'This module deploys an ExpressRoute Circuit.'

// ================================================= Parameters =================================================

@description('Required. The name of the ExpressRoute Circuit.')
@minLength(1)
@maxLength(80)
param expressRouteCircuitName string

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

@description('Optional. Tags of the ExpressRoute Circuit resource.')
param tags object = {}

// SKU parameters
@description('Required. The name of the SKU. Follows the format {tier}_{family}, e.g. Standard_MeteredData.')
param skuName string

@description('Required. The tier of the SKU.')
@allowed([
  'Basic'
  'Local'
  'Premium'
  'Standard'
])
param skuTier string

@description('Required. The family of the SKU.')
@allowed([
  'MeteredData'
  'UnlimitedData'
])
param skuFamily string

// Service Provider Properties (used when provisioning through a service provider)
@description('Optional. The name of the service provider. Required when provisioning through a service provider.')
param serviceProviderName string = ''

@description('Optional. The peering location. Required when provisioning through a service provider.')
param peeringLocation string = ''

@description('Optional. The bandwidth in Mbps. Required when provisioning through a service provider.')
param bandwidthInMbps int = 0

// ExpressRoute Direct Properties (used when provisioning on an ExpressRoute Port)
@description('Optional. The bandwidth of the circuit in Gbps. Used when the circuit is provisioned on an ExpressRoutePort resource.')
param bandwidthInGbps int = 0

@description('Optional. The resource ID of the ExpressRoutePort resource when the circuit is provisioned on an ExpressRoutePort resource.')
param expressRoutePortResourceId string = ''

// Circuit properties
@description('Optional. Allow classic operations on the circuit.')
param allowClassicOperations bool = false

@description('Optional. The authorization key for the circuit.')
param authorizationKey string = ''

@description('Optional. The list of authorizations for the circuit.')
param authorizations array = []

@description('Optional. The circuit provisioning state.')
param circuitProvisioningState string = ''

@description('Optional. Flag denoting rate-limiting status of the ExpressRoute direct-port circuit.')
param enableDirectPortRateLimit bool = false

@description('Optional. The GatewayManager Etag.')
param gatewayManagerEtag string = ''

@description('Optional. Flag denoting global reach status.')
param globalReachEnabled bool = false

@description('Optional. The list of peerings for the circuit.')
param peerings array = []

@description('Optional. The ServiceKey of the circuit.')
param serviceKey string = ''

@description('Optional. The service provider notes.')
param serviceProviderNotes string = ''

@description('Optional. The service provider provisioning state.')
@allowed([
  ''
  'Deprovisioning'
  'NotProvisioned'
  'Provisioned'
  'Provisioning'
])
param serviceProviderProvisioningState string = ''

// ================================================= Variables =================================================

var serviceProviderProperties = !empty(serviceProviderName) ? {
  serviceProviderName: serviceProviderName
  peeringLocation: peeringLocation
  bandwidthInMbps: bandwidthInMbps
} : null

// ================================================= Resources =================================================

@description('Upsert the ExpressRoute Circuit with the given parameters.')
resource expressRouteCircuit 'Microsoft.Network/expressRouteCircuits@2025-07-01' = {
  name: expressRouteCircuitName
  location: location
  tags: tags
  sku: {
    name: skuName
    tier: skuTier
    family: skuFamily
  }
  properties: {
    allowClassicOperations: allowClassicOperations
    authorizationKey: !empty(authorizationKey) ? authorizationKey : null
    authorizations: !empty(authorizations) ? authorizations : null
    bandwidthInGbps: bandwidthInGbps > 0 ? bandwidthInGbps : null
    circuitProvisioningState: !empty(circuitProvisioningState) ? circuitProvisioningState : null
    enableDirectPortRateLimit: enableDirectPortRateLimit
    expressRoutePort: !empty(expressRoutePortResourceId) ? { id: expressRoutePortResourceId } : null
    gatewayManagerEtag: !empty(gatewayManagerEtag) ? gatewayManagerEtag : null
    globalReachEnabled: globalReachEnabled
    peerings: !empty(peerings) ? peerings : null
    serviceKey: !empty(serviceKey) ? serviceKey : null
    serviceProviderNotes: !empty(serviceProviderNotes) ? serviceProviderNotes : null
    serviceProviderProperties: serviceProviderProperties
    serviceProviderProvisioningState: !empty(serviceProviderProvisioningState) ? serviceProviderProvisioningState : null
  }
}

// ================================================= Outputs =================================================

@description('The resource ID of the ExpressRoute Circuit.')
output expressRouteCircuitResourceId string = expressRouteCircuit.id

@description('The resource group the ExpressRoute Circuit was deployed into.')
output expressRouteCircuitResourceGroupName string = resourceGroup().name

@description('The name of the ExpressRoute Circuit.')
output expressRouteCircuitName string = expressRouteCircuit.name

@description('The service key of the ExpressRoute Circuit.')
output expressRouteCircuitServiceKey string = expressRouteCircuit.properties.serviceKey
