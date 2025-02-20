# managementPolicies

Target Scope: resourceGroup

## Synopsis
Creating a management policy for an existing storage account.

## Description
Creating a management policy for an existing storage account.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| storageAccountName | string | <input type="checkbox" checked> | Length between 0-24 | <pre></pre> | The name of the parent Storage Account which should be existing. |
| rules | array | <input type="checkbox" checked> | None | <pre></pre> | Required. The Storage Account ManagementPolicies Rules. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| resourceId | string | The resource ID of the deployed management policy. |
| name | string | The name of the deployed management policy. |

## Examples
<pre>
module storageaccount 'br:contosoregistry.azurecr.io/storage/storageaccounts/managementpolicies:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 55), 'mgtmtpolicy')
  params: {
    storageAccountName: storageAccountName
    rules: [
      {
        enabled: true
        name: 'lifecycle_tiers'
        type: 'Lifecycle'
        definition: {
          actions: {
            baseBlob: {
              tierToCold: {
                daysAfterModificationGreaterThan: 30
              }
              tierToCool: {
                daysAfterModificationGreaterThan: 10
              }
            }
          }
          filters: {
            blobTypes: [
              'blockBlob'
            ]
          }
        }
      }
    ]
  }
}
</pre>
<p>Creates a blob container management policy for an existing storage account.</p>

## Links
- [Bicep Storage Management Policy](https://learn.microsoft.com/en-us/azure/templates/microsoft.storage/storageaccounts/managementpolicies?pivots=deployment-language-bicep)
