# tables

Target Scope: resourceGroup

## Synopsis
Creating a table in an existing table service.

## Description
Creating a table in an existing table service.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| storageAccountName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the existing storage account. |
| tableServiceName | string | <input type="checkbox"> | None | <pre>'default'</pre> | The name of the existing table service. |
| tableName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the table to create. |

## Examples
<pre>
module storageaccount 'br:contosoregistry.azurecr.io/storage/storageaccounts/tableservices/tables:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 59), 'table')
  params: {
    storageAccountName: storageAccountName
    tableName: 'myfirsttable'
  }
}
</pre>
<p>Creates a table with the name myfirsttable in an existing storage account.</p>

## Links
- [Bicep Storage Table Services Table](https://learn.microsoft.com/en-us/azure/templates/microsoft.storage/storageaccounts/tableservices/tables?pivots=deployment-language-bicep)
