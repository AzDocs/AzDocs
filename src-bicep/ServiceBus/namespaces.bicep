/*
.SYNOPSIS
Creating a Service Bus Namespace
.DESCRIPTION
Creating a Service Bus Namespace resource with the given specs.
.EXAMPLE
<pre>
module serviceBusNamespace 'br:contosoregistry.azurecr.io/servicebus/namespaces:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 50), 'sbnamespace')
  scope: resourceGroup
  params: {
    serviceBusNamespaceName: serviceBusNamespaceName
    disableLocalAuth: false
    publicNetworkAccess: true
    location: location
    serviceBusMinimumTlsVersion: '1.2'
    skuName: 'Standard'
    skuCapacity: 1
  }
}
</pre>
<p>Creates a servicebus namespace with the name 'ServiceBusNamespace'</p>
.LINKS
- [Bicep Microsoft.ServiceBus Namespaces](https://learn.microsoft.com/en-us/azure/templates/microsoft.servicebus/namespaces?pivots=deployment-language-bicep)
*/

@description('The name of the servicebus namespace. This will be the target servicebus where systemevents will be delivered.')
param serviceBusNamespaceName string

@description('Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location.')
param location string = resourceGroup().location

@description('Specifies the sku of the servicebus namespace.')
@allowed([
  'Basic'
  'Premium'
  'Standard'
])
param skuName string = 'Standard'

@description('Messaging units for your service bus premium namespace. Valid capacities are {1, 2, 4, 8, 16} multiples of your properties.premiumMessagingPartitions setting. For example, If properties.premiumMessagingPartitions is 1 then possible capacity values are 1, 2, 4, 8, and 16. If properties.premiumMessagingPartitions is 4 then possible capacity values are 4, 8, 16, 32 and 64.')
@allowed([
  1
  2
  4
  8
  16
])
param skuCapacity int = 1

@description('Set the minimum TLS version to be permitted on requests to this servicebus.')
@allowed([
  '1.0'
  '1.1'
  '1.2'
])
param serviceBusMinimumTlsVersion string = '1.2'

@description('''
The default network action for this Azure Service Bus.
Disabling public network access is not allowed for SKU Basic and SKU Standard.''')
param publicNetworkAccess bool = false

@description('This property disables SAS authentication for the Service Bus namespace.')
param disableLocalAuth bool = true

@description('Enabling this property creates a Premium Service Bus Namespace in regions supported availability zones.')
param zoneRedundant bool = false

resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2022-01-01-preview' = {
  name: serviceBusNamespaceName
  location: location
  sku: {
    capacity: skuCapacity
    name: skuName
    tier: skuName
  }
  properties: {
    minimumTlsVersion: serviceBusMinimumTlsVersion
    publicNetworkAccess: publicNetworkAccess ? 'Enabled' : 'Disabled'
    disableLocalAuth: disableLocalAuth
    zoneRedundant: zoneRedundant
  }
}

output serviceBusNamespaceId string = serviceBusNamespace.id
output serviceBusNamespaceName string = serviceBusNamespace.name
