// ================================================= Parameters =================================================
@description('Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location.')
param location string = resourceGroup().location

@description('The name of the NIC for this VM. Defaults to nic-<vmBaseName>-<environmentType>.')
@maxLength(80)
param networkInterfaceName string

@description('''
The tags to apply to this resource. This is an object with key/value pairs.
Example:
{
  FirstTag: myvalue
  SecondTag: another value
}
''')
param tags object = {}

@description('Specifies the resource id of the subnet where this NIC should be onboarded into.')
param subnetResourceId string = ''

@description('The private IP address allocation method.')
@allowed([
  'Dynamic'
  'Static'
])
param privateIPAllocationMethod string = 'Dynamic'

@description('This allows you to override the default IP configurations. If you leave this empty, the NIC will be created with 1 IP configuration. If you fill this, you need to specify the properties.ipConfigurations yourself.')
param ipConfigurations array = []

@description('Enable Accelerated Networking for this interface. Defaults to `false`.')
param enableAcceleratedNetworking bool = false

@description('''
A list of resource id\'s referencing to the backend address pools of the loadbalancer.
NOTE: If you use the `ipConfigurations` parameter, this value will be omited and you need to define this using the `ipConfigurations` object structure.
Example:
[
  {
    id: '/resource/id/to/my/backEndAddressPool'
  }
  {
    id: '/resource/id/to/my/backEndAddressPool'
  }
]
''')
param loadBalancerBackendAddressPoolResourceIds array = []
@description('''
A list of resource id\'s referencing to the inbound nat rules of the loadbalancer.
NOTE: If you use the `ipConfigurations` parameter, this value will be omited and you need to define this using the `ipConfigurations` object structure.
Example:
[
  {
    id: '/resource/id/to/my/natRule'
  }
  {
    id: '/resource/id/to/my/natRule2'
  }
]
''')
param loadBalancerInboundNatRuleResourceIds array = []

// ================================================= Resources =================================================
@description('Upsert the NIC using the given parameters.')
resource networkInterface 'Microsoft.Network/networkInterfaces@2022-01-01' = {
  name: networkInterfaceName
  location: location
  tags: tags
  properties: {
    enableAcceleratedNetworking: enableAcceleratedNetworking
    ipConfigurations: length(ipConfigurations) <= 0
      ? [
          {
            name: networkInterfaceName
            properties: {
              privateIPAllocationMethod: privateIPAllocationMethod
              subnet: {
                id: subnetResourceId
              }
              loadBalancerBackendAddressPools: loadBalancerBackendAddressPoolResourceIds
              loadBalancerInboundNatRules: loadBalancerInboundNatRuleResourceIds
            }
          }
        ]
      : ipConfigurations
  }
}

@description('Outputs the network interface resource name.')
output networkInterfaceName string = networkInterface.name
@description('Outputs the network interface resource id.')
output networkInterfaceResourceId string = networkInterface.id
