# tableServices

Target Scope: resourceGroup

## Synopsis
Creating a table service in an existing storage account.

## Description
Creating a table service in an existing storage account.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| storageAccountName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the existing storage account. |
| tableServiceName | string | <input type="checkbox"> | None | <pre>'default'</pre> | The name of the table service to create. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| tableServiceId | string |  |

## Examples
<pre>
module storageaccount 'br:contosoregistry.azurecr.io/storage/storageaccounts/tableservices:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 55), 'tablesvc')
  params: {
    storageAccountName: storageAccountName
  }
}
</pre>
<p>Creates a tables services in an existing storage account.</p>

## Links
- [Bicep Storage Table Services](https://learn.microsoft.com/en-us/azure/templates/microsoft.storage/storageaccounts/tableservices?pivots=deployment-language-bicep)
