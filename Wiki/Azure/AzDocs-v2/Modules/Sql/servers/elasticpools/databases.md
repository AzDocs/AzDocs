# databases

Target Scope: resourceGroup

## Synopsis
Reference a SQL Database under an existing SQL Elastic Pool.

## Description
References the Microsoft.Sql/servers/elasticPools/databases child resource in an existing SQL Elastic Pool.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| sqlServerName | string | <input type="checkbox" checked> | Length between 1-63 | <pre></pre> | The resource name of the existing SQL Server that contains the target Elastic Pool. |
| elasticPoolName | string | <input type="checkbox" checked> | Length between 1-128 | <pre></pre> | The name of the existing SQL Elastic Pool where the database child resource exists. |
| sqlDatabaseName | string | <input type="checkbox" checked> | Length between 1-128 | <pre></pre> | The name of the SQL Database child resource in the Elastic Pool. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| elasticPoolDatabaseId | string | The resource identifier of the Elastic Pool Database child resource. |
| elasticPoolDatabaseName | string | The resource name of the associated SQL Database. |

## Examples
<pre>
module elasticPoolDatabase 'br:contosoregistry.azurecr.io/sql/servers/elasticpools/databases:latest' = {
	name: format('{0}-{1}', take('${deployment().name}', 61), 'epdb')
	params: {
		sqlServerName: 'my-sql-server'
		elasticPoolName: 'my-elastic-pool'
		sqlDatabaseName: 'my-database'
	}
}
</pre>
<p>Associates my-database with my-elastic-pool on my-sql-server.</p>

## Links
- [Bicep Microsoft.Sql servers elasticPools databases](https://learn.microsoft.com/en-us/azure/templates/microsoft.sql/servers/elasticpools/databases?pivots=deployment-language-bicep)
