/*
.SYNOPSIS
Creates a document db database.
.DESCRIPTION
Creates a document db database.
.EXAMPLE
<pre>
module database 'br:contosoregistry.azurecr.io/documentdb/databaseaccounts/sqldatabases:latest' = {
  name: 'creating_a_documentdb_database'
  scope: resourceGroup
  params: {
    documentDbName: 'mydocumentdb'
    databaseName: 'mydatabase'
    options: {
      maxThroughput: 400
    }
    tags: {
      environment: 'dev'
    }
  }
}
</pre>
<p>Creates a documentdb database with the given specs</p>
.LINKS
- [Bicep Microsoft.DocumentDB/databaseAccounts sqlDatabases](https://learn.microsoft.com/en-us/azure/templates/microsoft.documentdb/2025-04-15/databaseaccounts/sqldatabases?pivots=deployment-language-bicep)
*/

@description('The name of the Document DB account.')
param documentDbName string

@description('The name of the database to upsert.')
param databaseName string

@description('The options for the database.')
param options object = {}

@description('Specifies the location for all resources.')
param location string = resourceGroup().location

@description('Enum to indicate the mode of resource creation. Default or Restore.')
param createMode string = 'Default'

@description('Parameters to indicate the information about the restore. Only used when createMode is Restore.')
param restoreParameters object = {}

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

resource database 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2025-04-15' = {
  name: '${documentDbName}/${databaseName}'
  location: location
  tags: tags
  properties: {
    resource: {
      id: databaseName
      createMode: createMode
      restoreParameters: createMode == 'Restore' && !empty(restoreParameters) ? restoreParameters : null
    }
    options: options
  }
}

@description('The id of the database.')
output databaseId string = database.id
