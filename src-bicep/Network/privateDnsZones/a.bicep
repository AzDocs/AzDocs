/*
.SYNOPSIS
Creating an A record in a private Dns zone
.DESCRIPTION
Creating an A record in a private Dns zone with the given specs.
.EXAMPLE
<pre>
module aRecord 'br:contosoregistry.azurecr.io/network/privatednszones/a:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 56), 'arecord')
  params: {
    privateDnsZoneName: managedEnvironment.outputs.privateDnsZoneName
    aRecordName: '*'
    aRecordIpv4Address: managedEnvironment.outputs.managedEnvironmentStaticIp
  }
}
</pre>
<p>Creates an Arecord in the private Dns zone for a container app</p>
.LINKS
- [Bicep Microsoft.Network Private Dns zone A Record](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/privatednszones/a?pivots=deployment-language-bicep)
*/

// ================================================= Parameters =================================================
@description('''
The name of the private DNS zone in which the private endpoint can be looked up.
Example
'privatelink.blob.${environment().suffixes.storage}'
''')
@minLength(1)
@maxLength(63)
param privateDnsZoneName string

@description('''
The name for the A record in the private DNS zone.
Example:
'blob',
'*'
''')
param aRecordName string

@description('The TTL for the A record')
param aRecordTtl int = 300

@description('The ipv4 address for the A record')
param aRecordIpv4Address string


// ===================================== Resources =====================================
resource privateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' existing = {
  name: privateDnsZoneName
}

resource arecord 'Microsoft.Network/privateDnsZones/A@2024-06-01' = {
  parent: privateDnsZone
  name: aRecordName
  properties: {
    ttl: aRecordTtl
    aRecords: [
      {
        ipv4Address: aRecordIpv4Address
      }
    ]
  }
}
