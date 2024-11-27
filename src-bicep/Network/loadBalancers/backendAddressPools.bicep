/*
.SYNOPSIS
Configuring Backend address pool for Load balancer
.DESCRIPTION
Configuring Backend address pool for Load balancer with the given specs.
This module currently supports only configuring backend pool based on the IP Address.
All other references/properties should be set throught the main Load Balancer module.
.EXAMPLE
<pre>
module lbBackendAddressPool 'br:contosoregistry.azurecr.io/network/loadbalancers/backendaddresspools:latest' = {
  name: '${take(deployment().name, 58)}-pools'
  params: {
    loadBalancerName: loadBalancerName
    lbBackendAddressPoolName: lbBackendAddressPoolName
    nicIpAddresses: [
      '192.168.0.10'
      '192.168.0.11'
    ]
    vNetID: vnet.id
  }
  dependsOn: [
    loadBalancer
    networkInterfaces
  ]
}
</pre>
<p>Configures backend pool with the provided name</p>
.LINKS
- [Bicep Microsoft.Network backendAddressPools](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/loadbalancers/backendaddresspools?pivots=deployment-language-bicep)
*/

// ================================================= Parameters =================================================
@description('The name of the backend address pool.')
@minLength(2)
@maxLength(32)
param lbBackendAddressPoolName string

@description('A reference to a virtual network.')
param vNetID string

@description('''
An array of the private IPs that need to be added to the backend pool.
Example:
  '192.168.10.10'
  '192.168.10.11'
''')
param nicIpAddresses array

@description('A reference to a load balancer where the backend pool will be configured.')
param loadBalancerName string

@description('Fetch the existing Load Balancer.')
resource loadBalancer 'Microsoft.Network/loadBalancers@2022-01-01' existing = {
  name: loadBalancerName
}

resource lbBackendAddressPool 'Microsoft.Network/loadBalancers/backendAddressPools@2022-11-01' = {
  parent: loadBalancer
  name: lbBackendAddressPoolName
  properties: {
    loadBalancerBackendAddresses: [
      for (ip, j) in nicIpAddresses: {
        name: 'address${j}'
        properties: {
          virtualNetwork: {
            id: vNetID
          }
          ipAddress: ip
        }
      }
    ]
  }
}
