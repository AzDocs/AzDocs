# storages

Target Scope: resourceGroup

## User Defined Types
| Name | Type | Discriminator | Description
| -- |  -- | -- | -- |
| <a id="AccountKeyVaultProperties">AccountKeyVaultProperties</a>  | <pre>{</pre> |  | Properties to reference a Key Vault secret for the storage account key | 

## Synopsis
Creating a storages resources

## Description
A storages resources can be used for volumes for a container app.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| managedEnvironmentName | string | <input type="checkbox" checked> | None | <pre></pre> | The name for the managed Environment for the Container App. |
| storagesName | string | <input type="checkbox" checked> | None | <pre></pre> | The name for the storages resource |
| storageType | string | <input type="checkbox"> | `'AzureFile'` or `'NfsAzureFile'` | <pre>'AzureFile'</pre> | The type of storage to use: AzureFile (with account key) or NfsAzureFile (NFS v3 protocol) |
| storageAccountKey | string | <input type="checkbox"> | None | <pre>''</pre> | The account key to use on the storage account (required for AzureFile type if accountKeyVaultProperties is not provided) |
| storageAccountName | string | <input type="checkbox" checked> | None | <pre></pre> | the storage account name. This should be pre-existing. |
| storageAccountFileShareName | string | <input type="checkbox" checked> | None | <pre></pre> | the fileshare name in the storage account. |
| storagesAccessMode | string | <input type="checkbox"> | None | <pre>'ReadWrite'</pre> | Since you need to use a shareName (Azure File Share Storage), accessMode should be set to either ReadWrite or ReadOnly. |
| accountKeyVaultProperties | AccountKeyVaultProperties? | <input type="checkbox" checked> | None | <pre></pre> | Optional properties to reference the storage account key from Key Vault. If provided, this will be used instead of a plain account key. |

## Examples
<pre>
module storages 'br:contosoregistry.azurecr.io/app/managedenvironments/storages:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 48), 'storages')
  params: {
    managedEnvironmentName: managedEnvironmentName
    storageAccountFileShareName: 'myfileshare'
    accountKeyVaultProperties: {
      identity: uami.id
      keyVaultUrl: 'https://mykv.vault.azure.net/secrets/myStorageKey'
    }
    storageAccountName: storageAccountName
    location: location
  }
}
</pre>
<p>Creates a storages resource</p>

## Links
- [Bicep Microsoft.App/managedEnvironments storages](https://learn.microsoft.com/en-us/azure/templates/microsoft.app/2025-01-01/managedenvironments/storages?pivots=deployment-language-bicep)
