@description('''
The name of the private DNS zone the private endpoint can be looked up.
''')
param privateDnsZoneName string

@description('Auto register your eligible private endpoints within this DNS zone.')
param registrationEnabled bool = true

@description('''
The name of the virtual network you want to create the private endpoint in. Should be pre-existing.
''')
param virtualNetworkResourceId string

@description('The name of the Virtual Network Link in the DNS Zone.')
param privateDnsLinkName string

@description('Upsert the privateDnsZone')
resource privateDnsZone 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: privateDnsZoneName
  location: 'global'

  resource symbolicname 'virtualNetworkLinks@2020-06-01' = {
    name: privateDnsLinkName
    location: 'global'
    properties: {
      registrationEnabled: registrationEnabled
      virtualNetwork: {
        id: virtualNetworkResourceId
      }
    }
  }
}

@description('The Resource ID of the upserted Private DNS Zone.')
output privateDnsZoneResourceId string = privateDnsZone.id
