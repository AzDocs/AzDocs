/*
.SYNOPSIS
Creating a database in an existing elastic pool in an existing SQL server
.DESCRIPTION
Creating a database in an existing elastic pool in an existing SQL server with the given specs.
.EXAMPLE
<pre>
module sql 'br:contosoregistry.azurecr.io/sql/servers/elasticpools/databases.bicep:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 61), 'db')
  params: {
    sqlServerName:sqlserver.outputs.sqlServerName
    location: location
    sqlDatabaseName: 'sqlDatabaseName'
    elasticPoolId: elasticpoolId
    maxSizeBytes: 32 * 1024 * 1024 * 1024 // 32GB
  }
}
</pre>
<p>Creates a database called sqlDatabaseName in an existing elastic pool.</p>
.LINKS
- [Bicep Microsoft.SQL servers](https://learn.microsoft.com/en-us/azure/templates/microsoft.sql/servers/databases?pivots=deployment-language-bicep)
*/

// ================================================= Parameters =================================================
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

@description('The azure resource id of the log analytics workspace to log the diagnostics to. If you set this to an empty string, logging & diagnostics will be disabled.')
@minLength(0)
param logAnalyticsWorkspaceResourceId string = ''

@description('The name of the diagnostics. This defaults to `AzurePlatformCentralizedLogging`.')
@minLength(1)
@maxLength(260)
param diagnosticsName string = 'AzurePlatformCentralizedLogging'

@description('The collation of the database. Defaults to `SQL_Latin1_General_CP1_CI_AS`. For options, please refer to [collation](https://docs.microsoft.com/en-us/sql/relational-databases/collations/collation-and-unicode-support?view=sql-server-ver16#Server-level-collations).')
param collation string = 'SQL_Latin1_General_CP1_CI_AS'

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

@description('Determines if a user assigned managed identity should be created for this SQL database.')
param createDatabaseUserAssignedManagedIdentity bool = false

@description('The name of the user assigned managed identity to create for this SQL server.')
param userAssignedManagedIdentityName string = 'id-${sqlDatabaseName}'

// ================================================= Existing Resources =================================================
@description('Fetch the SQL server to use as underlying provider for the SQL Database')
resource sqlServer 'Microsoft.Sql/servers@2023-05-01-preview' existing = {
  name: sqlServerName
}

// ================================================= Resources =================================================
resource databaseUserAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = if (createDatabaseUserAssignedManagedIdentity) {
  name: userAssignedManagedIdentityName
  location: location
}

@description('The max size of the database expressed in bytes')
param maxSizeBytes int = 32 * 1024 * 1024 * 1024 // 32GB

// LTR backup parameters
@description('''
The retention object for the long term backup retention policy. See for values the [docs](https://learn.microsoft.com/en-us/azure/azure-sql/database/long-term-retention-overview?view=azuresql).
Example:
W=0, M=3, Y=0
'The first full backup of each month is kept for three months.'
''')
param backupRetention object = {
  weeklyRetention: 'P4W'
}

// STR backup parameters
@description('''
The differential backup interval in hours. This is how many interval hours between each differential backup will be supported. This is only applicable to live databases but not dropped databases.
See [docs](https://learn.microsoft.com/en-us/azure/azure-sql/database/automated-backups-overview?view=azuresql)
''')
@allowed([
  12
  24
])
param diffBackupIntervalInHours int = 12

@description('The backup retention period in days. This is how many days Point-in-Time Restore will be supported.')
param retentionDays int = 7

@description('The resource identifier of the elastic pool, this should be pre-existing.')
param elasticPoolId string = ''

// ================================================= Resources =================================================
@description('Upsert the SQL database with the given parameters.')
resource sqlDatabase 'Microsoft.Sql/servers/databases@2023-05-01-preview' = {
  parent: sqlServer
  location: location
  name: sqlDatabaseName
  properties: {
    collation: collation
    elasticPoolId: elasticPoolId
    maxSizeBytes: maxSizeBytes
  }

  @description('Upsert the backup long term retention policies settings for this SQL Database.')
  resource longTermBackupPolicy 'backupLongTermRetentionPolicies@2022-11-01-preview' = {
    name: 'default'
    properties: backupRetention
  }

  @description('Upsert the backup short term retention policies settings for this SQL Database.')
  resource backupShortTermRetentionPolicies 'backupShortTermRetentionPolicies@2022-05-01-preview' = {
    name: 'default'
    properties: {
      diffBackupIntervalInHours: diffBackupIntervalInHours
      retentionDays: retentionDays
    }
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
