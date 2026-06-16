# gremlinDatabases

Target Scope: resourceGroup

## Synopsis
Creating a document db Gremlin database.

## Description
This module creates a document db Gremlin database within an existing document db account.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| name | string | <input type="checkbox" checked> | None | <pre></pre> | Required. Name of the Gremlin database. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| databaseAccountName | string | <input type="checkbox" checked> | Length between 3-44 | <pre></pre> | The name of the DocumentDB instance to create the Gremlin database on. This DocumentDB instance should already exist. |
| maxThroughput | int | <input type="checkbox"> | None | <pre>4000</pre> | Optional. Represents the maximum throughput the database can scale up to. Cannot be set together with `throughput`. If `throughput` is set, this autoscale setting is ignored. Setting throughput at the database level is recommended only for development, test, or uniformly shared workloads across all graphs. |
| throughput | int? | <input type="checkbox" checked> | None | <pre></pre> | Optional. Request Units per second for the Gremlin database, for example 10000. Cannot be set together with `maxThroughput`. For large production workloads, prefer dedicated throughput at the graph level. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| name | string | The name of the Gremlin database. |
| resourceId | string | The resource ID of the Gremlin database. |
| resourceGroupName | string | The name of the resource group the Gremlin database was created in. |

## Examples
<pre>
module gremlinDatabase 'br:contosoregistry.azurecr.io/documentdb/databaseaccounts/gremlindatabases:latest' = {
  name: 'Creating_a_document_db_gremlin_database'
  scope: resourceGroup
  params: {
    databaseAccountName: 'mydocumentdb'
    name: 'mygremlindatabase'
    maxThroughput: 4000
    throughput: null
    tags: {
      environment: 'dev'
    }
  }
}
</pre>
<p>Creates a document db Gremlin database with the given specs</p>

## Links
- [Bicep Microsoft.DocumentDB databaseAccounts gremlinDatabases](https://learn.microsoft.com/en-us/azure/templates/microsoft.documentdb/2025-04-15/databaseaccounts/gremlindatabases)
