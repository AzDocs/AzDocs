// ================================================= Parameters =================================================
@description('''
The object structure which defines the NIC\'s you want to create.
For parameter information, see networkInterfaces.bicep.
Object structure:
[
  {
    networkInterfaceName: 'nic-<nicNumber>-${virtualMachine.name}'
    enableAcceleratedNetworking: true
    loadBalancerBackendAddressPoolResourceIds: [
      {
        id: '/resource/id/to/my/backEndAddressPool'
      }
      {
        id: '/resource/id/to/my/backEndAddressPool'
      }
    ]
    loadBalancerInboundNatRuleResourceIds: [
      {
        id: '/resource/id/to/my/natRule'
      }
      {
        id: '/resource/id/to/my/natRule2'
      }
    ]
    location: location
    ipConfiguration: [
      {
        name: networkInterfaceName
        properties: {
          privateIPAllocationMethod: privateIPAllocationMethod
          subnet: {
            id: subnetResourceId
          }
          loadBalancerBackendAddressPools: empty(loadBalancerName) ? [] : [
            {
              id: loadBalancer.properties.backendAddressPools[0].id
            }
          ]
          loadBalancerInboundNatRules: empty(loadBalancerName) ? [] : [
            {
              id: loadBalancer.properties.inboundNatRules[0].id
            }
          ]
        }
      }
    ]
    privateIPAllocationMethod: 'Static'
    subnetResourceId: '/resource/id/to/my/subnet'
    tags: tags
  }
]
''')
param networkInterfaceInformation array = []

module networkInterfaces 'networkInterfaces.bicep' = [for i in range(0, length(networkInterfaceInformation)): {
  name: format('{0}-{1}', take('${deployment().name}', 53), '${i}-multiNic')
  params: {
    networkInterfaceName: replace(networkInterfaceInformation[i].networkInterfaceName, '<nicNumber>', '${i}')
    enableAcceleratedNetworking: contains(networkInterfaceInformation[i], 'enableAcceleratedNetworking') ? networkInterfaceInformation[i].enableAcceleratedNetworking : false
    loadBalancerBackendAddressPoolResourceIds: contains(networkInterfaceInformation[i], 'loadBalancerBackendAddressPoolResourceIds') ? networkInterfaceInformation[i].loadBalancerBackendAddressPoolResourceIds : []
    loadBalancerInboundNatRuleResourceIds: contains(networkInterfaceInformation[i], 'loadBalancerInboundNatRuleResourceIds') ? networkInterfaceInformation[i].loadBalancerInboundNatRuleResourceIds : []
    location: contains(networkInterfaceInformation[i], 'location') ? networkInterfaceInformation[i].location : 'westeurope'
    ipConfigurations: contains(networkInterfaceInformation[i], 'ipConfigurations') ? networkInterfaceInformation[i].ipConfigurations : []
    privateIPAllocationMethod: contains(networkInterfaceInformation[i], 'privateIPAllocationMethod') ? networkInterfaceInformation[i].privateIPAllocationMethod : ''
    subnetResourceId: contains(networkInterfaceInformation[i], 'subnetResourceId') ? networkInterfaceInformation[i].subnetResourceId : ''
    tags: contains(networkInterfaceInformation[i], 'tags') ? networkInterfaceInformation[i].tags : {}
  }
}]

@description('Outputs the network interface resource id.')
output networkInterfaceResourceIds array = [for i in range(0, length(networkInterfaceInformation)): {
  name: networkInterfaces[i].outputs.networkInterfaceName
  resourceId: networkInterfaces[i].outputs.networkInterfaceResourceId
}]
