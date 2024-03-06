# backendAddressPools

Target Scope: resourceGroup

## Synopsis
Configuring Backend address pool for Load balancer

## Description
Configuring Backend address pool for Load balancer with the given specs.<br>
This module currently supports only configuring backend pool based on the IP Address.<br>
All other references/properties should be set throught the main Load Balancer module.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| lbBackendAddressPoolName | string | <input type="checkbox" checked> | Length between 2-32 | <pre></pre> | The name of the backend address pool. |
| vNetID | string | <input type="checkbox" checked> | None | <pre></pre> | A reference to a virtual network. |
| nicIpAddresses | array | <input type="checkbox" checked> | None | <pre></pre> | An array of the private IPs that need to be added to the backend pool.<br>Example:<br>&nbsp;&nbsp;&nbsp;'192.168.10.10'<br>&nbsp;&nbsp;&nbsp;'192.168.10.11' |
| loadBalancerName | string | <input type="checkbox" checked> | None | <pre></pre> | A reference to a load balancer where the backend pool will be configured. |

## Examples
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

## Links
- [Bicep Microsoft.Network backendAddressPools](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/loadbalancers/backendaddresspools?pivots=deployment-language-bicep)
