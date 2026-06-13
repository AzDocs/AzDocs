/*
.SYNOPSIS
Creating a database in an existing SQL server
.DESCRIPTION
Creating a database in an existing SQL server with the given specs.
.EXAMPLE
<pre>
module sql 'br:contosoregistry.azurecr.io/sql/servers/databases.bicep:2026.06.12.1-main' = {
  name: format('{0}-{1}', take('${deployment().name}', 61), 'db')
  params: {
    sqlServerName:sqlserver.outputs.sqlServerName
    location: location
    sqlDatabaseName: 'sqlDatabaseName'
  }
}
</pre>
<p>Creates a database called sqlDatabaseName in an existing Sql server with the name sqlServerName</p>
.LINKS
- [Bicep Microsoft.SQL servers](https://learn.microsoft.com/en-us/azure/templates/microsoft.sql/servers/databases?pivots=deployment-language-bicep)
*/

// ================================================= Parameters =================================================
@discriminator('type')
type IdentityType =
  | {
    type: 'UserAssigned'
    userAssignedIdentities: {
      *: {}
    }
  }
  | {
    type: 'None'
  }

@description('Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location.')
param location string = resourceGroup().location

@description('The resourcename of the SQL Server to use (should be pre-existing).')
@minLength(1)
@maxLength(63)
param sqlServerName string

@description('The name of the SQL Database to upsert.')
@minLength(1)
@maxLength(128)
param sqlDatabaseName string

@description('The azure resource id of the log analytics workspace to log the diagnostics to.')
@minLength(0)
param logAnalyticsWorkspaceResourceId string = ''

@description('The name of the diagnostics. This defaults to `AzurePlatformCentralizedLogging`.')
@minLength(1)
@maxLength(260)
param diagnosticsName string = 'AzurePlatformCentralizedLogging'

@description('''
The SKU object to use for this SQL Database. Defaults to a serverless General Purpose tier GP_S_Gen5 with capacity 2 sku. 
For the object format, refer to [sku](https://docs.microsoft.com/en-us/azure/templates/microsoft.sql/servers/databases?tabs=bicep#sku).
Example
param sku object = {
  name: 'ElasticPool'
  tier: 'Standard'
  capacity: 0
}
''')
param sku object = {
  name: 'GP_S_Gen5'
  tier: 'GeneralPurpose'
  family: 'Gen5'
  capacity: 2
}

@description('The collation of the database. Defaults to `SQL_Latin1_General_CP1_CI_AS`. For options, please refer to [collation](https://docs.microsoft.com/en-us/sql/relational-databases/collations/collation-and-unicode-support?view=sql-server-ver16#Server-level-collations).')
param collation string = 'SQL_Latin1_General_CP1_CI_AS'

@description('Collation of the metadata catalog. Leave empty to use service defaults.')
@allowed([
  ''
  'DATABASE_DEFAULT'
  'SQL_Latin1_General_CP1_CI_AS'
])
param catalogCollation string = ''

@description('Specifies the mode of database creation. Use restore/copy parameters below when not using Default mode.')
@allowed([
  'Copy'
  'Default'
  'OnlineSecondary'
  'PointInTimeRestore'
  'Recovery'
  'Restore'
  'RestoreExternalBackup'
  'RestoreExternalBackupSecondary'
  'RestoreLongTermRetentionBackup'
  'Secondary'
])
param createMode string = 'Default'

@description('The resource identifier of the source database associated with copy/restore/secondary create operations.')
param sourceDatabaseId string = ''

@description('Specifies the point in time (ISO8601 format) for PointInTimeRestore create mode.')
param restorePointInTime string = ''

@description('The resource identifier of the recoverable database associated with Recovery create mode.')
param recoverableDatabaseId string = ''

@description('The resource identifier of the restorable dropped database associated with Restore create mode.')
param restorableDroppedDatabaseId string = ''

@description('Specifies the time that the source database was deleted, for restore operations that require it.')
param sourceDatabaseDeletionDate string = ''

@description('The resource identifier of the source associated with restore operations across subscriptions, where supported.')
param sourceResourceId string = ''

@description('The resource identifier of the long term retention backup associated with create operation of this database.')
param longTermRetentionBackupResourceId string = ''

@description('The license type to apply for this database. LicenseIncluded if you need a license, or BasePrice if you have a license and are eligible for the Azure Hybrid Benefit.')
@allowed([
  'BasePrice'
  'LicenseIncluded'
])
param licenseType string = 'BasePrice'

@description('The storage account type to be used to store backups for this database.')
@allowed([
  'Geo'
  'GeoZone'
  'Local'
  'Zone'
])
param requestedBackupStorageRedundancy string = 'Zone'

@description('Whether this database uses the free monthly limits. Allowed on one database in a subscription.')
param useFreeLimit bool = false

@description('The behavior to apply when free monthly limits are exhausted. Allowed only when useFreeLimit is true.')
@allowed([
  'AutoPause'
  'BillOverUsage'
])
param freeLimitExhaustionBehavior string = 'AutoPause'

@description('The managed identity to use for this SQL database. Set this to UserAssigned when per-database customer-managed keys or other identity-bound features require it.')
param identity IdentityType = {
  type: 'None'
}

@description('The Azure Key Vault URI of the key to use for per-database customer-managed keys.')
param encryptionProtector string = ''

@description('Whether the database encryption protector key should rotate automatically. Set this to true only when encryptionProtector is configured.')
param encryptionProtectorAutoRotation bool = false

@description('Which log categories to enable; This defaults to `allLogs`. For array/object format, please refer to [docs](https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep#logsettings).')
param diagnosticSettingsLogsCategories array = [
  {
    categoryGroup: 'allLogs'
    enabled: true
  }
]

@description('Which Metrics categories to enable; This defaults to `AllMetrics`. For array/object format, please refer to [docs](https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep&pivots=deployment-language-bicep#metricsettings).')
param diagnosticSettingsMetricsCategories array = [
  {
    categoryGroup: 'AllMetrics'
    enabled: true
  }
]

@description('''
The tags to apply to this resource. This is an object with key/value pairs.
Example:
{
  FirstTag: myvalue
  SecondTag: another value
}
''')
param tags object = {}

@description('Whether or not this database is zone redundant, which means the replicas of this database will be spread across multiple availability zones.')
param databaseZoneRedundant bool = false

@description('Specifies the availability zone the database is pinned to. Leave empty to use platform default behavior.')
@allowed([
  ''
  '1'
  '2'
  '3'
  'NoPreference'
])
param availabilityZone string = ''

@description('''
Maintenance configuration resource ID assigned to the database. Leave empty to use SQL default maintenance behavior.
Example:
'/subscriptions/11111111-2222-3333-4444-555555555555/providers/Microsoft.Maintenance/publicMaintenanceConfigurations/SQL_westeurope_DB_1'
''')
param maintenanceConfigurationId string = ''

@description('The number of secondary replicas for high availability. Leave empty to use the service default for the selected SKU.')
param highAvailabilityReplicaCount int?

@description('Whether this database should be created as a ledger database. Leave empty to use default behavior.')
param isLedgerOn bool?

@description('The max size of the database expressed in bytes')
param maxSizeBytes int = 32 * 1024 * 1024 * 1024 // 32GB

@description('For the serverless database model, ignored for the provisioned model.Time in minutes after which database is automatically paused. A value of -1 means that automatic pause is disabled. Default is 15 minutes.')
param autoPauseDelay int = 15

@description('Minimal capacity that database will always have allocated, if not paused. To specify a decimal (0.5 0.75 ß1) value, use the json() function.')
param minCapacity string = '0.5'

@description('The sample name of the database to create.')
@allowed([
  ''
  'AdventureWorksLT'
  'WideWorldImportersStd'
  'WideWorldImportersFull'
])
param sampleName string = ''

@description('''
The state of read-only routing. If enabled, connections that have application intent set to readonly in their connection string may be routed to a readonly secondary replica in the same region. 
Not applicable to a Hyperscale database within an elastic pool.
''')
@allowed([
  'Enabled'
  'Disabled'
])
param readScaleOut string = 'Disabled'

@description('The resource identifier of the elastic pool, this should be pre-existing.')
param elasticPoolId string = ''

// ================================================= Variables =================================================
var usesElasticPool = !empty(elasticPoolId)
var usesFreeLimitAutoPauseExhaustion = useFreeLimit && freeLimitExhaustionBehavior == 'AutoPause'
var effectiveRequestedBackupStorageRedundancy = usesFreeLimitAutoPauseExhaustion ? 'Local' : requestedBackupStorageRedundancy

// ================================================= Existing Resources =================================================
@description('Fetch the SQL server to use as underlying provider for the SQL Database')
resource sqlServer 'Microsoft.Sql/servers@2025-01-01' existing = {
  name: sqlServerName
}

// ================================================= Resources =================================================
@description('Upsert the SQL database with the given parameters.')
resource sqlDatabase 'Microsoft.Sql/servers/databases@2025-01-01' = {
  parent: sqlServer
  name: sqlDatabaseName
  location: location
  tags: tags
  identity: identity
  sku: sku
  properties: {
    createMode: createMode
    collation: collation
    ...(empty(catalogCollation) ? {} : {
      catalogCollation: catalogCollation
    })
    elasticPoolId: elasticPoolId
    licenseType: licenseType
    requestedBackupStorageRedundancy: effectiveRequestedBackupStorageRedundancy
    useFreeLimit: useFreeLimit
    ...(useFreeLimit ? {
      freeLimitExhaustionBehavior: freeLimitExhaustionBehavior
    } : {})
    ...(empty(encryptionProtector) ? {} : {
      encryptionProtector: encryptionProtector
    })
    ...(empty(encryptionProtector) || !encryptionProtectorAutoRotation ? {} : {
      encryptionProtectorAutoRotation: encryptionProtectorAutoRotation
    })
    readScale: readScaleOut
    ...(usesElasticPool || empty(sampleName) ? {} : {
      sampleName: sampleName
    })
    zoneRedundant: databaseZoneRedundant
    maxSizeBytes: maxSizeBytes
    ...(usesElasticPool ? {} : {
      ...(usesFreeLimitAutoPauseExhaustion ? {} : {
        autoPauseDelay: autoPauseDelay
      })
      minCapacity: json(minCapacity)
    })
    ...(empty(availabilityZone) ? {} : {
      availabilityZone: availabilityZone
    })
    ...(empty(maintenanceConfigurationId) ? {} : {
      maintenanceConfigurationId: maintenanceConfigurationId
    })
    ...(highAvailabilityReplicaCount == null ? {} : {
      highAvailabilityReplicaCount: highAvailabilityReplicaCount
    })
    ...(isLedgerOn == null ? {} : {
      isLedgerOn: isLedgerOn
    })
    ...(empty(sourceDatabaseId) ? {} : {
      sourceDatabaseId: sourceDatabaseId
    })
    ...(empty(restorePointInTime) ? {} : {
      restorePointInTime: restorePointInTime
    })
    ...(empty(recoverableDatabaseId) ? {} : {
      recoverableDatabaseId: recoverableDatabaseId
    })
    ...(empty(restorableDroppedDatabaseId) ? {} : {
      restorableDroppedDatabaseId: restorableDroppedDatabaseId
    })
    ...(empty(sourceDatabaseDeletionDate) ? {} : {
      sourceDatabaseDeletionDate: sourceDatabaseDeletionDate
    })
    ...(empty(sourceResourceId) ? {} : {
      sourceResourceId: sourceResourceId
    })
    ...(empty(longTermRetentionBackupResourceId) ? {} : {
      longTermRetentionBackupResourceId: longTermRetentionBackupResourceId
    })
  }
}

@description('Upsert the diagnostic settings for this SQL Database.')
resource diagnosticSetting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceResourceId)) {
  name: diagnosticsName
  scope: sqlDatabase
  properties: {
    workspaceId: logAnalyticsWorkspaceResourceId
    logs: diagnosticSettingsLogsCategories
    metrics: diagnosticSettingsMetricsCategories
  }
}

@description('Output the SQL Database resource name.')
output sqlDatabase string = sqlDatabase.name
