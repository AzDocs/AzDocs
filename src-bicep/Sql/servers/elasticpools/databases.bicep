metadata name = 'SQL Elastic Pool Database'
metadata description = 'This module references an existing database child resource under an Azure SQL Elastic Pool.'

/*
.SYNOPSIS
Reference a SQL Database under an existing SQL Elastic Pool.
.DESCRIPTION
References the Microsoft.Sql/servers/elasticPools/databases child resource in an existing SQL Elastic Pool.
.EXAMPLE
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
.LINKS
- [Bicep Microsoft.Sql servers elasticPools databases](https://learn.microsoft.com/en-us/azure/templates/microsoft.sql/servers/elasticpools/databases?pivots=deployment-language-bicep)
*/

// ================================================= Parameters =================================================
@description('The resource name of the existing SQL Server that contains the target Elastic Pool.')
@minLength(1)
@maxLength(63)
param sqlServerName string

@description('The name of the existing SQL Elastic Pool where the database child resource exists.')
@minLength(1)
@maxLength(128)
param elasticPoolName string

@description('The name of the SQL Database child resource in the Elastic Pool.')
@minLength(1)
@maxLength(128)
param sqlDatabaseName string

// ================================================= Existing Resources =================================================
@description('Fetch the SQL Server that hosts the target Elastic Pool.')
resource sqlServer 'Microsoft.Sql/servers@2025-01-01' existing = {
	name: sqlServerName
}

@description('Fetch the SQL Elastic Pool where the child database resource exists.')
resource elasticPool 'Microsoft.Sql/servers/elasticPools@2025-01-01' existing = {
	parent: sqlServer
	name: elasticPoolName
}

// ================================================= Resources =================================================
@description('Fetch the SQL Database child resource under the target Elastic Pool.')
resource elasticPoolDatabase 'Microsoft.Sql/servers/elasticPools/databases@2014-04-01' existing = {
	parent: elasticPool
	name: sqlDatabaseName
}

// ================================================= Outputs =================================================
@description('The resource identifier of the Elastic Pool Database child resource.')
output elasticPoolDatabaseId string = elasticPoolDatabase.id

@description('The resource name of the associated SQL Database.')
output elasticPoolDatabaseName string = elasticPoolDatabase.name
