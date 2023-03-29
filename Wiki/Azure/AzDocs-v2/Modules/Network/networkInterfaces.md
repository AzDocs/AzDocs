# networkInterfaces

Target Scope: resourceGroup

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location. |
| networkInterfaceName | string | <input type="checkbox" checked> | Length between 0-80 | <pre></pre> | The name of the NIC for this VM. Defaults to nic-<vmBaseName>-<environmentType>. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| subnetResourceId | string | <input type="checkbox"> | None | <pre>''</pre> | Specifies the resource id of the subnet where this NIC should be onboarded into. |
| privateIPAllocationMethod | string | <input type="checkbox"> | `'Dynamic'` or `'Static'` | <pre>'Dynamic'</pre> | The private IP address allocation method. |
| ipConfigurations | array | <input type="checkbox"> | None | <pre>[]</pre> | This allows you to override the default IP configurations. If you leave this empty, the NIC will be created with 1 IP configuration. If you fill this, you need to specify the properties.ipConfigurations yourself. |
| enableAcceleratedNetworking | bool | <input type="checkbox"> | None | <pre>false</pre> | Enable Accelerated Networking for this interface. Defaults to `false`. |
| loadBalancerBackendAddressPoolResourceIds | array | <input type="checkbox"> | None | <pre>[]</pre> | A list of resource id\'s referencing to the backend address pools of the loadbalancer.<br>NOTE: If you use the `ipConfigurations` parameter, this value will be omited and you need to define this using the `ipConfigurations` object structure.<br>Example:<br>[<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;id: '/resource/id/to/my/backEndAddressPool'<br>&nbsp;&nbsp;&nbsp;}<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;id: '/resource/id/to/my/backEndAddressPool'<br>&nbsp;&nbsp;&nbsp;}<br>] |
| loadBalancerInboundNatRuleResourceIds | array | <input type="checkbox"> | None | <pre>[]</pre> | A list of resource id\'s referencing to the inbound nat rules of the loadbalancer.<br>NOTE: If you use the `ipConfigurations` parameter, this value will be omited and you need to define this using the `ipConfigurations` object structure.<br>Example:<br>[<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;id: '/resource/id/to/my/natRule'<br>&nbsp;&nbsp;&nbsp;}<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;id: '/resource/id/to/my/natRule2'<br>&nbsp;&nbsp;&nbsp;}<br>] |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| networkInterfaceName | string | Outputs the network interface resource name. |
| networkInterfaceResourceId | string | Outputs the network interface resource id. |

