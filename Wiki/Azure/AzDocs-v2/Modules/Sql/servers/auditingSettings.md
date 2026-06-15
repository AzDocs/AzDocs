# auditingSettings

Target Scope: resourceGroup

## Synopsis
Configuring auditing settings for an existing SQL server

## Description
Creates or updates auditing settings and optional DevOps auditing settings on an existing Azure SQL server.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| sqlServerName | string | <input type="checkbox" checked> | Length between 1-63 | <pre></pre> | The name of the existing SQL Server. |
| storageEndpoint | string | <input type="checkbox" checked> | None | <pre></pre> | The storage endpoint used by SQL auditing settings. Example: https://mystorage.blob.core.windows.net/. |
| auditingSettingsIsAzureMonitorTargetEnabled | bool | <input type="checkbox"> | None | <pre>true</pre> | Specifies whether audit events are sent to Azure Monitor. |
| auditActionsAndGroups | array | <input type="checkbox"> | None | <pre>[ 'BATCH_COMPLETED_GROUP', 'SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP', 'FAILED_DATABASE_AUTHENTICATION_GROUP' ]</pre> | List of audit action groups to enable. |
| enableDevOpsAuditingSettings | bool | <input type="checkbox"> | None | <pre>true</pre> | Deploy DevOps auditing settings in addition to SQL auditing settings. |
| devOpsAuditingIsManagedIdentityInUse | bool | <input type="checkbox"> | None | <pre>true</pre> | Specifies whether managed identity is used by DevOps auditing settings. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| auditingSettingsName | string | Output the name of the SQL auditing settings resource. |
| devOpsAuditingSettingsName | string | Output the name of the SQL DevOps auditing settings resource. |

## Examples
<pre>
module sqlAuditing 'br:contosoregistry.azurecr.io/sql/servers/auditingsettings.bicep:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 57), 'sqlaudit')
  params: {
    sqlServerName: sqlServerName
    storageEndpoint: vulnerabilityAssessmentStorage.outputs.storageAccountPrimaryBlobEndpoint
    auditingSettingsIsAzureMonitorTargetEnabled: true
  }
}
</pre>
<p>Configures SQL auditing settings for an existing SQL server.</p>

## Links
- [Bicep Microsoft.Sql servers/auditingSettings](https://learn.microsoft.com/en-us/azure/templates/microsoft.sql/servers/auditingsettings?pivots=deployment-language-bicep)
- [Bicep Microsoft.Sql servers/devOpsAuditingSettings](https://learn.microsoft.com/en-us/azure/templates/microsoft.sql/servers/devopsauditingsettings?pivots=deployment-language-bicep)
