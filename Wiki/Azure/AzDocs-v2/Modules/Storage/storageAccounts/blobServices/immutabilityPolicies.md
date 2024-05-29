# immutabilityPolicies

Target Scope: resourceGroup

## Synopsis
Adding a immutability policy to a blob container in a storage account.

## Description
Adding a immutability policy to a blob container in a storage account.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| blobContainerName | string | <input type="checkbox" checked> | Length between 3-63 | <pre></pre> | The name of the blob container to create the policy for. This should be pre-existing. |
| storageAccountName | string | <input type="checkbox" checked> | Length between 3-24 | <pre></pre> | The name of the storage account. This should be pre-existing. |
| immutabilityPolicyName | string | <input type="checkbox"> | None | <pre>'default'</pre> | The name of the immutability policy. |
| allowProtectedAppendWrites | bool | <input type="checkbox"> | None | <pre>false</pre> | When enabled, new blocks can be written to an append blob while maintaining immutability protection and compliance. Only new blocks can be added and any existing blocks cannot be modified or deleted. This property cannot be changed with ExtendImmutabilityPolicy API. The \'allowProtectedAppendWrites\' and \'allowProtectedAppendWritesAll\' properties are mutually exclusive. |
| allowProtectedAppendWritesAll | bool | <input type="checkbox"> | None | <pre>true</pre> | When enabled, new blocks can be written to both \'Append and Bock Blobs\' while maintaining immutability protection and compliance. Only new blocks can be added and any existing blocks cannot be modified or deleted. This property cannot be changed with ExtendImmutabilityPolicy API. The \'allowProtectedAppendWrites\' and \'allowProtectedAppendWritesAll\' properties are mutually exclusive. |
| immutabilityPeriodSinceCreationInDays | int | <input type="checkbox"> | None | <pre>180</pre> | Immutability period since creation in days. |

## Examples
<pre>
module policy 'br:contosoregistry.azurecr.io/storage/storageaccounts/blobservices/immutabilitypolicies:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 58), 'impol')
  params: {
    storageAccountName: storageAccountName
    blobContainerName: 'blobcontainername'
    allowProtectedAppendWrites: true
    allowProtectedAppendWritesAll: true
    immutabilityPeriodSinceCreationInDays: 180
  }
}
</pre>
<p>Creates an immutabhility policy for an existing blob container with the name blobcontainername in an existing storage account with the name storageAccountName.</p>

## Links
- [Bicep Storage Blob Container Immutability Policy](https://learn.microsoft.com/en-us/azure/templates/microsoft.storage/storageaccounts/blobservices/containers/immutabilitypolicies?pivots=deployment-language-bicep)
