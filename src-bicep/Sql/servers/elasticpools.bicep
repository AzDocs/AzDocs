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
      name: 'GP_Gen5'
      tier: 'GeneralPurpose'
      capacity: 2
      family: 'Gen5'
    }
    sqlServerName: sqlserver.outputs.sqlServerName
    location: location
    elasticPoolName: 'elasticpoolname'
    databaseCapacityMin: 0
    databaseCapacityMax: 10
    elasticPoolPreferredEnclave: 'Default'
    elasticPoolLicense: 'LicenseIncluded'
    elasticPoolZoneRedundant: false
    elasticPoolAvailabilityZone: 'NoPreference'
    elasticPoolHighAvailabilityMode: 1
    elasticPoolMaxSizeBytes: 268435456000 // 250 GB
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

@description('The Elastic Pool license type. For options, please refer to [elasticPoolLicenseType].')
type elasticPoolLicenseType = 'LicenseIncluded' | 'BasePrice'

@description('The license type for the Elastic Pool.')
param elasticPoolLicense elasticPoolLicenseType = 'LicenseIncluded'

@description('Specifies whether the Elastic Pool is zone redundant.')
param elasticPoolZoneRedundant bool = false

@description('The elastic pool availability zone. For options, please refer to [elasticPoolAvailabilityZone].')
type elasticPoolAvailabilityZoneType = '1' | '2' | '3' | 'NoPreference'

@description('The availability zone for the Elastic Pool.')
param elasticPoolAvailabilityZone elasticPoolAvailabilityZoneType = 'NoPreference'

@maxValue(3)
@description('The high availability replica count for the Elastic Pool.')
param elasticPoolHighAvailabilityMode int = 1

@description('The maximum size in bytes for the Elastic Pool.')
param elasticPoolMaxSizeBytes int = 268435456000 // 250 GB

@description('The preferred enclave type of the Elastic Pool. For options, please refer to [elasticPoolPreferredEnclaveType].')
type elasticPoolPreferredEnclaveType = 'Default' | 'VBS'

@description('The preferred enclave type for the Elastic Pool.')
param elasticPoolPreferredEnclave elasticPoolPreferredEnclaveType = 'Default'

@description('The sku name of the Elastic Pool. For options, please refer to [elasticPoolSkuName].')
type elasticPoolSkuName = 'BC_Gen4' | 'GP_Gen4' | 'HS_Gen5' | 'BC_Gen5' | 'GP_Gen5'

@description('The sku family of the Elastic Pool. For options, please refer to [elasticPoolSkuFamily].')
type elasticPoolSkuFamily = 'Gen5' | 'Gen4'

@description('The sku capacity of the Elastic Pool. For options, please refer to [elasticPoolSkuCapacity].')
type elasticPoolSkuCapacity = int

@description('The sku tier of the Elastic Pool. For options, please refer to [elasticPoolSkuTier].')
type elasticPoolSkuTier = 'GeneralPurpose' | 'BusinessCritical' | 'Hyperscale'

@export()
@description('The Elastic Pool sku size. For options, please refer to [elasticPoolSkuSize].')
type elasticPoolSkuSize = 'Basic' | 'Standard' | 'Premium' | 'GeneralPurpose' | 'BusinessCritical' | 'Hyperscale'

@description('The Elastic Pool sku type. For options, please refer to [elasticPoolSku].')
type elasticPoolSku = {
  @description('The name of the Elastic Pool SKU.')
  name: elasticPoolSkuName

  @description('The tier of the Elastic Pool SKU.')
  tier: elasticPoolSkuTier

  @description('The family of the Elastic Pool SKU.')
  family: elasticPoolSkuFamily?

  @description('The capacity of the Elastic Pool SKU.')
  capacity: elasticPoolSkuCapacity
}

@description('''
The SKU object to use for this Elastic Pool. Defaults to a standard pool. 
Example
param sku object = {
  name: 'PremiumPool'
  tier: 'Premium'
}
''')
param sku elasticPoolSku = {
  name: 'GP_Gen5'
  tier: 'GeneralPurpose'
  family: 'Gen5'
  capacity: 2
} //default sku for elastic pool

// ================================================= Existing Resources =================================================
@description('Fetch the SQL server to use as underlying provider for the SQL Database')
resource sqlServer 'Microsoft.Sql/servers@2024-05-01-preview' existing = {
  name: sqlServerName
}

// ================================================= Resources =================================================
resource elasticPool 'Microsoft.Sql/servers/elasticPools@2024-05-01-preview' = {
  parent: sqlServer
  location: location
  name: elasticPoolName
  sku: sku
  properties: {
    perDatabaseSettings: {
      minCapacity: databaseCapacityMin
      maxCapacity: databaseCapacityMax
    }
    preferredEnclaveType: elasticPoolPreferredEnclave
    licenseType: elasticPoolLicense
    zoneRedundant: elasticPoolZoneRedundant
    availabilityZone: elasticPoolAvailabilityZone
    highAvailabilityReplicaCount: elasticPoolHighAvailabilityMode
    maxSizeBytes: elasticPoolMaxSizeBytes
  }
}

@description('The resource id of the Elastic Pool.')
output elasticPoolId string = elasticPool.id
@description('The resource name of the Elastic Pool.')
output elasticPoolName string = elasticPool.name
