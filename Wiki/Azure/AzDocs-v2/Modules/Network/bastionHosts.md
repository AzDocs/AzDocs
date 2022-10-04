# bastionHosts

Target Scope: resourceGroup

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location. |
| bastionHostName | string | <input type="checkbox" checked> | Length between 1-80 | <pre></pre> | Specifies the name of the Azure Bastion resource. |
| bastionHostDisableCopyPaste | bool | <input type="checkbox"> | None | <pre>false</pre> | Enable/Disable Copy/Paste feature of the Bastion Host resource. |
| bastionHostEnableFileCopy | bool | <input type="checkbox"> | None | <pre>false</pre> | Enable/Disable File Copy (between Host & Client) feature of the Bastion Host resource. |
| bastionHostEnableIpConnect | bool | <input type="checkbox"> | None | <pre>false</pre> | Enable/Disable IP Connect feature of the Bastion Host resource. This will allow you to connect to VM\'s (either azure or non-azure) using the VM\'s private IP address through Bastion. |
| bastionHostEnableShareableLink | bool | <input type="checkbox"> | None | <pre>false</pre> | Enable/Disable Shareable Link of the Bastion Host resource. |
| bastionHostEnableTunneling | bool | <input type="checkbox"> | None | <pre>false</pre> | Enable/Disable Tunneling feature of the Bastion Host resource.<br>SSH tunneling is a method of transporting arbitrary networking data over an encrypted SSH connection. It can be used to add encryption to legacy applications. It can also be used to implement VPNs (Virtual Private Networks) and access intranet services across firewalls. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| bastionSubnetName | string | <input type="checkbox"> | Length between 1-80 | <pre>'AzureBastionSubnet'</pre> | Name of the Azure Bastion subnet. This is probably going to have to be `AzureBastionSubnet` due to Azure restrictions. |
| bastionPublicIpAddressName | string | <input type="checkbox"> | Length between 1-80 | <pre>'pip-${bastionHostName}'</pre> | The resource name of the Public IP for this Azure Bastion host. |
| vnetName | string | <input type="checkbox"> | Length between 2-64 | <pre>''</pre> | The VNet name to onboard this Azure Bastion Host into. |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| neededNsgRulesForBastionSubnet | array | The default needed NSG rules which you need to apply to your Azure Bastion Subnet. |

