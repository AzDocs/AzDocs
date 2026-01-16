/*
.SYNOPSIS
Provisioning an Azure Data Protection Backup Policy
.DESCRIPTION
Provisioning an Azure Data Protection Backup Policy with comprehensive backup and retention rules.
.KEYFEATURES
- Support for multiple datasource types (Storage Accounts, Disks, PostgreSQL, MySQL, AKS)
- Configurable backup rules with scheduling and triggers
- Advanced retention policies with lifecycle management
- Data store tier transitions (Operational, Vault, Archive)
- Flexible backup types (Full, Incremental, Differential, Log)
- Custom retention periods and deletion policies
- Schedule-based and adhoc backup triggers
- Cross-datastore copy and move operations
.EXAMPLE
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
.LINKS
- [Bicep Microsoft.DataProtection/backupVaults/backupPolicies@2025-07-01](https://learn.microsoft.com/en-us/azure/templates/microsoft.dataprotection/2025-07-01/backupvaults/backuppolicies?pivots=deployment-language-bicep)
- [Microsoft Learn](https://learn.microsoft.com/en-us/azure/backup/backup-azure-database-postgresql-flex)
*/

// ================================================= Parameters =================================================
@description('Name of the backup vault where the policy will be created')
@minLength(1)
param backupVaultName string

@description('Name of the backup policy')
@minLength(1)
param backupPolicyName string

@allowed([
  'Microsoft.Storage/storageAccounts/blobServices'
  'Microsoft.Storage/storageAccounts/fileServices'
  'Microsoft.Compute/disks'
  'Microsoft.DBforPostgreSQL/flexibleServers'
  'Microsoft.DBforMySQL/flexibleServers'
  'Microsoft.ContainerService/managedClusters'
  'Microsoft.DBforPostgreSQL/servers'
])
@description('Type of datasources this policy will protect. Common values: Microsoft.Storage/storageAccounts/blobServices, Microsoft.Compute/disks, Microsoft.DBforPostgreSQL/flexibleServers')
param datasourceTypes string[]

@description('Policy rules that define backup and retention behavior. Can contain AzureBackupRule and AzureRetentionRule objects')
param policyRules policyRuleType[] = []

// ================================================= Types =====================================================

@description('''
Policy rule type for Azure Data Protection backup policies.
Supports both AzureBackupRule and AzureRetentionRule objects based on API version 2025-07-01.

AzureBackupRule: Defines backup behavior including schedule, triggers, and data stores
AzureRetentionRule: Defines retention behavior including lifecycle and deletion options
''')
type policyRuleType = {
  @description('The name of the policy rule (e.g., "BackupRule", "Default", "Weekly", "Monthly", "Yearly")')
  name: string

  @description('The type of policy rule - must be either AzureBackupRule or AzureRetentionRule')
  objectType: 'AzureBackupRule' | 'AzureRetentionRule'

  // AzureBackupRule specific properties (conditional based on objectType)
  @description('Backup parameters - required when objectType is AzureBackupRule')
  backupParameters: {
    @description('The type of backup (Discrete, Full, Incremental, Differential, Log, CopyOnlyFull)')
    backupType: string
    @description('Object type - must be AzureBackupParams')
    objectType: 'AzureBackupParams'
  }?

  @description('Data store configuration - required when objectType is AzureBackupRule')
  dataStore: {
    @description('Type of datastore (OperationalStore, VaultStore, ArchiveStore)')
    dataStoreType: 'OperationalStore' | 'VaultStore' | 'ArchiveStore'
    @description('Object type - must be DataStoreInfoBase')
    objectType: 'DataStoreInfoBase'
  }?

  @description('Trigger configuration for backup scheduling - required when objectType is AzureBackupRule')
  trigger: {
    @description('Object type for trigger context')
    objectType: 'ScheduleBasedTriggerContext' | 'AdhocBasedTriggerContext'
    @description('Backup schedule configuration - required for ScheduleBasedTriggerContext')
    schedule: {
      @description('Repeating time intervals in ISO 8601 format')
      repeatingTimeIntervals: string[]
      @description('Time zone for the schedule')
      timeZone: string?
    }?
    @description('Tagging criteria for backup retention and scheduling')
    taggingCriteria: array?
  }?

  // AzureRetentionRule specific properties (conditional based on objectType)
  @description('Whether this is the default retention rule - required when objectType is AzureRetentionRule')
  isDefault: bool?

  @description('Lifecycle rules for retention - required when objectType is AzureRetentionRule')
  lifecycles: {
    @description('Delete configuration after specified duration')
    deleteAfter: {
      @description('Duration of retention in ISO 8601 format')
      duration: string
      @description('Object type - must be AbsoluteDeleteOption')
      objectType: 'AbsoluteDeleteOption'
    }
    @description('Source data store configuration')
    sourceDataStore: {
      @description('Type of datastore (OperationalStore, VaultStore, ArchiveStore)')
      dataStoreType: 'OperationalStore' | 'VaultStore' | 'ArchiveStore'
      @description('Object type - must be DataStoreInfoBase')
      objectType: 'DataStoreInfoBase'
    }
    @description('Target data store copy settings for tier transitions')
    targetDataStoreCopySettings: {
      @description('Copy configuration')
      copyAfter: {
        @description('Object type for copy option')
        objectType: 'CopyOnExpiryOption' | 'CustomCopyOption' | 'ImmediateCopyOption'
        @description('Duration for custom copy option')
        duration: string?
      }
      @description('Target data store configuration')
      dataStore: {
        @description('Type of datastore (OperationalStore, VaultStore, ArchiveStore)')
        dataStoreType: 'OperationalStore' | 'VaultStore' | 'ArchiveStore'
        @description('Object type - must be DataStoreInfoBase')
        objectType: 'DataStoreInfoBase'
      }
    }[]?
  }[]?
}
resource backupVault 'Microsoft.DataProtection/backupVaults@2025-07-01' existing = {
  name: backupVaultName
}

resource backupPolicy 'Microsoft.DataProtection/backupVaults/backupPolicies@2025-07-01' = {
  parent: backupVault
  name: backupPolicyName
  properties: {
    datasourceTypes: datasourceTypes
    objectType: 'BackupPolicy'
    policyRules: policyRules
  }
}

// ================================================= Outputs =================================================
@description('The resource ID of the backup policy')
output backupPolicyId string = backupPolicy.id

@description('The name of the backup policy')
output backupPolicyName string = backupPolicy.name
