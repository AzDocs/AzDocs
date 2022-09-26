# privateDnsZones

Target Scope: resourceGroup

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| privateDnsZoneName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the private DNS zone the private endpoint can be looked up. |
| registrationEnabled | bool | <input type="checkbox"> | None | <pre>true</pre> | Auto register your eligible private endpoints within this DNS zone. |
| virtualNetworkResourceId | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the virtual network you want to create the private endpoint in. Should be pre-existing. |
| privateDnsLinkName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the Virtual Network Link in the DNS Zone. |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| privateDnsZoneResourceId | string | The Resource ID of the upserted Private DNS Zone. |

