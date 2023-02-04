/*
.SYNOPSIS
Creating a private endpoint
.DESCRIPTION
Creating a private endpoint for a resource.
.EXAMPLE
<pre>
module privateendpoint 'br:acrazdocsprd.azurecr.io/network/privateendpoints:latest' = {
  name: '${deployment().name}-stgpetest'
  params: {
    privateDnsLinkName: 'stgprivdnslinkname'
    privateDnsZoneName: 'privatelink.blob.${environment().suffixes.storage}'
    privateEndpointGroupId: 'blob'
    subnetName: privateEndpointSubnetName
    targetResourceId: storageAccount.outputs.storageAccountResourceId
    privateEndpointName: 'myStgPrivateEndpoint'
    virtualNetworkName: virtualNetworkName
    virtualNetworkResourceId: virtualNetworkResourceId
    location: location
    privateDnsZoneResourceGroupName: privateDnsZoneResourceGroupName
  }
}
</pre>
<p>Creates a private endpoint with the name privateEndpointName. You can decide to host the DNS zones in a different resourcegroup than the VNET resourcegroup.</p>
.LINKS
- [BICEP Private Endpoint](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/privateendpoints?pivots=deployment-language-bicep)
*/
@description('Specifies the Azure location where the private endpoint should be created.')
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
The name for the private endpoint resource to be upserted.
''')
@minLength(2)
@maxLength(64)
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
String containing the resource id of the virtual network you want to create the private endpoint in.
Example:
'${subscription().id}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Network/virtualNetworks/${virtualNetworkName}'
''')
param virtualNetworkResourceId string = '${subscription().id}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Network/virtualNetworks/${virtualNetworkName}'

@description('''
The name of the private DNS zone in which the private endpoint can be looked up.
Example:
'privatelink.blob.${environment().suffixes.storage}'
''')
@minLength(1)
@maxLength(63)
param privateDnsZoneName string

@description('''
The name of the virtual network link in the DNS Zone.
After you create a private DNS zone in Azure, you will need to link a virtual network to it.
A virtual network can be linked to private DNS zone as a registration (autoregistration true) or as a resolution virtual network (autoregistration false).
''')
@minLength(1)
@maxLength(80)
param privateDnsLinkName string

@description('''
The name of the resourcegroup where the private DNS zone for the private endpoint resides or will reside in.
''')
param privateDnsZoneResourceGroupName string = az.resourceGroup().name

@description('''
The ID(s) of the group(s) obtained from the remote resource that this private endpoint should connect to.
For example: blob, queue, table, file, registry, sites
Example
[
  'sqlServer'
]
''')
param privateEndpointGroupId string

@description('Optional parameter to change the default connection name.')
param privateLinkServiceConnectionName string = '${privateEndpointName}-${privateEndpointGroupId}-${virtualNetworkName}-${subnetName}'

@description('Auto register your eligible private endpoints within this DNS zone. Note: This should be default false unless you have a good reason to make this true')
param registrationEnabled bool = false

@description('The resourceId of the subnet you want to put the private endpoint in.')
var subnetResourceId = '${virtualNetworkResourceId}/subnets/${subnetName}'

module privateDnsZone 'privateDnsZones.bicep' = {  //TODO: ?should this not be: br:acrazdocsprd.azurecr.io/network/privatednszones:latest
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
resource privateEndpoint 'Microsoft.Network/privateEndpoints@2022-07-01' = {
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

  resource privateEndpointZoneGroup 'privateDnsZoneGroups@2022-07-01' = {
    name: 'dnsgroupname'
    properties: {
      privateDnsZoneConfigs: [
        {
          name: replace(replace(replace(privateDnsZoneName, '-', '--'), '.', '-'), '*', 'wildcard')
          properties: {
            privateDnsZoneId: privateDnsZone.outputs.privateDnsZoneResourceId
          }
        }
      ]
    }
  }
}
