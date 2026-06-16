metadata name = 'SQL Database Short-Term Backup Retention Policy'
metadata description = 'This module configures short-term backup retention policy settings for an existing Azure SQL Database.'

/*
.SYNOPSIS
Configure short-term backup retention policy for an existing SQL Database.
.DESCRIPTION
Applies short-term retention policy settings to an existing SQL Database.
.EXAMPLE
<pre>
module backupShortTermRetentionPolicies 'br:contosoregistry.azurecr.io/sql/servers/databases/backupshorttermretentionpolicies:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 61), 'db-str')
  params: {
    sqlServerName: 'myserver01'
    sqlDatabaseName: 'mydb01'
    diffBackupIntervalInHours: 12
    retentionDays: 7
  }
}
</pre>
<p>Configures short-term retention settings on an existing SQL Database.</p>
.LINKS
- [Bicep Microsoft.SQL servers databases backupShortTermRetentionPolicies](https://learn.microsoft.com/en-us/azure/templates/microsoft.sql/servers/databases/backupshorttermretentionpolicies?pivots=deployment-language-bicep)
*/

// ================================================= Parameters =================================================
@description('The resource name of the SQL Server containing the target database.')
@minLength(1)
@maxLength(63)
param sqlServerName string

@description('The name of the SQL Database to configure short-term backup retention for.')
@minLength(1)
@maxLength(128)
param sqlDatabaseName string

@description('The differential backup interval in hours for live databases.')
@allowed([
  12
  24
])
param diffBackupIntervalInHours int = 12

@description('The short-term backup retention period in days for point-in-time restore.')
@minValue(7)
@maxValue(35)
param retentionDays int = 7

// ================================================= Existing Resources =================================================
@description('Fetch the SQL Server to use as underlying provider for the SQL Database.')
resource sqlServer 'Microsoft.Sql/servers@2025-01-01' existing = {
  name: sqlServerName
}

@description('Fetch the SQL Database to configure short-term backup retention for.')
resource sqlDatabase 'Microsoft.Sql/servers/databases@2025-01-01' existing = {
  parent: sqlServer
  name: sqlDatabaseName
}

// ================================================= Resources =================================================
@description('Upsert short-term backup retention policy settings for this SQL Database.')
resource backupShortTermRetentionPolicy 'Microsoft.Sql/servers/databases/backupShortTermRetentionPolicies@2025-02-01-preview' = {
  parent: sqlDatabase
  name: 'default'
  properties: {
    diffBackupIntervalInHours: diffBackupIntervalInHours
    retentionDays: retentionDays
  }
}

// ================================================= Outputs =================================================
@description('The resource identifier of the short-term backup retention policy resource.')
output backupShortTermRetentionPolicyId string = backupShortTermRetentionPolicy.id
