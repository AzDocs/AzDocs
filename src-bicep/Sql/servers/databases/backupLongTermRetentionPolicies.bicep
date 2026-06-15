metadata name = 'SQL Database Long-Term Backup Retention Policy'
metadata description = 'This module configures long-term backup retention policy settings for an existing Azure SQL Database.'

/*
.SYNOPSIS
Configure long-term backup retention policy for an existing SQL Database.
.DESCRIPTION
Applies long-term retention policy settings to an existing SQL Database.
.EXAMPLE
<pre>
module backupLongTermRetentionPolicies 'br:contosoregistry.azurecr.io/sql/servers/databases/backuplongtermretentionpolicies:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 61), 'db-ltr')
  params: {
    sqlServerName: 'myserver01'
    sqlDatabaseName: 'mydb01'
    weeklyRetention: 'P4W'
    monthlyRetention: 'P6M'
    yearlyRetention: 'P0Y'
    weekOfYear: 1
    timeBasedImmutability: 'Disabled'
  }
}
</pre>
<p>Configures long-term retention settings on an existing SQL Database.</p>
.LINKS
- [Bicep Microsoft.SQL servers databases backupLongTermRetentionPolicies](https://learn.microsoft.com/en-us/azure/templates/microsoft.sql/servers/databases/backuplongtermretentionpolicies?pivots=deployment-language-bicep)
*/

// ================================================= Parameters =================================================
@description('The resource name of the SQL Server containing the target database.')
@minLength(1)
@maxLength(63)
param sqlServerName string

@description('The name of the SQL Database to configure long-term backup retention for.')
@minLength(1)
@maxLength(128)
param sqlDatabaseName string

@description('The weekly retention policy for LTR backups in ISO 8601 duration format, for example P4W.')
param weeklyRetention string = 'P4W'

@description('The monthly retention policy for LTR backups in ISO 8601 duration format, for example P6M. Leave empty to omit this property.')
param monthlyRetention string = ''

@description('The yearly retention policy for LTR backups in ISO 8601 duration format, for example P1Y. Leave empty to omit this property.')
param yearlyRetention string = ''

@description('The ISO week number to take the yearly backup. Leave null to omit this property.')
@minValue(1)
@maxValue(52)
param weekOfYear int?

@allowed([
  'Disabled'
  'Enabled'
])
@description('Whether time-based immutability should be enabled for future long-term backups.')
param timeBasedImmutability string = 'Disabled'

@allowed([
  ''
  'Locked'
  'Unlocked'
])
@description('Immutability mode for future long-term backups when timeBasedImmutability is Enabled. Leave empty to omit this property.')
param timeBasedImmutabilityMode string = ''

// ================================================= Existing Resources =================================================
@description('Fetch the SQL Server to use as underlying provider for the SQL Database.')
resource sqlServer 'Microsoft.Sql/servers@2025-01-01' existing = {
  name: sqlServerName
}

@description('Fetch the SQL Database to configure long-term backup retention for.')
resource sqlDatabase 'Microsoft.Sql/servers/databases@2025-01-01' existing = {
  parent: sqlServer
  name: sqlDatabaseName
}

// ================================================= Resources =================================================
@description('Upsert long-term backup retention policy settings for this SQL Database.')
resource backupLongTermRetentionPolicy 'Microsoft.Sql/servers/databases/backupLongTermRetentionPolicies@2025-02-01-preview' = {
  parent: sqlDatabase
  name: 'default'
  properties: {
    weeklyRetention: weeklyRetention
    ...(empty(monthlyRetention) ? {} : {
      monthlyRetention: monthlyRetention
    })
    ...(empty(yearlyRetention) ? {} : {
      yearlyRetention: yearlyRetention
    })
    ...(weekOfYear == null ? {} : {
      weekOfYear: weekOfYear
    })
    timeBasedImmutability: timeBasedImmutability
    ...(timeBasedImmutability == 'Enabled' && !empty(timeBasedImmutabilityMode) ? {
      timeBasedImmutabilityMode: timeBasedImmutabilityMode
    } : {})
  }
}

// ================================================= Outputs =================================================
@description('The resource identifier of the long-term backup retention policy resource.')
output backupLongTermRetentionPolicyId string = backupLongTermRetentionPolicy.id
