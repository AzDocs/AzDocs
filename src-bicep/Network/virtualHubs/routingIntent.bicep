/*
.SYNOPSIS
Configuring Routing Intent for a Virtual Hub.
.DESCRIPTION
Configuring Routing Intent for a Virtual Hub with the given specs. This module requires an existing Virtual Hub and Azure Firewall.
.EXAMPLE
<pre>
module routingIntent 'br:contosoregistry.azurecr.io/network/routingIntent:latest' = {
  name: '${deployment().name}-routingintent'
  params: {
    virtualHubName: virtualHub.name
    azureFirewallResourceId: azureFirewall.id
    privateToFirewall: true
    internetToFirewall: true
  }
}
</pre>
<p>Creates a Routing Intent configuration that routes both private and internet traffic to the Azure Firewall.</p>
.LINKS
- [Bicep Microsoft.Network virtualHubs/routingIntent](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/virtualhubs/routingintent?pivots=deployment-language-bicep)
- [Virtual Hub Routing Intent](https://learn.microsoft.com/en-us/azure/virtual-wan/how-to-routing-policies)
*/
metadata name = 'Virtual Hub Routing Intent'
metadata description = 'This module configures Routing Intent for a Virtual Hub; this module requires an existing Virtual Hub, as well the firewall Resource ID.'

@description('Required. Hub firewall Resource ID.')
param azureFirewallResourceId string

@description('Optional. The name of the routing intent configuration.')
param routingIntentName string = 'defaultRouteTable'

@description('Required. Name of the Virtual Hub.')
param virtualHubName string

@description('Optional. Configures Routing Intent to forward Private traffic to the firewall (RFC1918).')
param privateToFirewall bool = true

@description('Optional. Configures Routing Intent to Forward Internet traffic to the firewall (0.0.0.0/0).')
param internetToFirewall bool = true

resource virtualHub 'Microsoft.Network/virtualHubs@2025-01-01' existing = {
  name: virtualHubName
}

resource routingIntent 'Microsoft.Network/virtualHubs/routingIntent@2025-01-01' = {
  name: routingIntentName
  parent: virtualHub
  properties: {
    routingPolicies: union(
      internetToFirewall == true
        ? [
            {
              name: '_policy_PublicTraffic'
              destinations: [
                'Internet'
              ]
              nextHop: azureFirewallResourceId
            }
          ]
        : [],
      privateToFirewall == true
        ? [
            {
              name: '_policy_PrivateTraffic'
              destinations: [
                'PrivateTraffic'
              ]
              nextHop: azureFirewallResourceId
            }
          ]
        : []
    )
  }
}

@description('The name of the Routing Intent configuration.')
output routingIntentName string = routingIntent.name

@description('The resource ID of the Routing Intent configuration.')
output routingIntentResourceId string = routingIntent.id

@description('The resource group the Routing Intent configuration was deployed into.')
output routingIntentResourceGroupName string = resourceGroup().name
