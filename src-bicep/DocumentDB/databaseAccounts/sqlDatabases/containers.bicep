/*
.SYNOPSIS
Creates a document db container.
.DESCRIPTION
Creates a document db container.
.EXAMPLE
<pre>
module container 'br:contosoregistry.azurecr.io/documentdb/databaseaccounts/sqldatabases/containers:latest' = {
  name: 'creating_a_documentdb_container'
  scope: resourceGroup
  params: {
    documentDbName: 'documentdb'
    databaseName: 'database'
    containerName: 'container'
  }
}
</pre>
<p>Creates a documentdb container with the given specs</p>
.LINKS
- [Bicep Microsoft.DocumentDB/databaseAccounts/sqlDatabases containers](https://learn.microsoft.com/en-us/azure/templates/microsoft.documentdb/2025-04-15/databaseaccounts/sqldatabases/containers?pivots=deployment-language-bicep)
*/

@description('The name of the DocumentDB account.')
param documentDbName string

@description('The name of the database.')
param databaseName string

@description('The name of the container.')
param containerName string

@description('The partition key for the container.')
param partitionKey object = {
  paths: [
    '/id'
  ]
  kind: 'Hash'
  version: 2
}

@description('The indexing policy for the container.')
param indexingPolicy object = {
  automatic: true
  indexingMode: 'consistent'
  includedPaths: [
    {
      path: '/*'
    }
  ]
  excludedPaths: [
    {
      path: '/"_etag"/?'
    }
  ]
}

@description('The conflict resolution policy for the container.')
param conflictResolutionPolicy object = {
  mode: 'LastWriterWins'
}

@description('The options for the container.')
param options object = {}

@description('Specifies the location for all resources.')
param location string = resourceGroup().location

@description('Enum to indicate the mode of resource creation. Default or Restore.')
param createMode string = 'Default'

@description('Parameters to indicate the information about the restore. Only used when createMode is Restore.')
param restoreParameters object = {}

@description('Analytical TTL. Enables analytical storage when set to a value other than 0. -1 for infinite retention.')
param analyticalStorageTtl int = 0

@description('Default time to live in seconds. -1 for infinity, items do not expire by default.')
param defaultTtl int = -1

@description('List of computed properties for server-side calculations.')
param computedProperties array = []

@description('Client encryption policy for the container.')
param clientEncryptionPolicy object = {}

@description('Full-text search policy for the container.')
param fullTextPolicy object = {}

@description('Unique key policy configuration for uniqueness constraints.')
param uniqueKeyPolicy object = {}

@description('Vector embedding policy for AI/vector search capabilities.')
param vectorEmbeddingPolicy object?

@description('''
    The tag object.
    For example (in YAML):
      ApplicationID: 1234
      ApplicationName: MyCmdbAppName
      ApplicationOwner: myproductowner@company.com
      AppTechOwner: myteam@company.com
      BillingIdentifier: 123456
      BusinessUnit: MyBusinessUnit
      CostType: Application
      EnvironmentType: dev
      PipelineBuildNumber: 2022.08.02-main
      PipelineRunUrl: https://dev.azure.com/org/TeamProject/_build/results?buildId=1234&view=results
''')
param tags object = {}

resource container 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2025-04-15' = {
  name: '${documentDbName}/${databaseName}/${containerName}'
  location: location
  tags: tags
  properties: {
    resource: {
      id: containerName
      createMode: createMode
      partitionKey: partitionKey
      indexingPolicy: indexingPolicy
      conflictResolutionPolicy: conflictResolutionPolicy
      restoreParameters: createMode == 'Restore' && !empty(restoreParameters) ? restoreParameters : null
      analyticalStorageTtl: analyticalStorageTtl
      defaultTtl: defaultTtl
      computedProperties: !empty(computedProperties) ? computedProperties : null
      clientEncryptionPolicy: !empty(clientEncryptionPolicy) ? clientEncryptionPolicy : null
      fullTextPolicy: !empty(fullTextPolicy) ? fullTextPolicy : null
      uniqueKeyPolicy: !empty(uniqueKeyPolicy) ? uniqueKeyPolicy : null
      vectorEmbeddingPolicy: !empty(vectorEmbeddingPolicy) ? vectorEmbeddingPolicy : null
    }
    options: options
  }
}

@description('The id of the container.')
output containerId string = container.id
