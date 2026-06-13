# SQL Database Backup Policies module

## Description

This module configures short-term and long-term backup retention policies for an existing Azure SQL Database.

## Parameters

| Name | Type | Description |
| --- | --- | --- |
| `sqlServerName` | string | The resource name of the SQL Server containing the target database. |
| `sqlDatabaseName` | string | The name of the SQL Database to configure backup policies for. |
| `backupRetention` | object | Retention object for the long-term backup retention policy. |
| `diffBackupIntervalInHours` | int | Differential backup interval in hours (12 or 24). |
| `retentionDays` | int | Short-term backup retention period in days. |

## Usage

```bicep
module backupPolicies 'br:azdocs/sql/servers/databases/backuppolicies:latest' = {
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
```
