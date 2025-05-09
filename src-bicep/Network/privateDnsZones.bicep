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
.EXAMPLE
<pre>
module dnszone  'br:contosoregistry.azurecr.io/network/privatednszones:latest' ={
  name: '${deployment().name}-dnszone'
  params: {
    privateDnsLinkName: 'kvprivdnslinkname'
    VirtualNetworkLinks: [
      {
        privateDnsLinkName: 'privatelink${environment().suffixes.keyvaultDns}'
        virtualNetworkResourceId: '${subscription().id}/resourceGroups/${platformResourceGroupName}/providers/Microsoft.Network/virtualNetworks/${virtualNetworkName}'
      }
    ]
    
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

type ResolutionPolicyType = 'Default' | 'NxDomainRedirect'

@description('''
The resolution policy on the virtual network link. Only applicable for virtual network links to privatelink zones, and for A,AAAA,CNAME queries. 
When set to 'NxDomainRedirect', Azure DNS resolver falls back to public resolution if private dns query resolution results in non-existent domain response.
''')
param resolutionPolicy ResolutionPolicyType = 'Default'

@description('''
The id of the virtual network you want to link to. Should be pre-existing.
Example:
'${subscription().id}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Network/virtualNetworks/${virtualNetworkName}'
''')
param virtualNetworkResourceId string = ''

@description('''
The name of the virtual network link in the DNS Zone.
After you create a private DNS zone in Azure, you will need to link a virtual network to it.
A virtual network can be linked to private DNS zone as a registration (autoregistration true) or as a resolution virtual network (autoregistration false).
''')
@minLength(0)
@maxLength(80)
param privateDnsLinkName string = ''

@description('''
For adding virtual network links to the private DNS zone.
''')
type virtualNetworkLinkType = {
  @minLength(0)
  @maxLength(80)
  privateDnsLinkName: string
  registrationEnabled: bool?
  resolutionPolicy: ResolutionPolicyType?
  virtualNetworkResourceId: string
}

@description('''
If you need multiple network links you can use this property to add multiple links in one go.
''')
param VirtualNetworkLinks virtualNetworkLinkType[] = []

var allLinks = union(
  VirtualNetworkLinks,
  !empty(privateDnsLinkName)
    ? [
        {
          privateDnsLinkName: privateDnsLinkName
          registrationEnabled: registrationEnabled
          resolutionPolicy: resolutionPolicy
          virtualNetworkResourceId: virtualNetworkResourceId
        }
      ]
    : []
)

@description('Upsert the privateDnsZone')
resource privateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' = {
  name: privateDnsZoneName
  location: 'global'

  @batchSize(1)
  resource virtualNetworkLink 'virtualNetworkLinks@2024-06-01' = [
    for link in allLinks: if (!empty(link.privateDnsLinkName)) {
      name: link.privateDnsLinkName
      location: 'global'
      properties: {
        registrationEnabled: link.registrationEnabled ?? false
        resolutionPolicy: startsWith(privateDnsZoneName, 'privatelink') ? link.resolutionPolicy : null
        virtualNetwork: {
          id: link.virtualNetworkResourceId
        }
      }
    }
  ]
}

@description('The Resource ID of the upserted Private DNS Zone.')
output privateDnsZoneResourceId string = privateDnsZone.id

@description('The name of the upserted Private DNS Zone.')
output privateDnsZoneName string = privateDnsZone.name
