/*
.SYNOPSIS
Creating a public ip prefix resource.
.DESCRIPTION
Creating public ip prefixes. A public IP address prefix is a contiguous range of standard SKU public IP addresses.
When you create a public IP address resource, you can assign a static public IP address from the prefix and associate the address to virtual machines, load balancers, or other resources.
.EXAMPLE
<pre>
module publicipprefix 'br:contosoregistry.azurecr.io/network/publicipprefixes:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 49), 'publicipprefix')
  params: {
    publicIPPrefixesName: 'aksNodePublicIP'
    location: location
    publicIPPrefixesPrefixLength:31
  }
}
</pre>
<p>Creates a public ip prefixes with 2 ip adresses with the name aksNodePublicIP</p>
.LINKS
- [Bicep Microsoft.Network public ip prefixes](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/publicipprefixes?pivots=deployment-language-bicep)
*/

// ===================================== Parameters =====================================
@description('Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location.')
param location string = resourceGroup().location

@description('''
The tags to apply to this resource. This is an object with key/value pairs.
Example:
{
  FirstTag: myvalue
  SecondTag: another value
}
''')
param tags object = {}

@description('The public IP prefix SKU. Tier can be Global or Regional')
param publicIPPrefixesSku object = {
  name: 'Standard'
  tier: 'Regional'
}

@description('The name for the public ip prefixes resource.')
@minLength(1)
@maxLength(80)
param publicIPPrefixesName string

@description('''
How many Public IPs you want to be available. A value of 28 for IPv4 means 16 addresses. A value of 124 for IPv6 means 16 addresses.
The following public IP prefix sizes are currently available:
/28 (IPv4) or /124 (IPv6) = 16 addresses
/29 (IPv4) or /125 (IPv6) = 8 addresses
/30 (IPv4) or /126 (IPv6) = 4 addresses
/31 (IPv4) or /127 (IPv6) = 2 addresses
''')
param publicIPPrefixesPrefixLength int = 31

@description('The public IP address version.')
@allowed([
  'IPv4'
  'IPv6'
])
param publicIPAddressVersion string = 'IPv4'

@description('''
A list of tags associated with the public IP prefix.
Example:
[
  ipTagType: 'RoutingPreference'
  tag: 'Internet'
]
''')
param publicIPPrefixesIpTags array = []

@description('''
A list of availability zones denoting the IP allocated for the resource needs to come from.
Example:
[
  1
  2
  3
]
''')
@maxLength(3)
param publicIPPrefixesZones array = []

resource publicIPPrefixes 'Microsoft.Network/publicIPPrefixes@2023-02-01' = {
  name: publicIPPrefixesName
  location: location
  tags: tags
  sku: publicIPPrefixesSku
  properties: {
    prefixLength: publicIPPrefixesPrefixLength
    publicIPAddressVersion: publicIPAddressVersion
    ipTags: publicIPPrefixesIpTags
  }
  zones: !empty(publicIPPrefixesZones) ? publicIPPrefixesZones : null
}

@description('The resource id of the upserted publicIPPrefix')
output publicIPPrefixesResourceId string = publicIPPrefixes.id
@description('The resource name of the upserted publicIPPrefix.')
output publicIPPrefixesName string = publicIPPrefixes.name
