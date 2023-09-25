/*
.SYNOPSIS
Bicep module to deploy an IP Group.
.DESCRIPTION
Bicep module to deploy an IP Group.
.EXAMPLE
<pre>
module ipGroupGripDev 'br:contosoregistry.azurecr.io/network/ipgroups:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 56), 'ipgroup')
  params: {
    location: location
    ipGroupName: 'dev-frontend-ip-group'
    ipGroupIpAddresses: [ '10.100.198.32/27' ]
  }
}
</pre>
<p>Creates an IpGroup with the name dev-frontend-ip-group.</p>
.LINKS
- [Bicep Microsoft.Network ipgroups](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/ipgroups?pivots=deployment-language-bicep)
*/

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

@description('Specifies the name of the IP group.')
param ipGroupName string

@description('Specifies the IP addresses to include in the IP group.')
param ipGroupIpAddresses array = []

resource ipGroup 'Microsoft.Network/ipGroups@2023-04-01' = {
  name: ipGroupName
  location: location
  tags: tags
  properties: {
    ipAddresses: ipGroupIpAddresses
  }
}

@description('The name of the IP group.')
output ipGroupName string = ipGroup.name
@description('The resource ID of the IP group.')
output ipGroupResourceId string = ipGroup.id
