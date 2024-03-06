# blobServices

Target Scope: resourceGroup

## Synopsis
Creating a blob container in a storage account.

## Description
Creating a blob container in a storage account.

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

## Examples
<pre>
module storageaccount 'br:contosoregistry.azurecr.io/storage/storageaccounts/blobservices:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 59), 'blob')
  params: {
    storageAccountName: storageAccountName
    blobContainerName: 'blobcontainername'
  }
}
</pre>
<p>Creates a blob container with the name blobcontainername in an existing storage account.</p>

## Links
- [Bicep Storage Blob Container](https://learn.microsoft.com/en-us/azure/templates/microsoft.storage/storageaccounts/blobservices/containers?pivots=deployment-language-bicep)
