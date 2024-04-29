/*
.SYNOPSIS
Creating a private DNS zone
.DESCRIPTION
Creating a private DNS zone.
.EXAMPLE
<pre>
module dnszone  'br:contosoregistry.azurecr.io/network/privatednszones:latest' ={
  name: '${deployment().name}-dnszone'
  params: {
    privateDnsLinkName: 'kvprivdnslinkname'
    privateDnsZoneName: 'privatelink${environment().suffixes.keyvaultDns}'
    virtualNetworkResourceId: '${subscription().id}/resourceGroups/${platformResourceGroupName}/providers/Microsoft.Network/virtualNetworks/${virtualNetworkName}'
  }
}
TODO
}
</pre>
<p>Creates a private DNS zone with the name private DNS zone name.</p>
.LINKS
- [BICEP Private DNS zone](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/privatednszones?pivots=deployment-language-bicep)
*/
@description('''
The name of the private DNS zone in which the private endpoint can be looked up.
Example
'privatelink.blob.${environment().suffixes.storage}'
''')
@minLength(1)
@maxLength(63)
param privateDnsZoneName string

@description('Auto register your eligible private endpoints within this DNS zone. Note: This should be default false unless you have a good reason to make this true.')
param registrationEnabled bool = false

@description('''
The id of the virtual network you want to create the private endpoint in. Should be pre-existing.
Example:
'${subscription().id}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Network/virtualNetworks/${virtualNetworkName}'
''')
param virtualNetworkResourceId string

@description('''
The name of the virtual network link in the DNS Zone.
After you create a private DNS zone in Azure, you will need to link a virtual network to it.
A virtual network can be linked to private DNS zone as a registration (autoregistration true) or as a resolution virtual network (autoregistration false).
''')
@minLength(1)
@maxLength(80)
param privateDnsLinkName string

@description('Upsert the privateDnsZone')
resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsZoneName
  location: 'global'

  resource virtualNetworkLink 'virtualNetworkLinks@2020-06-01' = {
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
