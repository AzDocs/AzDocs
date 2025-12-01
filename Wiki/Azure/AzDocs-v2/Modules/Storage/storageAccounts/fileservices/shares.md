# shares

Target Scope: resourceGroup

## Synopsis
Creating a file share in an existing file service.

## Description
Creating a file share in an existing file service.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| storageAccountName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the existing storage account. |
| fileServiceName | string | <input type="checkbox"> | None | <pre>'default'</pre> | The name of the existing file service. |
| fileShareName | string | <input type="checkbox" checked> | Length between 3-63 | <pre></pre> | Specifies the name of the File Share. File share names must be between 3 and 63 characters in length and use numbers, lower-case letters and dash (-) only. |
| shareQuota | int | <input type="checkbox"> | None | <pre>5120</pre> | Specifies the quota of the File Share in GB. Larger than 5 TB requires a storage account with large file shares feature enabled.<br>It is the provisioned capacity for the file share, ranging from 32 GiB to 262144 GiB. |
| accessTier | string | <input type="checkbox"> | `'Hot'` or `'Cool'` or `'Premium'` or `'TransactionOptimized'` | <pre>'TransactionOptimized'</pre> | Specifies the access tier of the File Share. Options are Hot, Cool, TransactionOptimized. |
| enabledProtocols | string | <input type="checkbox"> | `'SMB'` or `'NFS'` | <pre>'SMB'</pre> | Specifies the enabled protocols of the File Share. Options are SMB, NFS. |
| metadata | object | <input type="checkbox"> | None | <pre>{}</pre> | A set of name-value pairs that can be used to store additional information about the file share as metadata. |
| rootSquash | string | <input type="checkbox"> | `'NoRootSquash'` or `'RootSquash'` or `'AllSquash'` | <pre>'NoRootSquash'</pre> | Specifies the root squash setting for NFS shares. Options are NoRootSquash, RootSquash, AllSquash. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| fileShareId | string |  |
| fileShareName | string |  |

## Examples
<pre>
module storageaccount 'br:contosoregistry.azurecr.io/storage/storageaccounts/fileservices/shares:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 59), 'share')
  params: {
    storageAccountName: storageAccountName
    shareName: 'myfirstshare'
  }
}
</pre>
<p>Creates a file share with the name myfirstshare in an existing storage account.</p>

## Links
- [Bicep Storage File Services Shares](https://learn.microsoft.com/en-us/azure/templates/microsoft.storage/storageaccounts/fileservices/shares?pivots=deployment-language-bicep)
