# backupShortTermRetentionPolicies

Target Scope: resourceGroup

## Synopsis
Configure short-term backup retention policy for an existing SQL Database.

## Description
Applies short-term retention policy settings to an existing SQL Database.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| sqlServerName | string | <input type="checkbox" checked> | Length between 1-63 | <pre></pre> | The resource name of the SQL Server containing the target database. |
| sqlDatabaseName | string | <input type="checkbox" checked> | Length between 1-128 | <pre></pre> | The name of the SQL Database to configure short-term backup retention for. |
| diffBackupIntervalInHours | int | <input type="checkbox"> | `12` or `24` | <pre>12</pre> | The differential backup interval in hours for live databases. |
| retentionDays | int | <input type="checkbox"> | Value between 7-35 | <pre>7</pre> | The short-term backup retention period in days for point-in-time restore. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| backupShortTermRetentionPolicyId | string | The resource identifier of the short-term backup retention policy resource. |

## Examples
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

## Links
- [Bicep Microsoft.SQL servers databases backupShortTermRetentionPolicies](https://learn.microsoft.com/en-us/azure/templates/microsoft.sql/servers/databases/backupshorttermretentionpolicies?pivots=deployment-language-bicep)
