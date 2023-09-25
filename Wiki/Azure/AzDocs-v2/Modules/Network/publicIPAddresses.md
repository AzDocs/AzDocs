# publicIPAddresses

Target Scope: resourceGroup

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| publicIPAddressName | string | <input type="checkbox" checked> | Length between 1-80 | <pre></pre> | The resource name for this Public IP address. |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location. |
| sku | object | <input type="checkbox"> | None | <pre>{<br>  name: 'Standard'<br>}</pre> | The SKU name to use for this public IP address. For the object/array structure, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.network/publicipaddresses?tabs=bicep#publicipaddresssku. |
| publicIPAllocationMethod | string | <input type="checkbox"> | `'Static'` or `'Dynamic'` | <pre>'Static'</pre> | The public IP address allocation method. Options are `Static` or `Dynamic`. |
| publicIPAddressVersion | string | <input type="checkbox"> | `'IPv4'` or `'IPv6'` | <pre>'IPv4'</pre> | The version of the IP Address. can be IPv4 or IPv6. |
| publicIPIdleTimeoutInMinutes | int | <input type="checkbox"> | Value between 4-30 | <pre>4</pre> | Keep a TCP or HTTP connection open without relying on clients to send keep-alive messages for this amount of minutes. Range is 4-30. |
| availabilityZones | array | <input type="checkbox"> | `'1'` or `'2'` or `'3'` | <pre>[]</pre> | The zones to use for this public ipaddress. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| publicIpName | string | Output the resource name of the public ip address. |
| publicIpResourceId | string | Output the resource name of the public ip address. |

