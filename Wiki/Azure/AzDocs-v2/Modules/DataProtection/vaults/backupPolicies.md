# backupPolicies

Target Scope: resourceGroup

## User Defined Types
| Name | Type | Discriminator | Description
| -- |  -- | -- | -- |
| <a id="policyRuleType">policyRuleType</a>  | <pre>{<br>&nbsp;&nbsp;&nbsp;@description('The name of the policy rule (e.g., "BackupRule", "Default", "Weekly", "Monthly", "Yearly")')<br>&nbsp;&nbsp;&nbsp;name: string<br><br>&nbsp;&nbsp;&nbsp;@description('The type of policy rule - must be either AzureBackupRule or AzureRetentionRule')<br>&nbsp;&nbsp;&nbsp;objectType: 'AzureBackupRule' &#124; 'AzureRetentionRule'<br><br>&nbsp;&nbsp;&nbsp;// AzureBackupRule specific properties (conditional based on objectType)<br>&nbsp;&nbsp;&nbsp;@description('Backup parameters - required when objectType is AzureBackupRule')<br>&nbsp;&nbsp;&nbsp;backupParameters: {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('The type of backup (Discrete, Full, Incremental, Differential, Log, CopyOnlyFull)')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;backupType: string<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Object type - must be AzureBackupParams')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;objectType: 'AzureBackupParams'<br>&nbsp;&nbsp;&nbsp;}?<br><br>&nbsp;&nbsp;&nbsp;@description('Data store configuration - required when objectType is AzureBackupRule')<br>&nbsp;&nbsp;&nbsp;dataStore: {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Type of datastore (OperationalStore, VaultStore, ArchiveStore)')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;dataStoreType: 'OperationalStore' &#124; 'VaultStore' &#124; 'ArchiveStore'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Object type - must be DataStoreInfoBase')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;objectType: 'DataStoreInfoBase'<br>&nbsp;&nbsp;&nbsp;}?<br><br>&nbsp;&nbsp;&nbsp;@description('Trigger configuration for backup scheduling - required when objectType is AzureBackupRule')<br>&nbsp;&nbsp;&nbsp;trigger: {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Object type for trigger context')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;objectType: 'ScheduleBasedTriggerContext' &#124; 'AdhocBasedTriggerContext'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Backup schedule configuration - required for ScheduleBasedTriggerContext')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;schedule: {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Repeating time intervals in ISO 8601 format')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;repeatingTimeIntervals: string[]<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Time zone for the schedule')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;timeZone: string?<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}?<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Tagging criteria for backup retention and scheduling')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;taggingCriteria: array?<br>&nbsp;&nbsp;&nbsp;}?<br><br>&nbsp;&nbsp;&nbsp;// AzureRetentionRule specific properties (conditional based on objectType)<br>&nbsp;&nbsp;&nbsp;@description('Whether this is the default retention rule - required when objectType is AzureRetentionRule')<br>&nbsp;&nbsp;&nbsp;isDefault: bool?<br><br>&nbsp;&nbsp;&nbsp;@description('Lifecycle rules for retention - required when objectType is AzureRetentionRule')<br>&nbsp;&nbsp;&nbsp;lifecycles: {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Delete configuration after specified duration')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;deleteAfter: {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Duration of retention in ISO 8601 format')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;duration: string<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Object type - must be AbsoluteDeleteOption')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;objectType: 'AbsoluteDeleteOption'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Source data store configuration')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;sourceDataStore: {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Type of datastore (OperationalStore, VaultStore, ArchiveStore)')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;dataStoreType: 'OperationalStore' &#124; 'VaultStore' &#124; 'ArchiveStore'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Object type - must be DataStoreInfoBase')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;objectType: 'DataStoreInfoBase'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Target data store copy settings for tier transitions')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;targetDataStoreCopySettings: {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Copy configuration')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;copyAfter: {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Object type for copy option')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;objectType: 'CopyOnExpiryOption' &#124; 'CustomCopyOption' &#124; 'ImmediateCopyOption'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Duration for custom copy option')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;duration: string?<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Target data store configuration')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;dataStore: {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Type of datastore (OperationalStore, VaultStore, ArchiveStore)')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;dataStoreType: 'OperationalStore' &#124; 'VaultStore' &#124; 'ArchiveStore'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Object type - must be DataStoreInfoBase')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;objectType: 'DataStoreInfoBase'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}[]?<br>&nbsp;&nbsp;&nbsp;}[]?<br>}</pre> |  | Policy rule type for Azure Data Protection backup policies. Supports both AzureBackupRule and AzureRetentionRule objects based on API version 2025-07-01.  AzureBackupRule: Defines backup behavior including schedule, triggers, and data stores AzureRetentionRule: Defines retention behavior including lifecycle and deletion options | 

## Synopsis
Provisioning an Azure Data Protection Backup Policy

## Description
Provisioning an Azure Data Protection Backup Policy with comprehensive backup and retention rules.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| backupVaultName | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | Name of the backup vault where the policy will be created |
| backupPolicyName | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | Name of the backup policy |
| datasourceTypes | string[] | <input type="checkbox" checked> | `'Microsoft.Storage/storageAccounts/blobServices'` or `'Microsoft.Storage/storageAccounts/fileServices'` or `'Microsoft.Compute/disks'` or `'Microsoft.DBforPostgreSQL/flexibleServers'` or `'Microsoft.DBforMySQL/flexibleServers'` or `'Microsoft.ContainerService/managedClusters'` or `'Microsoft.DBforPostgreSQL/servers'` | <pre></pre> | Type of datasources this policy will protect. Common values: Microsoft.Storage/storageAccounts/blobServices, Microsoft.Compute/disks, Microsoft.DBforPostgreSQL/flexibleServers |
| policyRules | [policyRuleType](#policyRuleType)[] | <input type="checkbox"> | None | <pre>[]</pre> | Policy rules that define backup and retention behavior. Can contain AzureBackupRule and AzureRetentionRule objects |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| backupPolicyId | string | The resource ID of the backup policy |
| backupPolicyName | string | The name of the backup policy |

## Examples
<pre>
module backupPolicy 'br:contosoregistry.azurecr.io/dataprotection/vaults/backuppolicies:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 48), 'backuppolicies')
  params: {
    backupVaultName: backupVaultName
    backupPolicyName: backupPolicyName
    datasourceTypes: [
      'Microsoft.Storage/storageAccounts/blobServices'
      'Microsoft.Compute/disks'
    ]
    policyRules: [
      {
        name: 'BackupRule'
        objectType: 'AzureBackupRule'
        backupParameters: {
          backupType: 'Full'
          objectType: 'AzureBackupParams'
        }
        dataStore: {
          dataStoreType: 'VaultStore'
          objectType: 'DataStoreInfoBase'
        }
        trigger: {
          objectType: 'ScheduleBasedTriggerContext'
          schedule: {
            repeatingTimeIntervals: ['R/2024-01-01T00:00:00+00:00/P1D']
          }
        }
      }
    ]
  }
}
</pre>
<p>Provisioning an Azure Data Protection Backup Policy with advanced backup and retention configurations</p>

## Links
- [Bicep Microsoft.DataProtection/backupVaults/backupPolicies@2025-07-01](https://learn.microsoft.com/en-us/azure/templates/microsoft.dataprotection/2025-07-01/backupvaults/backuppolicies?pivots=deployment-language-bicep)<br>
- [Microsoft Learn](https://learn.microsoft.com/en-us/azure/backup/backup-azure-database-postgresql-flex)
