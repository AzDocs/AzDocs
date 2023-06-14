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
- [Bicep Microsoft.DocumentDB/databaseAccounts/sqlDatabases containers](https://learn.microsoft.com/en-us/azure/templates/microsoft.documentdb/databaseaccounts/sqldatabases/containers?pivots=deployment-language-bicep)
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

resource container 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2023-04-15' = {
  name: '${documentDbName}/${databaseName}/${containerName}'
  tags: tags
  properties: {
    resource: {
      id: containerName
      partitionKey: partitionKey
      indexingPolicy: indexingPolicy
      conflictResolutionPolicy: conflictResolutionPolicy
    }
    options: options
  }
}

@description('The id of the container.')
output containerId string = container.id
