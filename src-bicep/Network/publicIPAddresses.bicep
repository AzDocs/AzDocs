/*
.SYNOPSIS
Creating a Public IP Address.
.DESCRIPTION
Creating a Public IP Address with the given specs.
.EXAMPLE
<pre>
module publicIP 'br:contosoregistry.azurecr.io/network/publicIPAddresses:latest' = {
  name: '${deployment().name}-publicip'
  params: {
    publicIPAddressName: publicIPName
    location: location
    publicIPAllocationMethod: 'Static'
    sku: {
      name: 'Standard'
      tier: 'Regional'
    }
  }
}
</pre>
<p>Creates a Public IP Address with static allocation method.</p>
.LINKS
- [Bicep Microsoft.Network publicIPAddresses](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/publicipaddresses?pivots=deployment-language-bicep)
- [Public IP addresses](https://learn.microsoft.com/en-us/azure/virtual-network/ip-services/public-ip-addresses)
*/
@description('The resource name for this Public IP address.')
@minLength(1)
@maxLength(80)
param publicIPAddressName string

@description('Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location.')
param location string = resourceGroup().location

@description('The SKU name to use for this public IP address.')
param sku resourceInput<'Microsoft.Network/publicIPAddresses@2025-01-01'>.sku = {
  name: 'Standard'
  tier: 'Regional'
}

@description('The public IP address allocation method. Options are `Static` or `Dynamic`.')
@allowed([
  'Static'
  'Dynamic'
])
param publicIPAllocationMethod string = 'Static'

@description('Optional. Resource ID of the Public IP Prefix object. This is only needed if you want your Public IPs created in a PIP Prefix.')
param publicIpPrefixResourceId string?

@description('The version of the IP Address. can be IPv4 or IPv6.')
@allowed([
  'IPv4'
  'IPv6'
])
param publicIPAddressVersion string = 'IPv4'

@description('Keep a TCP or HTTP connection open without relying on clients to send keep-alive messages for this amount of minutes. Range is 4-30.')
@minValue(4)
@maxValue(30)
param publicIPIdleTimeoutInMinutes int = 4

@description('A list of availability zones denoting the IP allocated for the resource needs to come from.')
@allowed([
  []
  [1]
  [2]
  [3]
  [1, 2]
  [1, 3]
  [2, 3]
  [1, 2, 3]
])
param availabilityZones array = []

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
The domain name label. The concatenation of the domain name label and the regionalized DNS zone make up the fully qualified domain name associated with the public IP address. 
If a domain name label is specified, an A DNS record is created for the public IP in the Microsoft Azure DNS system.
''')
param domainNameLabel string = ''

@description('Upsert the public ip with the given parameters.')
resource publicIP 'Microsoft.Network/publicIPAddresses@2025-01-01' = {
  name: publicIPAddressName
  location: location
  sku: sku
  tags: tags
  properties: {
    publicIPAddressVersion: publicIPAddressVersion
    publicIPAllocationMethod: publicIPAllocationMethod
    publicIPPrefix: !empty(publicIpPrefixResourceId)
      ? {
          id: publicIpPrefixResourceId
        }
      : null
    idleTimeoutInMinutes: publicIPIdleTimeoutInMinutes
    dnsSettings: empty(domainNameLabel)
      ? null
      : {
          domainNameLabel: domainNameLabel
        }
  }
  zones: !empty(availabilityZones) ? availabilityZones : null
}

@description('Output the resource name of the public ip address.')
output publicIpName string = publicIP.name

@description('Output the resource name of the public ip address.')
output publicIpResourceId string = publicIP.id
