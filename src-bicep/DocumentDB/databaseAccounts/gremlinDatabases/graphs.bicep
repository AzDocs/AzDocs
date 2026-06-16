/*
.SYNOPSIS
Creating a document db Gremlin graph.
.DESCRIPTION
This module creates a document db Gremlin graph within an existing Gremlin database.
.EXAMPLE
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
.LINKS
- [Bicep Microsoft.DocumentDB databaseAccounts gremlinDatabases graphs](https://learn.microsoft.com/en-us/azure/templates/microsoft.documentdb/2025-04-15/databaseaccounts/gremlindatabases/graphs)
*/
@description('Required. Name of the graph.')
param name string

@description('Optional. Tags for the Gremlin graph resource.')
param tags resourceInput<'Microsoft.DocumentDB/databaseAccounts/gremlinDatabases/graphs@2025-04-15'>.tags?

@description('The name of the parent DocumentDB account. This DocumentDB instance should already exist.')
@minLength(3)
@maxLength(44)
param databaseAccountName string

@description('The name of the parent Gremlin database. This Gremlin database should already exist.')
param gremlinDatabaseName string

@description('Optional. The indexing policy to apply to the graph.')
param indexingPolicy resourceInput<'Microsoft.DocumentDB/databaseAccounts/gremlinDatabases/graphs@2025-04-15'>.properties.resource.indexingPolicy?

@description('Optional. The list of partition key paths to apply to the graph. Defaults to `/id`.')
param partitionKeyPaths array = [
  '/id'
]

resource databaseAccount 'Microsoft.DocumentDB/databaseAccounts@2025-04-15' existing = {
  name: databaseAccountName

  resource gremlinDatabase 'gremlinDatabases@2025-04-15' existing = {
    name: gremlinDatabaseName
  }
}

resource gremlinGraph 'Microsoft.DocumentDB/databaseAccounts/gremlinDatabases/graphs@2025-04-15' = {
  name: name
  tags: tags
  parent: databaseAccount::gremlinDatabase
  properties: {
    resource: {
      id: name
      indexingPolicy: indexingPolicy
      partitionKey: {
        paths: partitionKeyPaths
      }
    }
  }
}

@description('The name of the graph.')
output name string = gremlinGraph.name

@description('The resource ID of the graph.')
output resourceId string = gremlinGraph.id

@description('The name of the resource group the graph was created in.')
output resourceGroupName string = resourceGroup().name
