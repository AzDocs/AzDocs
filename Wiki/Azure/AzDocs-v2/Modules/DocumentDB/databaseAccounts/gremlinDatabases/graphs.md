# graphs

Target Scope: resourceGroup

## Synopsis
Creating a document db Gremlin graph.

## Description
This module creates a document db Gremlin graph within an existing Gremlin database.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| name | string | <input type="checkbox" checked> | None | <pre></pre> | Required. Name of the graph. |
| tags | resourceInput<'Microsoft.DocumentDB/databaseAccounts/gremlinDatabases/graphs@2025-04-15'>.tags? | <input type="checkbox" checked> | None | <pre></pre> | Optional. Tags for the Gremlin graph resource. |
| databaseAccountName | string | <input type="checkbox" checked> | Length between 3-44 | <pre></pre> | The name of the parent DocumentDB account. This DocumentDB instance should already exist. |
| gremlinDatabaseName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the parent Gremlin database. This Gremlin database should already exist. |
| indexingPolicy | resourceInput<'Microsoft.DocumentDB/databaseAccounts/gremlinDatabases/graphs@2025-04-15'>.properties.resource.indexingPolicy? | <input type="checkbox" checked> | None | <pre></pre> | Optional. The indexing policy to apply to the graph. |
| partitionKeyPaths | array | <input type="checkbox"> | None | <pre>[<br>  '/id'<br>]</pre> | Optional. The list of partition key paths to apply to the graph. Defaults to `/id`. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| name | string | The name of the graph. |
| resourceId | string | The resource ID of the graph. |
| resourceGroupName | string | The name of the resource group the graph was created in. |

## Examples
<pre>
module gremlinGraph 'br:contosoregistry.azurecr.io/documentdb/databaseaccounts/gremlindatabases/graphs:latest' = {
  name: 'Creating_a_document_db_gremlin_graph'
  scope: resourceGroup
  params: {
    databaseAccountName: 'mydocumentdb'
    gremlinDatabaseName: 'mygremlindatabase'
    name: 'mygraph'
    partitionKeyPaths: [
      '/id'
    ]
    tags: {
      environment: 'dev'
    }
  }
}
</pre>
<p>Creates a document db Gremlin graph with the given specs</p>

## Links
- [Bicep Microsoft.DocumentDB databaseAccounts gremlinDatabases graphs](https://learn.microsoft.com/en-us/azure/templates/microsoft.documentdb/2025-04-15/databaseaccounts/gremlindatabases/graphs)
