# backupLongTermRetentionPolicies

Target Scope: resourceGroup

## Synopsis
Configure long-term backup retention policy for an existing SQL Database.

## Description
Applies long-term retention policy settings to an existing SQL Database.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| sqlServerName | string | <input type="checkbox" checked> | Length between 1-63 | <pre></pre> | The resource name of the SQL Server containing the target database. |
| sqlDatabaseName | string | <input type="checkbox" checked> | Length between 1-128 | <pre></pre> | The name of the SQL Database to configure long-term backup retention for. |
| weeklyRetention | string | <input type="checkbox"> | None | <pre>'P4W'</pre> | The weekly retention policy for LTR backups in ISO 8601 duration format, for example P4W. |
| monthlyRetention | string | <input type="checkbox"> | None | <pre>''</pre> | The monthly retention policy for LTR backups in ISO 8601 duration format, for example P6M. Leave empty to omit this property. |
| yearlyRetention | string | <input type="checkbox"> | None | <pre>''</pre> | The yearly retention policy for LTR backups in ISO 8601 duration format, for example P1Y. Leave empty to omit this property. |
| weekOfYear | int? | <input type="checkbox" checked> | Value between 1-52 | <pre></pre> | The ISO week number to take the yearly backup. Leave null to omit this property. |
| timeBasedImmutability | string | <input type="checkbox"> | `'Disabled'` or `'Enabled'` | <pre>'Disabled'</pre> | Whether time-based immutability should be enabled for future long-term backups. |
| timeBasedImmutabilityMode | string | <input type="checkbox"> | `''` or `'Locked'` or `'Unlocked'` | <pre>''</pre> | Immutability mode for future long-term backups when timeBasedImmutability is Enabled. Leave empty to omit this property. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| backupLongTermRetentionPolicyId | string | The resource identifier of the long-term backup retention policy resource. |

## Examples
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

## Links
- [Bicep Microsoft.SQL servers databases backupLongTermRetentionPolicies](https://learn.microsoft.com/en-us/azure/templates/microsoft.sql/servers/databases/backuplongtermretentionpolicies?pivots=deployment-language-bicep)
