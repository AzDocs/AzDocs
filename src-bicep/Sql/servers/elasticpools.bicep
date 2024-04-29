/*
.SYNOPSIS
Creating an elastic pool
.DESCRIPTION
Creating an elastic pool with the given specs.
.EXAMPLE
<pre>
module sql 'br:contosoregistry.azurecr.io/sql/servers/elasticpools.bicep:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 61), 'ep')
  params: {
    sku: {
      name: 'StandardPool'
      tier: 'Standard'
      capacity: 50
    }
    sqlServerName: sqlserver.outputs.sqlServerName
    location: location
    elasticPoolName: 'elasticpoolname'
    databaseCapacityMin: 0
    databaseCapacityMax: 10
  }
}
</pre>
<p>Creates an elastic pool with the name elasticpoolname</p>
.LINKS
- [Bicep Microsoft.SQL servers](https://learn.microsoft.com/en-us/azure/templates/microsoft.sql/servers/elasticpools?pivots=deployment-language-bicep)
*/

// ================================================= Parameters =================================================
@description('Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location.')
param location string = resourceGroup().location

@description('The resourcename of the SQL Server to use (should be pre-existing).')
@minLength(1)
@maxLength(63)
param sqlServerName string

@description('The Elastic Pool name.')
param elasticPoolName string

@description('The Elastic Pool database capacity min.')
param databaseCapacityMin int = 0

@description('The Elastic Pool database capacity max.')
param databaseCapacityMax int = 2

@description('''
The SKU object to use for this Elastic Pool. Defaults to a standard pool. 
Example
param sku object = {
  name: 'PremiumPool'
  tier: 'Premium'
}
''')
param sku object = {
  name: 'StandardPool'
  tier: 'Standard'
  capacity: 50
}

// ================================================= Existing Resources =================================================
@description('Fetch the SQL server to use as underlying provider for the SQL Database')
resource sqlServer 'Microsoft.Sql/servers@2023-05-01-preview' existing = {
  name: sqlServerName
}

// ================================================= Resources =================================================
resource elasticPool 'Microsoft.Sql/servers/elasticPools@2023-02-01-preview' = {
  parent: sqlServer
  location: location
  name: elasticPoolName
  sku: sku
  properties: {
    perDatabaseSettings: {
      minCapacity: databaseCapacityMin
      maxCapacity: databaseCapacityMax
    }
  }
}

@description('The resource id of the Elastic Pool.')
output elasticPoolId string = elasticPool.id
@description('The resource name of the Elastic Pool.')
output elasticPoolName string = elasticPool.name
