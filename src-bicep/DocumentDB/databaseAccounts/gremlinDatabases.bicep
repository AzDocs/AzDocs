/*
.SYNOPSIS
Creating a document db Gremlin database.
.DESCRIPTION
This module creates a document db Gremlin database within an existing document db account.
.EXAMPLE
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
.LINKS
- [Bicep Microsoft.DocumentDB databaseAccounts gremlinDatabases](https://learn.microsoft.com/en-us/azure/templates/microsoft.documentdb/2025-04-15/databaseaccounts/gremlindatabases)
*/
@description('Required. Name of the Gremlin database.')
param name string

@description('''
The tags to apply to this resource. This is an object with key/value pairs.
Example:
{
  FirstTag: myvalue
  SecondTag: another value
}
''')
param tags object = {}

@description('The name of the DocumentDB instance to create the Gremlin database on. This DocumentDB instance should already exist.')
@minLength(3)
@maxLength(44)
param databaseAccountName string

@description('Optional. Represents the maximum throughput the database can scale up to. Cannot be set together with `throughput`. If `throughput` is set, this autoscale setting is ignored. Setting throughput at the database level is recommended only for development, test, or uniformly shared workloads across all graphs.')
param maxThroughput int = 4000

@description('Optional. Request Units per second for the Gremlin database, for example 10000. Cannot be set together with `maxThroughput`. For large production workloads, prefer dedicated throughput at the graph level.')
param throughput int?

var accountCapabilities = databaseAccount.properties.capabilities ?? []

var isServerless = contains(string(accountCapabilities), 'EnableServerless')

var databaseOptions = isServerless
  ? {}
  : {
      ...(throughput == null
        ? {
            autoscaleSettings: {
              maxThroughput: maxThroughput
            }
          }
        : {})
      ...(throughput != null
        ? {
            throughput: throughput ?? 0
          }
        : {})
    }

resource databaseAccount 'Microsoft.DocumentDB/databaseAccounts@2025-04-15' existing = {
  name: databaseAccountName
}

resource gremlinDatabase 'Microsoft.DocumentDB/databaseAccounts/gremlinDatabases@2025-04-15' = {
  parent: databaseAccount
  name: name
  tags: tags
  properties: {
    options: databaseOptions
    resource: {
      id: name
    }
  }
}

@description('The name of the Gremlin database.')
output name string = gremlinDatabase.name

@description('The resource ID of the Gremlin database.')
output resourceId string = gremlinDatabase.id

@description('The name of the resource group the Gremlin database was created in.')
output resourceGroupName string = resourceGroup().name
