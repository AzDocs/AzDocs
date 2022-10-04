# privateEndpoints

Target Scope: resourceGroup

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the key vault should be created. |
| targetResourceId | string | <input type="checkbox" checked> | None | <pre></pre> | The target resource id where this private endpoint is created for. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| privateEndpointName | string | <input type="checkbox" checked> | None | <pre></pre> | The name for the private endpoint for the automation account |
| virtualNetworkName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the virtual network you want to create the private endpoint in. Should be pre-existing. |
| subnetName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the subnet in the virtual network you want to create the private endpoint in. Should be pre-existing. |
| virtualNetworkResourceId | string | <input type="checkbox"> | None | <pre>'${subscription().id}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Network/virtualNetworks/${virtualNetworkName}'</pre> | String containing the resource id of the subnet you want to create the private endpoint in.<br>Example:<br>'${subscription().id}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Network/virtualNetworks/${virtualNetworkName}/subnets/${subnetName}' |
| privateDnsZoneName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the private DNS zone the private endpoint can be looked up. |
| privateDnsLinkName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the Virtual Network Link in the DNS Zone. |
| privateDnsZoneResourceGroupName | string | <input type="checkbox"> | None | <pre>az.resourceGroup().name</pre> | The name of the resourcegroup where the private DNS zone for the private endpoint resides or will reside in. |
| privateEndpointGroupId | string | <input type="checkbox" checked> | None | <pre></pre> | The group ID to apply to this private endpoint. |
| privateLinkServiceConnectionName | string | <input type="checkbox"> | None | <pre>'${privateEndpointName}-${privateEndpointGroupId}-${virtualNetworkName}-${subnetName}'</pre> | Optional parameter to change the default connection name. |
| registrationEnabled | bool | <input type="checkbox"> | None | <pre>true</pre> | Auto register your eligible private endpoints within this DNS zone. |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |

