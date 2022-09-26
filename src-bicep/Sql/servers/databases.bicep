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
param logAnalyticsWorkspaceResourceId string

@description('The name of the diagnostics. This defaults to `AzurePlatformCentralizedLogging`.')
@minLength(1)
@maxLength(260)
param diagnosticsName string = 'AzurePlatformCentralizedLogging'

@description('The SKU object to use for this SQL Database. Defaults to a GP_Gen5 with capacity 2 sku. For the object format, refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.sql/servers/databases?tabs=bicep#sku.')
param sku object = {
  name: 'GP_Gen5'
  tier: 'GeneralPurpose'
  family: 'Gen5'
  capacity: 2
}

@description('The collation of the database. Defaults to `SQL_Latin1_General_CP1_CI_AS`. For options, please refer to https://docs.microsoft.com/en-us/sql/relational-databases/collations/collation-and-unicode-support?view=sql-server-ver16#Server-level-collations.')
param collation string = 'SQL_Latin1_General_CP1_CI_AS'

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

@description('Which log categories to enable; This defaults to `allLogs`. For array/object format, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep#logsettings.')
param diagnosticSettingsLogsCategories array = [
  {
    categoryGroup: 'allLogs'
    enabled: true
  }
]

@description('Which Metrics categories to enable; This defaults to `AllMetrics`. For array/object format, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep&pivots=deployment-language-bicep#metricsettings')
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

@description('Fetch the SQL server to use as underlying provider for the SQL Database')
resource sqlServer 'Microsoft.Sql/servers@2021-11-01-preview' existing = {
  name: sqlServerName
}

@description('Upsert the SQL database with the given parameters.')
resource sqlDatabase 'Microsoft.Sql/servers/databases@2021-11-01-preview' = {
  parent: sqlServer
  name: sqlDatabaseName
  location: location
  tags: tags
  sku: sku
  properties: {
    collation: collation
    licenseType: licenseType
    requestedBackupStorageRedundancy: requestedBackupStorageRedundancy
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
