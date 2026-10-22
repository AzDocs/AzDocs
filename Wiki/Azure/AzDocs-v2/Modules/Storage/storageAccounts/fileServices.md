# fileServices

Target Scope: resourceGroup

## Synopsis
Configuring file services on an existing storage account.

## Description
Configures the file service (Microsoft.Storage/storageAccounts/fileServices) on an existing<br>
storage account. Supports NFS protocol settings such as encryption-in-transit configuration.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| storageAccountName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the existing storage account to configure file services on. |
| fileServiceName | string | <input type="checkbox"> | None | <pre>'default'</pre> | The name of the file service. Only \'default\' is supported by Azure. |
| nfsEncryptionInTransitRequired | bool | <input type="checkbox"> | None | <pre>true</pre> | If true, NFS connections require encryption in transit (channel encryption).<br>Set to false when using NFS with private endpoints, where network-layer security is provided<br>by the private endpoint and in-transit encryption at the protocol level is not required.<br>Defaults to true. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| fileServiceId | string | The resource ID of the file service. |
| fileServiceName | string | The name of the file service. |

## Examples
<pre>
module fileServices 'br:contosoregistry.azurecr.io/storage/storageaccounts/fileservices:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 55), 'fs')
  params: {
    storageAccountName: storageAccountName
    nfsEncryptionInTransitRequired: false
  }
}
</pre>
<p>Configures file services with NFS encryption in transit disabled, for use with private endpoints.</p>

## Links
- [Bicep Storage File Services](https://learn.microsoft.com/en-us/azure/templates/microsoft.storage/storageaccounts/fileservices?pivots=deployment-language-bicep)
