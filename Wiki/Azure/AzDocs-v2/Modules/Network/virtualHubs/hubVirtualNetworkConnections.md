# hubVirtualNetworkConnections

Target Scope: resourceGroup

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| virtualHubName | string | <input type="checkbox" checked> | Length between 1-80 | <pre></pre> | The name of the VirtualHub |
| targetSubscriptionId | string | <input type="checkbox" checked> | Length is 36 | <pre></pre> | The ID of the subscription where the target (to be attached) VNet is located |
| targetResourceGroupName | string | <input type="checkbox" checked> | Length between 1-90 | <pre></pre> | The name of the resourcegroup where the target (to be attached) VNet is located |
| targetVNetName | string | <input type="checkbox" checked> | Length between 2-64 | <pre></pre> | The name of the target (to be attached) VNet |
| virtualHubRouteResourceId | string | <input type="checkbox"> | None | <pre>'/subscriptions/${az.subscription().subscriptionId}/resourceGroups/${az.resourceGroup().name}/providers/Microsoft.Network/virtualHubs/${virtualHubName}/hubRouteTables/defaultRouteTable'</pre> | The VirtualHub routetable resourceId. Defaults to the `defaultRouteTable` table. |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |

