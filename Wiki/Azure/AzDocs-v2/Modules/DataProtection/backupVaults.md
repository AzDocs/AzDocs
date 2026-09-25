# backupVaults

Target Scope: resourceGroup

## User Defined Types
| Name | Type | Discriminator | Description
| -- |  -- | -- | -- |
| <a id="featureSettingsType">featureSettingsType</a>  | <pre>{<br>&nbsp;&nbsp;&nbsp;@description('Settings for cross-region restore functionality')<br>&nbsp;&nbsp;&nbsp;crossRegionRestoreSettings: {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('State of cross-region restore feature')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;state: 'Enabled' &#124; 'Disabled'<br>&nbsp;&nbsp;&nbsp;}?<br><br>&nbsp;&nbsp;&nbsp;@description('Settings for cross-subscription restore functionality')<br>&nbsp;&nbsp;&nbsp;crossSubscriptionRestoreSettings: {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('State of cross-subscription restore feature')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;state: 'Enabled' &#124; 'Disabled' &#124; 'PermanentlyDisabled'<br>&nbsp;&nbsp;&nbsp;}?<br>}<br></pre> |  |  | 
| <a id="storageSettingType">storageSettingType</a>  | <pre>{<br>&nbsp;&nbsp;&nbsp;@description('Type of the datastore for backup storage')<br>&nbsp;&nbsp;&nbsp;datastoreType: 'ArchiveStore' &#124; 'OperationalStore' &#124; 'VaultStore'<br><br>&nbsp;&nbsp;&nbsp;@description('Storage redundancy type for the backup vault')<br>&nbsp;&nbsp;&nbsp;type: 'GeoRedundant' &#124; 'LocallyRedundant' &#124; 'ZoneRedundant'<br>}<br></pre> |  |  | 
| <a id="securitySettingsType">securitySettingsType</a>  | <pre>{<br>&nbsp;&nbsp;&nbsp;@description('Customer Managed Key details of the resource')<br>&nbsp;&nbsp;&nbsp;encryptionSettings: {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('State of infrastructure encryption (double encryption)')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;infrastructureEncryption: 'Enabled' &#124; 'Disabled'<br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Managed identity configuration for Customer Managed Key (CMK)')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;kekIdentity: {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Type of managed identity for CMK access')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;identityType: 'SystemAssigned' &#124; 'UserAssigned'<br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Resource ID of the user-assigned managed identity. Required only when identityType is UserAssigned')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@minLength(1)<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;identityId: string?<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}?<br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Key Vault configuration for Customer Managed Key (CMK)')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;keyVaultProperties: {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('URI of the Customer Managed Key in Key Vault')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@minLength(1)<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;keyUri: string<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}?<br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Overall encryption state of the backup vault')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;state: 'Enabled' &#124; 'Disabled' &#124; 'Inconsistent'<br>&nbsp;&nbsp;&nbsp;}?<br><br>&nbsp;&nbsp;&nbsp;@description('Immutability Settings at vault level')<br>&nbsp;&nbsp;&nbsp;immutabilitySettings: {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Immutability state')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;state: 'Disabled' &#124; 'Locked' &#124; 'Unlocked'<br>&nbsp;&nbsp;&nbsp;}?<br><br>&nbsp;&nbsp;&nbsp;@description('Soft delete related settings')<br>&nbsp;&nbsp;&nbsp;softDeleteSettings: {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Soft delete retention duration in days')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@minValue(14)<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@maxValue(180)<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;retentionDurationInDays: int<br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('State of soft delete')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;state: 'AlwaysOn' &#124; 'Off' &#124; 'On'<br>&nbsp;&nbsp;&nbsp;}?<br>}<br></pre> |  |  | 

## Synopsis
Provisioning an Azure Data Protection Backup Vault

## Description
Provisioning an Azure Data Protection Backup Vault with comprehensive configuration options.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| alertsForAllJobFailures | string | <input type="checkbox" checked> | `'Enabled'` or `'Disabled'` | <pre></pre> | Enable Azure Monitor alerts for all job failures |
| backupVaultName | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | Name of the backup vault |
| identity | object | <input type="checkbox"> | None | <pre>{   type: 'SystemAssigned' }</pre> |  |
| featureSettings | [featureSettingsType](#featureSettingsType)? | <input type="checkbox" checked> | None | <pre></pre> | Feature settings configuration for the backup vault |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Location for all resources |
| replicatedRegions | string[] | <input type="checkbox"> | None | <pre>[]</pre> | List of replicated regions for cross-region restore |
| resourceGuardOperationRequests | string[] | <input type="checkbox"> | None | <pre>[]</pre> | Resource Guard operation requests on which LAC check will be performed |
| storageSettings | [storageSettingType](#storageSettingType)[] | <input type="checkbox" checked> | None | <pre></pre> | Storage settings configuration for the backup vault |
| securitySettings | [securitySettingsType](#securitySettingsType) | <input type="checkbox"> | None | <pre>{<br>  softDeleteSettings: {<br>    state: 'On'<br>    retentionDurationInDays: 14<br>  }<br>}</pre> | Security settings configuration for the backup vault |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | Tags to apply to resources. Example: { Environment: "Production", CostCenter: "IT", Owner: "TeamA" } |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| backupVaultId | string | The resource ID of the backup vault |
| backupVaultName | string | The name of the backup vault |
| principalId | string | The principal ID of the system assigned managed identity |

## Examples
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

## Links
- [Bicep Microsoft.DataProtection/backupVaults@2025-07-01](https://learn.microsoft.com/en-us/azure/templates/microsoft.dataprotection/2025-07-01/backupvaults?pivots=deployment-language-bicep)<br>
- [Microsoft Learn](https://learn.microsoft.com/en-us/azure/backup/backup-vault-overview)
