# blobServices

Target Scope: resourceGroup

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| blobContainerName | string | <input type="checkbox" checked> | Length between 3-63 | <pre></pre> | The name of the blob container to create. |
| storageAccountName | string | <input type="checkbox" checked> | Length between 3-24 | <pre></pre> | The name of the storage account to create the blob container in. This should be pre-existing. |
| restorePolicy | object | <input type="checkbox"> | None | <pre>{<br>  days: 30<br>  enabled: true<br>}</pre> | The restore policy for the blob container. |
| changeFeed | object | <input type="checkbox"> | None | <pre>{<br>  enabled: true<br>  retentionInDays: 30<br>}</pre> | The change feed policy for the blobservices. |
| isVersioningEnabled | bool | <input type="checkbox"> | None | <pre>true</pre> | Whether or not to enable versioning on the blobservices. |
| deleteRetentionPolicy | object | <input type="checkbox"> | None | <pre>{   allowPermanentDelete: false   days: 31   enabled: true }</pre> |  |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| blobContainerName | string | Output the storage account container name. |

