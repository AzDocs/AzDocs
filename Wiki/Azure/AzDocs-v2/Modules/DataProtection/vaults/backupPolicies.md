# backupPolicies

Target Scope: resourceGroup

## User Defined Types
| Name | Type | Discriminator | Description
| -- |  -- | -- | -- |
| <a id="policyRuleType">policyRuleType</a>  | <pre>{</pre> |  | Policy rule type for Azure Data Protection backup policies. Supports both AzureBackupRule and AzureRetentionRule objects based on API version 2025-07-01.  AzureBackupRule: Defines backup behavior including schedule, triggers, and data stores AzureRetentionRule: Defines retention behavior including lifecycle and deletion options | 

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
| policyRules | policyRuleType[] | <input type="checkbox"> | None | <pre>[]</pre> | Policy rules that define backup and retention behavior. Can contain AzureBackupRule and AzureRetentionRule objects |

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
