# managedVirtualNetworks

Target Scope: resourceGroup

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| dataFactoryName | string | <input type="checkbox" checked> | Length between 3-63 | <pre></pre> | The resource name of the Data Factory you are targeting. This resource has to be pre-existing. |
| dataFactoryManagedVirtualNetworkName | string | <input type="checkbox" checked> | Length between 2-64 | <pre></pre> | The resource name of the managed virtual network to be upserted. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| dataFactoryManagedVirtualNetworkName | string | Output the resourcename for the upserted managed virtual network. |
