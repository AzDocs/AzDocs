# tables

Target Scope: resourceGroup

## Synopsis
Creating a document db table.

## Description
This module creates a document db table.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| tableName | string | <input type="checkbox" checked> | None | <pre></pre> | Required. Name of the table. |
| tags | resourceInput<'Microsoft.DocumentDB/databaseAccounts/tables@2025-04-15'>.tags? | <input type="checkbox" checked> | None | <pre></pre> | Optional. Tags for the table. |
| databaseAccountName | string | <input type="checkbox" checked> | None | <pre></pre> | Conditional. The name of the parent Azure Cosmos DB account. Required if the template is used in a standalone deployment. |
| maxThroughput | int | <input type="checkbox"> | None | <pre>4000</pre> | Optional. Represents maximum throughput, the resource can scale up to. Cannot be set together with `throughput`. If `throughput` is set to something else than -1, this autoscale setting is ignored. |
| throughput | int? | <input type="checkbox" checked> | None | <pre></pre> | Optional. Request Units per second (for example 10000). Cannot be set together with `maxThroughput`. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| name | string | The name of the table. |
| resourceId | string | The resource ID of the table. |

## Examples
<pre>
module table 'br:contosoregistry.azurecr.io/documentdb/databaseaccounts/tables:latest' = {
  name: 'Creating_a_document_db_table'
  scope: resourceGroup
  params: {
    databaseAccountName: 'mydocumentdb'
    tableName: 'mytablename'
    maxThroughput: 4000
    throughput: null
    tags: {
      environment: 'dev'
    }
  }
}
</pre>
<p>Creates a documentdb table with the given specs</p>

## Links
- [Bicep Microsoft.DocumentDB databaseAccounts tables](https://learn.microsoft.com/en-us/azure/templates/microsoft.documentdb/2025-04-15/databaseaccounts/tables)
