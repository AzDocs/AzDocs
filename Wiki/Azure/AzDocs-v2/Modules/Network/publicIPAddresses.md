# publicIPAddresses

Target Scope: resourceGroup

## Synopsis
Creating a Public IP Address.

## Description
Creating a Public IP Address with the given specs.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| publicIPAddressName | string | <input type="checkbox" checked> | Length between 1-80 | <pre></pre> | The resource name for this Public IP address. |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location. |
| sku | resourceInput<'Microsoft.Network/publicIPAddresses@2025-01-01'>.sku | <input type="checkbox"> | None | <pre>{<br>  name: 'Standard'<br>  tier: 'Regional'<br>}</pre> | The SKU name to use for this public IP address. |
| publicIPAllocationMethod | string | <input type="checkbox"> | `'Static'` or `'Dynamic'` | <pre>'Static'</pre> | The public IP address allocation method. Options are `Static` or `Dynamic`. |
| publicIpPrefixResourceId | string? | <input type="checkbox" checked> | None | <pre></pre> | Optional. Resource ID of the Public IP Prefix object. This is only needed if you want your Public IPs created in a PIP Prefix. |
| publicIPAddressVersion | string | <input type="checkbox"> | `'IPv4'` or `'IPv6'` | <pre>'IPv4'</pre> | The version of the IP Address. can be IPv4 or IPv6. |
| publicIPIdleTimeoutInMinutes | int | <input type="checkbox"> | Value between 4-30 | <pre>4</pre> | Keep a TCP or HTTP connection open without relying on clients to send keep-alive messages for this amount of minutes. Range is 4-30. |
| availabilityZones | array | <input type="checkbox"> | `[]` or `[1]` or `[2]` or `[3]` or `[1, 2]` or `[1, 3]` or `[2, 3]` or `[1, 2, 3]` | <pre>[]</pre> | A list of availability zones denoting the IP allocated for the resource needs to come from. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| domainNameLabel | string | <input type="checkbox"> | None | <pre>''</pre> | The domain name label. The concatenation of the domain name label and the regionalized DNS zone make up the fully qualified domain name associated with the public IP address. <br>If a domain name label is specified, an A DNS record is created for the public IP in the Microsoft Azure DNS system. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| publicIpName | string | Output the resource name of the public ip address. |
| publicIpResourceId | string | Output the resource name of the public ip address. |

## Examples
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

## Links
- [Bicep Microsoft.Network publicIPAddresses](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/publicipaddresses?pivots=deployment-language-bicep)<br>
- [Public IP addresses](https://learn.microsoft.com/en-us/azure/virtual-network/ip-services/public-ip-addresses)
