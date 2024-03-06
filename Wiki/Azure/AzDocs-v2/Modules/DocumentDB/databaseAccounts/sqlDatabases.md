# sqlDatabases

Target Scope: resourceGroup

## Synopsis
Creates a document db database.

## Description
Creates a document db database.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| documentDbName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the Document DB account. |
| databaseName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the database to upsert. |
| options | object | <input type="checkbox"> | None | <pre>{}</pre> | The options for the database. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;The tag object.<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;For example (in YAML):<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ApplicationID: 1234<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ApplicationName: MyCmdbAppName<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ApplicationOwner: myproductowner@company.com<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;AppTechOwner: myteam@company.com<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;BillingIdentifier: 123456<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;BusinessUnit: MyBusinessUnit<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;CostType: Application<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;EnvironmentType: dev<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;PipelineBuildNumber: 2022.08.02-main<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;PipelineRunUrl: https://dev.azure.com/org/TeamProject/_build/results?buildId=1234&view=results |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| databaseId | string | The id of the database. |

## Examples
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

## Links
- [Bicep Microsoft.DocumentDB/databaseAccounts sqlDatabases](https://learn.microsoft.com/en-us/azure/templates/microsoft.documentdb/databaseaccounts/sqldatabases?pivots=deployment-language-bicep)
