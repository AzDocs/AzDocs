# publicIPPrefixes

Target Scope: resourceGroup

## Synopsis
Creating a public ip prefix resource.

## Description
Creating public ip prefixes. A public IP address prefix is a contiguous range of standard SKU public IP addresses.<br>
When you create a public IP address resource, you can assign a static public IP address from the prefix and associate the address to virtual machines, load balancers, or other resources.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| publicIPPrefixesSku | object | <input type="checkbox"> | None | <pre>{<br>  name: 'Standard'<br>  tier: 'Regional'<br>}</pre> | The public IP prefix SKU. Tier can be Global or Regional |
| publicIPPrefixesName | string | <input type="checkbox" checked> | Length between 1-80 | <pre></pre> | The name for the public ip prefixes resource. |
| publicIPPrefixesPrefixLength | int | <input type="checkbox"> | None | <pre>31</pre> | How many Public IPs you want to be available. A value of 28 for IPv4 means 16 addresses. A value of 124 for IPv6 means 16 addresses.<br>The following public IP prefix sizes are currently available:<br>/28 (IPv4) or /124 (IPv6) = 16 addresses<br>/29 (IPv4) or /125 (IPv6) = 8 addresses<br>/30 (IPv4) or /126 (IPv6) = 4 addresses<br>/31 (IPv4) or /127 (IPv6) = 2 addresses |
| publicIPAddressVersion | string | <input type="checkbox"> | `'IPv4'` or `'IPv6'` | <pre>'IPv4'</pre> | The public IP address version. |
| publicIPPrefixesIpTags | array | <input type="checkbox"> | None | <pre>[]</pre> | A list of tags associated with the public IP prefix.<br>Example:<br>[<br>&nbsp;&nbsp;&nbsp;ipTagType: 'RoutingPreference'<br>&nbsp;&nbsp;&nbsp;tag: 'Internet'<br>] |
| publicIPPrefixesZones | array | <input type="checkbox"> | Length between 0-3 | <pre>[]</pre> | A list of availability zones denoting the IP allocated for the resource needs to come from.<br>Example:<br>[<br>&nbsp;&nbsp;&nbsp;1<br>&nbsp;&nbsp;&nbsp;2<br>&nbsp;&nbsp;&nbsp;3<br>] |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| publicIPPrefixesResourceId | string | The resource id of the upserted publicIPPrefix |
| publicIPPrefixesName | string | The resource name of the upserted publicIPPrefix. |

## Examples
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

## Links
- [Bicep Microsoft.Network public ip prefixes](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/publicipprefixes?pivots=deployment-language-bicep)
