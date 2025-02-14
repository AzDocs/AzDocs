/*
.SYNOPSIS
Creating a private endpoint
.DESCRIPTION
Creating a private endpoint for a resource.
.EXAMPLE
<pre>
module privateendpoint 'br:contosoregistry.azurecr.io/network/privateendpoints:latest' = {
  name: '${deployment().name}-stgpetest'
  params: {
    location: location
    privateEndpointGroupId: 'sqlServer'
    subnetName: 'privateendpointsubnet'
    targetResourceId: sqlserver.outputs.sqlServerResourceId
    privateEndpointName: 'mysqlpe'
    virtualNetworkResourceGroupName: 'vnetresourcegroupname'
    virtualNetworkName: 'vnetname'
  }
}
</pre>
<p>Creates a private endpoint with the name privateEndpointName without creating a private DNS zone./p>
.EXAMPLE
<pre>
module privateendpoint 'br:contosoregistry.azurecr.io/network/privateendpoints:latest' = {
  name: '${deployment().name}-stgpetest'
  params: {
    privateDnsLinkName: 'stgprivdnslinkname'
    privateDnsZoneName: 'privatelink.blob.${environment().suffixes.storage}'
    privateEndpointGroupId: 'blob'
    subnetName: privateEndpointSubnetName
    targetResourceId: storageAccount.outputs.storageAccountResourceId
    privateEndpointName: 'myStgPrivateEndpoint'
    virtualNetworkName: virtualNetworkName
    virtualNetworkResourceGroupName: privateDnsZoneResourceGroupName
    location: location
  }
}
</pre>
<p>Creates a private endpoint with the name privateEndpointName. You can decide to host the DNS zones in a different resourcegroup than the VNET resourcegroup. The IP address is dynamic</p>
.EXAMPLE
<pre>
module privateendpoint 'br:contosoregistry.azurecr.io/network/privateendpoints:latest' = {
  name: '${deployment().name}-stgpetest'
  params: {
    privateDnsLinkName: 'stgprivdnslinkname'
    privateDnsZoneName: 'privatelink.blob.${environment().suffixes.storage}'
    privateEndpointGroupId: 'blob'
    subnetName: privateEndpointSubnetName
    targetResourceId: storageAccount.outputs.storageAccountResourceId
    privateEndpointName: 'myStgPrivateEndpoint'
    virtualNetworkName: virtualNetworkName
    location: location
    privateDnsZoneResourceGroupName: privateDnsZoneResourceGroupName
    customNetworkInterfaceName: 'myCustomNetworkInterfaceName'
    ipConfigurations: [
      {
        name: 'IPConfigName'
        properties: {
          groupId: 'blob'
          memberName: 'blob'
          privateIPAddress: '10.0.0.5'
        }
      }
    ]
  }
}
</pre>
<p>Creates a private endpoint with the name privateEndpointName. You can decide to host the DNS zones in a different resourcegroup than the VNET resourcegroup.The Ip address is static</p>
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

@description('The name of the resource group where the virtual network resides in.')
param virtualNetworkResourceGroupName string = resourceGroup().name

@description('The name of the subnet in the virtual network you want to create the private endpoint in. Should be pre-existing.')
param subnetName string

@description('''
The name of the private DNS zone in which the private endpoint can be looked up.
Example:
'privatelink.blob.${environment().suffixes.storage}'
''')
@maxLength(63)
param privateDnsZoneName string = ''

@description('''
The name of the virtual network link in the DNS Zone.
After you create a private DNS zone in Azure, you will need to link a virtual network to it.
A virtual network can be linked to private DNS zone as a registration (autoregistration true) or as a resolution virtual network (autoregistration false).
''')
@minLength(1)
@maxLength(80)
param privateDnsLinkName string = privateEndpointName

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

@description('The custom name of the network interface attached to the private endpoint. If this parameter is omitted, a random network interface name is generated by Azure.')
param customNetworkInterfaceName string = ''

@description('''
Parameter used for defining static IP(s) for the private endpoint, see https://learn.microsoft.com/en-us/azure/templates/microsoft.network/privateendpoints?pivots=deployment-language-bicep#privateendpointipconfiguration. The array should contain at least one PrivateEndpointIPConfiguration object which has the following parameters:
  name: A name for the IPConfiguration resource that is unique within a resource group.
  groupId: The ID of a group obtained from the remote resource that this private endpoint should connect to (same as the privateEndpointGroupId parameter defined above).
  memberName: The member name of a group obtained from the remote resource that this private endpoint should connect to. For most resources it's equal to the groupId. See https://learn.microsoft.com/en-us/azure/private-link/manage-private-endpoint?tabs=manage-private-link-cli for more info on how to obtain this property.
  privateIPAddress: A private ip address obtained from the private endpoint's subnet.
Example
[
  {
    name: 'IPConfigName'
    properties: {
      groupId: 'blob'
      memberName: 'blob'
      privateIPAddress: '0.0.0.0'
    }
  }
]
''')
param ipConfigurations array = []

@description('Whether or not to create a private DNS zone for the private endpoint. If this parameter false, no private DNS zone will be created.')
param createPrivateDnsZone bool = false

//################## Existing Resources ##################
resource vnet 'Microsoft.Network/virtualNetworks@2023-06-01' existing = {
  name: virtualNetworkName
  scope: resourceGroup(virtualNetworkResourceGroupName)
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-06-01' existing = {
  parent: vnet
  name: subnetName
}

//################## Creating Resources ##################
module privateDnsZone 'privateDnsZones.bicep' = if (createPrivateDnsZone) {
  name: format('{0}-{1}', take('${deployment().name}', 53), 'pvtDnsZone')
  scope: az.resourceGroup(az.subscription().subscriptionId, privateDnsZoneResourceGroupName)
  params: {
    privateDnsZoneName: privateDnsZoneName
    privateDnsLinkName: privateDnsLinkName
    virtualNetworkResourceId: vnet.id
    registrationEnabled: registrationEnabled
  }
}

@description('''
Upsert the private endpoint & private dns zone group
Private DNS Zone Groups are a kind of link back to one or multiple Private DNS Zones.
With this connection, an A-Record will automatically be created, updated or removed on the referenced Private DNS Zone depending on the Private Endpoint configuration.
''')
resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-06-01' = {
  name: privateEndpointName
  location: location
  tags: tags
  properties: {
    customNetworkInterfaceName: customNetworkInterfaceName
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
    ipConfigurations: ipConfigurations
    manualPrivateLinkServiceConnections: []
    subnet: {
      id: subnet.id
    }
  }

  resource privateEndpointZoneGroup 'privateDnsZoneGroups@2023-06-01' = if (createPrivateDnsZone) {
    name: 'dnsgroupname'
    properties: {
      privateDnsZoneConfigs: [
        {
          name: replace(replace(replace(privateDnsZoneName, '-', '--'), '.', '-'), '*', 'wildcard')
          properties: {
            privateDnsZoneId: resourceId(
              subscription().subscriptionId,
              privateDnsZoneResourceGroupName,
              'Microsoft.Network/privateDnsZones',
              privateDnsZoneName
            )
          }
        }
      ]
    }
  }
}
