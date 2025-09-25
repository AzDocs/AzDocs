# backupVaults

Target Scope: resourceGroup

## User Defined Types
| Name | Type | Discriminator | Description
| -- |  -- | -- | -- |
| <a id="featureSettingsType">featureSettingsType</a>  | <pre>{</pre> |  |  | 
| <a id="storageSettingType">storageSettingType</a>  | <pre>{</pre> |  |  | 
| <a id="securitySettingsType">securitySettingsType</a>  | <pre>{</pre> |  |  | 

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
| featureSettings | featureSettingsType? | <input type="checkbox" checked> | None | <pre></pre> | Feature settings configuration for the backup vault |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Location for all resources |
| replicatedRegions | string[] | <input type="checkbox"> | None | <pre>[]</pre> | List of replicated regions for cross-region restore |
| resourceGuardOperationRequests | string[] | <input type="checkbox"> | None | <pre>[]</pre> | Resource Guard operation requests on which LAC check will be performed |
| storageSettings | storageSettingType[] | <input type="checkbox" checked> | None | <pre></pre> | Storage settings configuration for the backup vault |
| securitySettings | securitySettingsType | <input type="checkbox"> | None | <pre>{<br>  softDeleteSettings: {<br>    state: 'On'<br>    retentionDurationInDays: 14<br>  }<br>}</pre> | Security settings configuration for the backup vault |
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
