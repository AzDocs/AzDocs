@description('The resource name for this Public IP address.')
@minLength(1)
@maxLength(80)
param publicIPAddressName string

@description('Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location.')
param location string = resourceGroup().location

@description('The SKU name to use for this public IP address. For the object/array structure, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.network/publicipaddresses?tabs=bicep#publicipaddresssku.')
param sku object = {
  name: 'Standard'
}

@description('The public IP address allocation method. Options are `Static` or `Dynamic`.')
@allowed([
  'Static'
  'Dynamic'
])
param publicIPAllocationMethod string = 'Static'

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

@description('The zones to use for this public ipaddress.')
@allowed([
  '1'
  '2'
  '3'
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

@description('Upsert the public ip with the given parameters.')
resource publicIP 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: publicIPAddressName
  location: location
  sku: sku
  tags: tags
  properties: {
    publicIPAddressVersion: publicIPAddressVersion
    publicIPAllocationMethod: publicIPAllocationMethod
    idleTimeoutInMinutes: publicIPIdleTimeoutInMinutes
  }
  zones: !empty(availabilityZones) ? availabilityZones : null
}

@description('Output the resource name of the public ip address.')
output publicIpName string = publicIP.name

@description('Output the resource name of the public ip address.')
output publicIpResourceId string = publicIP.id
