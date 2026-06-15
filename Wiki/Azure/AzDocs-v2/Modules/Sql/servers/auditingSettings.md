# auditingSettings

Target Scope: resourceGroup

## User Defined Types
| Name | Type | Discriminator | Description
| -- |  -- | -- | -- |
| <a id="storageAccountSubscriptionIdType">storageAccountSubscriptionIdType</a>  | <pre></pre> | type | The subscription ID of the storage account used by SQL auditing settings. Leave empty to use the current subscription context. | 

## Synopsis
Configuring auditing settings for an existing SQL server. Destination can be set to a storage account, Azure Monitor, or both.

## Description
Creates or updates auditing settings and optional DevOps auditing settings on an existing Azure SQL server.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| sqlServerName | string | <input type="checkbox" checked> | Length between 1-63 | <pre></pre> | The name of the existing SQL Server. |
| storageEndpoint | string | <input type="checkbox"> | None | <pre>''</pre> | The storage endpoint used by SQL auditing settings. Example: https://mystorage.blob.core.windows.net/. |
| storageAccountAccessKey | string | <input type="checkbox"> | None | <pre>''</pre> | The storage account access key used by SQL auditing settings. <br>If state is Enabled and storageEndpoint is specified, not specifying the storageAccountAccessKey will use SQL server system-assigned managed identity to access the storage.<br>Prerequisites for using managed identity authentication:<br>1. Assign SQL Server a system-assigned or user-assigned managed identity.<br>2. Grant SQL Server identity access to the storage account by adding 'Storage Blob Data Contributor' RBAC role to the server identity. |
| storageAccountSubscriptionId | [storageAccountSubscriptionIdType](#storageAccountSubscriptionIdType) | <input type="checkbox"> | None | <pre>{<br>  type: 'Current'<br>}</pre> | Use Current to omit the property or Explicit to pass a storage account subscription ID. |
| auditingSettingsIsAzureMonitorTargetEnabled | bool | <input type="checkbox"> | None | <pre>true</pre> | Specifies whether audit events are sent to Azure Monitor (Log Analytics). <br>Set to true when SQL auditing should (also) emit to Azure Monitor.<br>This requires a separate diagnostic settings for SQLSecurityAuditEvents having been set on the master database. |
| auditActionsAndGroups | array | <input type="checkbox"> | None | <pre>[<br>  'BATCH_COMPLETED_GROUP'<br>  'SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP'<br>  'FAILED_DATABASE_AUTHENTICATION_GROUP'<br>]</pre> | List of audit action groups to enable. |
| enableDevOpsAuditingSettings | bool | <input type="checkbox"> | None | <pre>true</pre> | This will enable the setting: Enable Auditing of Microsoft support operations |
| devOpsAuditingIsManagedIdentityInUse | bool | <input type="checkbox"> | None | <pre>true</pre> | Specifies whether Managed Identity is used to access blob storage. RBAC rights for this identity must have been set on the storage account. <br>When set to true, DevOps auditing settings will use managed identity to write to the storage account. <br>When set to false, DevOps auditing settings will use storage account access key to write to the storage account. |
| state | string | <input type="checkbox"> | None | <pre>'Enabled'</pre> | Specifies the state of the audit. If state is Enabled, storageEndpoint or isAzureMonitorTargetEnabled are required. |
| diagnosticSettingsName | string | <input type="checkbox"> | Length between 1-260 | <pre>'AzurePlatformCentralizedLogging'</pre> | The diagnostic settings resource name created on the SQL master database when a diagnostics destination is configured. |
| enableMasterDiagnosticSettings | bool | <input type="checkbox"> | None | <pre>false</pre> | Set to true to deploy diagnostic settings on the SQL master database. At least one destination must also be provided. |
| logAnalyticsWorkspaceResourceId | string | <input type="checkbox"> | None | <pre>''</pre> | The resource ID of the Log Analytics workspace for SQL audit diagnostics. Leave empty to skip this destination. |
| eventHubAuthorizationRuleId | string | <input type="checkbox"> | None | <pre>''</pre> | The resource ID of the Event Hub authorization rule for SQL audit diagnostics. Leave empty to skip this destination. |
| eventHubName | string | <input type="checkbox"> | None | <pre>''</pre> | The Event Hub name for SQL audit diagnostics when eventHubAuthorizationRuleId is set. Leave empty to use the default entity in the authorization rule. |
| diagnosticsStorageAccountResourceId | string | <input type="checkbox"> | None | <pre>''</pre> | The resource ID of the Storage Account for SQL audit diagnostics archival. Leave empty to skip this destination. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| auditingSettingsName | string | Output the name of the SQL auditing settings resource. |
| devOpsAuditingSettingsName | string | Output the name of the SQL DevOps auditing settings resource. |
| sqlAuditDiagnosticSettingsName | string | Output the name of the SQL master database diagnostic settings resource. |

## Examples
<p>Storage destination example using storage account</p>
<pre>
module sqlAuditing 'br:contosoregistry.azurecr.io/sql/servers/auditingsettings.bicep:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 57), 'sqlaudit')
  params: {
    sqlServerName: sqlServerName
    storageEndpoint: vulnerabilityAssessmentStorage.outputs.storageAccountPrimaryBlobEndpoint
    storageAccountAccessKey: vulnerabilityAssessmentStorage.outputs.storageAccountPrimaryAccessKey
    auditingSettingsIsAzureMonitorTargetEnabled: false
    enableMasterDiagnosticSettings: false
  }
}
</pre>
<p>Azure Monitor destination example using Log Analytics workspace</p>
<pre>
module sqlAuditing 'br:contosoregistry.azurecr.io/sql/servers/auditingsettings.bicep:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 57), 'sqlaudit')
  params: {
    sqlServerName: sqlServerName
    auditingSettingsIsAzureMonitorTargetEnabled: true
    enableMasterDiagnosticSettings: true
    logAnalyticsWorkspaceResourceId: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-monitoring/providers/Microsoft.OperationalInsights/workspaces/law-shared'
  }
}
</pre>
<p>Configures SQL auditing settings for an existing SQL server.</p>

## Links
- [Bicep Microsoft.Sql servers/auditingSettings](https://learn.microsoft.com/en-us/azure/templates/microsoft.sql/servers/auditingsettings?pivots=deployment-language-bicep)<br>
- [Bicep Microsoft.Sql servers/devOpsAuditingSettings](https://learn.microsoft.com/en-us/azure/templates/microsoft.sql/servers/devopsauditingsettings?pivots=deployment-language-bicep)<br>
- [Azure SQL Database Audit Write Storage Account Behind VNet Firewall](https://learn.microsoft.com/en-us/azure/azure-sql/database/audit-write-storage-account-behind-vnet-firewall?view=azuresql)
