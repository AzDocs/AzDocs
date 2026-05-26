/*
.SYNOPSIS
Creating a document db table.
.DESCRIPTION
This module creates a document db table.
.EXAMPLE
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
.LINKS
- [Bicep Microsoft.DocumentDB databaseAccounts tables](https://learn.microsoft.com/en-us/azure/templates/microsoft.documentdb/2025-04-15/databaseaccounts/tables)
*/
@description('Required. Name of the table.')
param tableName string

@description('Optional. Tags for the table.')
param tags resourceInput<'Microsoft.DocumentDB/databaseAccounts/tables@2025-04-15'>.tags?

@description('The name of the DocumentDB instance to create the table on. This DocumentDB instance should already exist.')
@minLength(3)
@maxLength(44)
param databaseAccountName string

@description('Optional. Represents maximum throughput, the resource can scale up to. Cannot be set together with `throughput`. If `throughput` is set to something else than -1, this autoscale setting is ignored.')
param maxThroughput int = 4000

@description('Optional. Request Units per second (for example 10000). Cannot be set together with `maxThroughput`.')
param throughput int?

resource databaseAccount 'Microsoft.DocumentDB/databaseAccounts@2025-04-15' existing = {
  name: databaseAccountName
}

resource table 'Microsoft.DocumentDB/databaseAccounts/tables@2025-04-15' = {
  name: tableName
  tags: tags
  parent: databaseAccount
  properties: {
    options: contains(databaseAccount.properties.capabilities, { name: 'EnableServerless' })
      ? {}
      : {
          autoscaleSettings: throughput == null
            ? {
                maxThroughput: maxThroughput
              }
            : null
          throughput: throughput
        }
    resource: {
      id: tableName
    }
  }
}

@description('The name of the table.')
output name string = table.name

@description('The resource ID of the table.')
output resourceId string = table.id
