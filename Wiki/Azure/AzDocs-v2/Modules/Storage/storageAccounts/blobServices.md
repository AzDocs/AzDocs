# blobServices

Target Scope: resourceGroup

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| blobContainerName | string | <input type="checkbox" checked> | Length between 3-63 | <pre></pre> | The name of the blob container to create. |
| storageAccountName | string | <input type="checkbox" checked> | Length between 3-24 | <pre></pre> | The name of the storage account to create the blob container in. This should be pre-existing. |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| blobContainerName | string | Output the storage account container name. |

