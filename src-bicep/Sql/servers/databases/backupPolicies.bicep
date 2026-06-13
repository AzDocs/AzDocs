metadata name = 'SQL Database Backup Policies'
metadata description = 'This module configures short-term and long-term backup retention policies for an existing Azure SQL Database.'

/*
.SYNOPSIS
Configure backup retention policies for an existing SQL Database.
.DESCRIPTION
Applies short-term and long-term backup retention settings to an existing SQL Database.
.EXAMPLE
<pre>
module backupPolicies 'br:contosoregistry.azurecr.io/sql/servers/databases/backuppolicies:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 61), 'db-backup')
  params: {
    sqlServerName: 'myserver01'
    sqlDatabaseName: 'mydb01'
    backupRetention: {
      weeklyRetention: 'P4W'
    }
    diffBackupIntervalInHours: 12
    retentionDays: 7
  }
}
</pre>
<p>Configures short-term and long-term retention policies on an existing SQL Database.</p>
.LINKS
- [Bicep Microsoft.SQL servers databases backupLongTermRetentionPolicies](https://learn.microsoft.com/en-us/azure/templates/microsoft.sql/servers/databases/backuplongtermretentionpolicies?pivots=deployment-language-bicep)
- [Bicep Microsoft.SQL servers databases backupShortTermRetentionPolicies](https://learn.microsoft.com/en-us/azure/templates/microsoft.sql/servers/databases/backupshorttermretentionpolicies?pivots=deployment-language-bicep)
*/

// ================================================= Parameters =================================================
@description('The resource name of the SQL Server containing the target database.')
@minLength(1)
@maxLength(63)
param sqlServerName string

@description('The name of the SQL Database to configure backup policies for.')
@minLength(1)
@maxLength(128)
param sqlDatabaseName string

@description('''
The retention object for the long term backup retention policy. See values in the documentation.
Example:
W=0, M=3, Y=0
The first full backup of each month is kept for three months.
''')
param backupRetention object = {
  weeklyRetention: 'P4W'
}

@description('The differential backup interval in hours for live databases.')
@allowed([
  12
  24
])
param diffBackupIntervalInHours int = 12

@description('The short-term backup retention period in days for point-in-time restore.')
param retentionDays int = 7

// ================================================= Existing Resources =================================================
@description('Fetch the SQL Server to use as underlying provider for the SQL Database.')
resource sqlServer 'Microsoft.Sql/servers@2025-01-01' existing = {
  name: sqlServerName
}

@description('Fetch the SQL Database to configure backup policies for.')
resource sqlDatabase 'Microsoft.Sql/servers/databases@2025-01-01' existing = {
  parent: sqlServer
  name: sqlDatabaseName
}

// ================================================= Resources =================================================
@description('Upsert the backup long term retention policies settings for this SQL Database.')
resource longTermBackupPolicy 'Microsoft.Sql/servers/databases/backupLongTermRetentionPolicies@2022-11-01-preview' = {
  parent: sqlDatabase
  name: 'default'
  properties: backupRetention
}

@description('Upsert the backup short term retention policies settings for this SQL Database.')
resource backupShortTermRetentionPolicies 'Microsoft.Sql/servers/databases/backupShortTermRetentionPolicies@2022-05-01-preview' = {
  parent: sqlDatabase
  name: 'default'
  properties: {
    diffBackupIntervalInHours: diffBackupIntervalInHours
    retentionDays: retentionDays
  }
}
