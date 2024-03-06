# containers

Target Scope: resourceGroup

## Synopsis
Creates a document db container.

## Description
Creates a document db container.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| documentDbName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the DocumentDB account. |
| databaseName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the database. |
| containerName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the container. |
| partitionKey | object | <input type="checkbox"> | None | <pre>{<br>  paths: [<br>    '/id'<br>  ]<br>  kind: 'Hash'<br>  version: 2<br>}</pre> | The partition key for the container. |
| indexingPolicy | object | <input type="checkbox"> | None | <pre>{<br>  automatic: true<br>  indexingMode: 'consistent'<br>  includedPaths: [<br>    {<br>      path: '/*'<br>    }<br>  ]<br>  excludedPaths: [<br>    {<br>      path: '/"_etag"/?'<br>    }<br>  ]<br>}</pre> | The indexing policy for the container. |
| conflictResolutionPolicy | object | <input type="checkbox"> | None | <pre>{<br>  mode: 'LastWriterWins'<br>}</pre> | The conflict resolution policy for the container. |
| options | object | <input type="checkbox"> | None | <pre>{}</pre> | The options for the container. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;The tag object.<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;For example (in YAML):<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ApplicationID: 1234<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ApplicationName: MyCmdbAppName<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ApplicationOwner: myproductowner@company.com<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;AppTechOwner: myteam@company.com<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;BillingIdentifier: 123456<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;BusinessUnit: MyBusinessUnit<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;CostType: Application<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;EnvironmentType: dev<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;PipelineBuildNumber: 2022.08.02-main<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;PipelineRunUrl: https://dev.azure.com/org/TeamProject/_build/results?buildId=1234&view=results |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| containerId | string | The id of the container. |

## Examples
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

## Links
- [Bicep Microsoft.DocumentDB/databaseAccounts/sqlDatabases containers](https://learn.microsoft.com/en-us/azure/templates/microsoft.documentdb/databaseaccounts/sqldatabases/containers?pivots=deployment-language-bicep)
