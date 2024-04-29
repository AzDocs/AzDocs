# managedPrivateEndpoints

Target Scope: resourceGroup

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| dataFactoryName | string | <input type="checkbox" checked> | Length between 3-63 | <pre></pre> | The resource name of the Data Factory you are targeting. This resource has to be pre-existing. |
| targetResourceId | string | <input type="checkbox" checked> | None | <pre></pre> | The resource id of the resource you want to put this private endpoint in front of. |
| groupId | string | <input type="checkbox" checked> | None | <pre></pre> | The groupId to which the managed private endpoint is created. You can use Azure CLI with the command "az network private-link-resource list" to obtain the supported group ids. |
| managedPrivateEndpointName | string | <input type="checkbox" checked> | Length between 2-64 | <pre></pre> | The resource name of the managed private endpoint to create. |
| managedVirtualNetworkName | string | <input type="checkbox" checked> | Length between 2-64 | <pre></pre> | The resource name of the managed virtual network to use while creating the managed private endpoint. |
| managedPrivateEndpointFqdnsToAttach | array | <input type="checkbox"> | None | <pre>[]</pre> | Fully qualified domain names to attach to this private endpoint. You should fix the DNS yourself. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| managedPrivateEndpointResourceName | string | Output the resource name for the upserted managed private endpoint. |
| managedPrivateEndpointResourceId | string | Output the resource id for the upserted managed private endpoint. |
