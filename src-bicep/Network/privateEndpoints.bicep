@description('Specifies the Azure location where the key vault should be created.')
param location string = resourceGroup().location

@description('''
The target resource id where this private endpoint is created for.
''')
param targetResourceId string

@description('''
The tags to apply to this resource. This is an object with key/value pairs.
Example:
{
  FirstTag: myvalue
  SecondTag: another value
}
''')
param tags object = {}

@description('''
The name for the private endpoint for the automation account
''')
param privateEndpointName string

@description('''
The name of the virtual network you want to create the private endpoint in. Should be pre-existing.
''')
param virtualNetworkName string

@description('''
The name of the subnet in the virtual network you want to create the private endpoint in. Should be pre-existing.
''')
param subnetName string

@description('''
String containing the resource id of the subnet you want to create the private endpoint in.
Example:
'${subscription().id}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Network/virtualNetworks/${virtualNetworkName}/subnets/${subnetName}'
''')
param virtualNetworkResourceId string = '${subscription().id}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Network/virtualNetworks/${virtualNetworkName}'

@description('''
The name of the private DNS zone the private endpoint can be looked up.
''')
param privateDnsZoneName string

@description('The name of the Virtual Network Link in the DNS Zone.')
param privateDnsLinkName string

@description('''
The name of the resourcegroup where the private DNS zone for the private endpoint resides or will reside in.
''')
param privateDnsZoneResourceGroupName string = az.resourceGroup().name

@description('The group ID to apply to this private endpoint.')
param privateEndpointGroupId string

@description('Optional parameter to change the default connection name.')
param privateLinkServiceConnectionName string = '${privateEndpointName}-${privateEndpointGroupId}-${virtualNetworkName}-${subnetName}'

@description('Auto register your eligible private endpoints within this DNS zone.')
param registrationEnabled bool = true

var subnetResourceId = '${virtualNetworkResourceId}/subnets/${subnetName}'

module privateDnsZone 'privateDnsZones.bicep' = {
  name: format('{0}-{1}', take('${deployment().name}', 53), 'pvtDnsZone')
  scope: az.resourceGroup(az.subscription().subscriptionId, privateDnsZoneResourceGroupName)
  params: {
    privateDnsZoneName: privateDnsZoneName
    privateDnsLinkName: privateDnsLinkName
    virtualNetworkResourceId: virtualNetworkResourceId
    registrationEnabled: registrationEnabled
  }
}

@description('''
Upsert the private endpoint & private dns zone group

Private DNS Zone Groups are a kind of link back to one or multiple Private DNS Zones.
With this connection, an A-Record will automatically be created, updated or removed on the referenced Private DNS Zone depending on the Private Endpoint configuration.
''')
resource privateEndpoint 'Microsoft.Network/privateEndpoints@2020-11-01' = {
  name: privateEndpointName
  location: location
  tags: tags
  properties: {
    privateLinkServiceConnections: [
      {
        name: privateLinkServiceConnectionName
        properties: {
          privateLinkServiceId: targetResourceId
          groupIds: [
            privateEndpointGroupId
          ]
          privateLinkServiceConnectionState: {
            description: 'Auto-approved'
            actionsRequired: 'None'
          }
        }
      }
    ]
    manualPrivateLinkServiceConnections: []
    subnet: {
      id: subnetResourceId
    }
  }

  resource privateEndpointZoneGroup 'privateDnsZoneGroups@2020-11-01' = {
    name: 'dnsgroupname'
    properties: {
      privateDnsZoneConfigs: [
        {
          name: replace(replace(replace(privateDnsZone.name, '-', '--'), '.', '-'), '*', 'wildcard')
          properties: {
            privateDnsZoneId: privateDnsZone.outputs.privateDnsZoneResourceId
          }
        }
      ]
    }
  }
}
