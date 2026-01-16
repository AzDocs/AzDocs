/*
.SYNOPSIS
Provisioning an Azure Data Protection Backup Vault
.DESCRIPTION
Provisioning an Azure Data Protection Backup Vault with comprehensive configuration options.
.KEYFEATURES
- Support for cross-region restore functionality
- Cross-subscription restore capabilities
- Configurable storage settings with multiple redundancy options
- Advanced security settings including encryption and soft delete
- Monitoring and alerting integration
- Immutability settings for enhanced data protection
- Resource Guard integration for enhanced security
- Managed identity support for secure operations
.EXAMPLE
<pre>
module backupVault 'br:contosoregistry.azurecr.io/dataprotection/backupvaults:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 48), 'backupvaults')
  params: {
    alertsForAllJobFailures: alertsForAllJobFailures
    backupVaultName: backupVaultName
    featureSettings: featureSettings
    identity: identity
    location: location
    replicatedRegions: replicatedRegions
    resourceGuardOperationRequests: resourceGuardOperationRequests
    securitySettings: securitySettings
    storageSettings: storageSettings
    tags: tags
  }
}
</pre>
<p>Provisioning an Azure Data Protection Backup Vault with advanced security and monitoring features</p>
.LINKS
- [Bicep Microsoft.DataProtection/backupVaults@2025-07-01](https://learn.microsoft.com/en-us/azure/templates/microsoft.dataprotection/2025-07-01/backupvaults?pivots=deployment-language-bicep)
- [Microsoft Learn](https://learn.microsoft.com/en-us/azure/backup/backup-vault-overview)
*/

// ================================================= Parameters =================================================
@description('Enable Azure Monitor alerts for all job failures')
@allowed([
  'Enabled'
  'Disabled'
])
param alertsForAllJobFailures string

@description('Name of the backup vault')
@minLength(1)
param backupVaultName string

@description('''Managed identity configuration for the backup vault. Supports `SystemAssigned, UserAssigned, SystemAssigned,UserAssigned or None`.

Example: { type: "SystemAssigned" } or { type: "UserAssigned", userAssignedIdentities: { "/subscriptions/sub-id/resourceGroups/rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/myIdentity": {} } }''')
param identity object = {
  type: 'SystemAssigned'
}
@description('Feature settings configuration for the backup vault')
param featureSettings featureSettingsType?

@description('Location for all resources')
param location string = resourceGroup().location

@description('List of replicated regions for cross-region restore')
param replicatedRegions string[] = []

@description('Resource Guard operation requests on which LAC check will be performed')
param resourceGuardOperationRequests string[] = []

@description('Storage settings configuration for the backup vault')
param storageSettings storageSettingType[]

@description('Security settings configuration for the backup vault')
param securitySettings securitySettingsType = {
  softDeleteSettings: {
    state: 'On'
    retentionDurationInDays: 14
  }
}

@description('Tags to apply to resources. Example: { Environment: "Production", CostCenter: "IT", Owner: "TeamA" }')
param tags object = {}

// ================================================= Custom Types ==============================================
type featureSettingsType = {
  @description('Settings for cross-region restore functionality')
  crossRegionRestoreSettings: {
    @description('State of cross-region restore feature')
    state: 'Enabled' | 'Disabled'
  }?

  @description('Settings for cross-subscription restore functionality')
  crossSubscriptionRestoreSettings: {
    @description('State of cross-subscription restore feature')
    state: 'Enabled' | 'Disabled' | 'PermanentlyDisabled'
  }?
}

type storageSettingType = {
  @description('Type of the datastore for backup storage')
  datastoreType: 'ArchiveStore' | 'OperationalStore' | 'VaultStore'

  @description('Storage redundancy type for the backup vault')
  type: 'GeoRedundant' | 'LocallyRedundant' | 'ZoneRedundant'
}

type securitySettingsType = {
  @description('Customer Managed Key details of the resource')
  encryptionSettings: {
    @description('State of infrastructure encryption (double encryption)')
    infrastructureEncryption: 'Enabled' | 'Disabled'

    @description('Managed identity configuration for Customer Managed Key (CMK)')
    kekIdentity: {
      @description('Type of managed identity for CMK access')
      identityType: 'SystemAssigned' | 'UserAssigned'

      @description('Resource ID of the user-assigned managed identity. Required only when identityType is UserAssigned')
      @minLength(1)
      identityId: string?
    }?

    @description('Key Vault configuration for Customer Managed Key (CMK)')
    keyVaultProperties: {
      @description('URI of the Customer Managed Key in Key Vault')
      @minLength(1)
      keyUri: string
    }?

    @description('Overall encryption state of the backup vault')
    state: 'Enabled' | 'Disabled' | 'Inconsistent'
  }?

  @description('Immutability Settings at vault level')
  immutabilitySettings: {
    @description('Immutability state')
    state: 'Disabled' | 'Locked' | 'Unlocked'
  }?

  @description('Soft delete related settings')
  softDeleteSettings: {
    @description('Soft delete retention duration in days')
    @minValue(14)
    @maxValue(180)
    retentionDurationInDays: int

    @description('State of soft delete')
    state: 'AlwaysOn' | 'Off' | 'On'
  }?
}

// ================================================= Resources =================================================
resource backupVault 'Microsoft.DataProtection/backupVaults@2025-07-01' = {
  name: backupVaultName
  location: location
  tags: tags
  identity: identity
  properties: {
    featureSettings: featureSettings
    monitoringSettings: {
      azureMonitorAlertSettings: {
        alertsForAllJobFailures: alertsForAllJobFailures
      }
    }
    replicatedRegions: replicatedRegions
    resourceGuardOperationRequests: resourceGuardOperationRequests
    storageSettings: storageSettings
    securitySettings: securitySettings
  }
}

// ================================================= Outputs =================================================
@description('The resource ID of the backup vault')
output backupVaultId string = backupVault.id

@description('The name of the backup vault')
output backupVaultName string = backupVault.name

@description('The principal ID of the system assigned managed identity')
output principalId string = backupVault.identity.principalId
