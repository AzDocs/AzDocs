/*
.SYNOPSIS
Creating a Virtual Hub.
.DESCRIPTION
Creating a Virtual Hub with the given specs. If you are planning to deploy a Secure Virtual Hub (with an Azure Firewall integrated), please refer to the Azure Firewall module.
.EXAMPLE
<pre>
module virtualHub 'br:contosoregistry.azurecr.io/network/virtualHubs:latest' = {
  name: '${deployment().name}-vhub'
  params: {
    name: virtualHubName
    location: location
    addressPrefix: '10.0.0.0/24'
    virtualWanResourceId: virtualWan.id
    allowBranchToBranchTraffic: true
    sku: 'Standard'
  }
}
</pre>
<p>Creates a Virtual Hub with the specified address prefix and links it to a Virtual WAN.</p>
.LINKS
- [Bicep Microsoft.Network virtualHubs](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/virtualhubs?pivots=deployment-language-bicep)
- [Virtual Hub overview](https://learn.microsoft.com/en-us/azure/virtual-wan/virtual-wan-about)
*/
metadata name = 'Virtual Hubs'
metadata description = '''This module deploys a Virtual Hub.
If you are planning to deploy a Secure Virtual Hub (with an Azure Firewall integrated), please refer to the Azure Firewall module.'''

@description('Required. The virtual hub name.')
param virtualHubName string

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

@description('Optional. Tags of the resource.')
param tags object = {}

@description('Required. Address-prefix for this VirtualHub.')
param addressPrefix string

@description('Optional. Flag to control transit for VirtualRouter hub.')
param allowBranchToBranchTraffic bool = true

@description('Optional. Resource ID of the Azure Firewall to link to.')
param azureFirewallResourceId string = ''

@description('Optional. Resource ID of the Express Route Gateway to link to.')
param expressRouteGatewayResourceId string = ''

@description('Optional. Resource ID of the Point-to-Site VPN Gateway to link to.')
param p2SVpnGatewayResourceId string = ''

@description('Optional. The preferred routing preference for this virtual hub.')
param hubRoutingPreference resourceInput<'Microsoft.Network/virtualHubs@2025-01-01'>.properties.hubRoutingPreference?

@description('Optional. The preferred routing gateway types.')
param preferredRoutingGateway resourceInput<'Microsoft.Network/virtualHubs@2025-01-01'>.properties.preferredRoutingGateway?

@description('Optional. The VirtualHub route tables.')
param routeTableRoutes resourceInput<'Microsoft.Network/virtualHubs@2025-01-01'>.properties.routeTable.routes?

@description('Optional. ID of the Security Partner Provider to link to.')
param securityPartnerProviderResourceId string = ''

@description('Optional. The Security Provider name.')
param securityProviderName string = ''

@allowed([
  'Basic'
  'Standard'
])
@description('Optional. The sku of this VirtualHub.')
param sku string = 'Standard'

@description('Optional. List of all virtual hub route table v2s associated with this VirtualHub.')
param virtualHubRouteTableV2s resourceInput<'Microsoft.Network/virtualHubs@2025-01-01'>.properties.virtualHubRouteTableV2s?

@description('Optional. VirtualRouter ASN.')
@minValue(0)
@maxValue(4294967295)
param virtualRouterAsn resourceInput<'Microsoft.Network/virtualHubs@2025-01-01'>.properties.virtualRouterAsn?

@description('Optional. VirtualRouter IPs.')
param virtualRouterIps resourceInput<'Microsoft.Network/virtualHubs@2025-01-01'>.properties.virtualRouterIps?

@description('Optional. The auto scale configuration for the virtual router.')
param virtualRouterAutoScaleConfiguration resourceInput<'Microsoft.Network/virtualHubs@2025-01-01'>.properties.virtualRouterAutoScaleConfiguration?

@description('Required. Resource ID of the virtual WAN to link to.')
param virtualWanResourceId string

@description('Optional. Resource ID of the VPN Gateway to link to.')
param vpnGatewayResourceId string = ''

resource virtualHub 'Microsoft.Network/virtualHubs@2025-01-01' = {
  name: virtualHubName
  location: location
  tags: tags
  properties: {
    addressPrefix: addressPrefix
    allowBranchToBranchTraffic: allowBranchToBranchTraffic
    azureFirewall: !empty(azureFirewallResourceId)
      ? {
          id: azureFirewallResourceId
        }
      : null
    expressRouteGateway: !empty(expressRouteGatewayResourceId)
      ? {
          id: expressRouteGatewayResourceId
        }
      : null
    p2SVpnGateway: !empty(p2SVpnGatewayResourceId)
      ? {
          id: p2SVpnGatewayResourceId
        }
      : null
    hubRoutingPreference: hubRoutingPreference
    preferredRoutingGateway: preferredRoutingGateway
    routeTable: routeTableRoutes != null
      ? {
          routes: routeTableRoutes
        }
      : null
    securityPartnerProvider: !empty(securityPartnerProviderResourceId)
      ? {
          id: securityPartnerProviderResourceId
        }
      : null
    securityProviderName: securityProviderName
    sku: sku
    virtualHubRouteTableV2s: virtualHubRouteTableV2s
    virtualRouterAsn: virtualRouterAsn != 0 ? virtualRouterAsn : null
    virtualRouterIps: virtualRouterIps
    virtualRouterAutoScaleConfiguration: virtualRouterAutoScaleConfiguration
    virtualWan: {
      id: virtualWanResourceId
    }
    vpnGateway: !empty(vpnGatewayResourceId)
      ? {
          id: vpnGatewayResourceId
        }
      : null
  }
}

@description('Outputs the resource name of the Virtual Hub.')
output virtualHubName string = virtualHub.name
@description('Outputs the Resource ID of the Virtual Hub.')
output virtualHubResourceId string = virtualHub.id
@description('Outputs the resource group the Virtual Hub was deployed into.')
output virtualHubResourceGroupName string = resourceGroup().name
@description('Outputs the location the Virtual Hub was deployed into.')
output virtualHubLocation string = virtualHub.location
