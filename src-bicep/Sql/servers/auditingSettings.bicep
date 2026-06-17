/*
.SYNOPSIS
Configuring auditing settings for an existing SQL server. Destination can be set to a storage account, Azure Monitor, or both.
.DESCRIPTION
Creates or updates auditing settings and optional DevOps auditing settings on an existing Azure SQL server.
.EXAMPLE
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
.LINKS
- [Bicep Microsoft.Sql servers/auditingSettings](https://learn.microsoft.com/en-us/azure/templates/microsoft.sql/servers/auditingsettings?pivots=deployment-language-bicep)
- [Bicep Microsoft.Sql servers/devOpsAuditingSettings](https://learn.microsoft.com/en-us/azure/templates/microsoft.sql/servers/devopsauditingsettings?pivots=deployment-language-bicep)
- [Azure SQL Database Audit Write Storage Account Behind VNet Firewall](https://learn.microsoft.com/en-us/azure/azure-sql/database/audit-write-storage-account-behind-vnet-firewall?view=azuresql)
*/

// ================================================= Parameters =================================================
@description('The name of the existing SQL Server.')
@minLength(1)
@maxLength(63)
param sqlServerName string

@description('The storage endpoint used by SQL auditing settings. Example: https://mystorage.blob.core.windows.net/.')
param storageEndpoint string = ''

@description('''
The storage account access key used by SQL auditing settings. 
If state is Enabled and storageEndpoint is specified, not specifying the storageAccountAccessKey will use SQL server system-assigned managed identity to access the storage.
Prerequisites for using managed identity authentication:
1. Assign SQL Server a system-assigned or user-assigned managed identity.
2. Grant SQL Server identity access to the storage account by adding 'Storage Blob Data Contributor' RBAC role to the server identity.
''')
@secure()
param storageAccountAccessKey string = ''

@description('''
The subscription ID of the storage account used by SQL auditing settings.
Leave empty to use the current subscription context.
''')
@discriminator('type')
type storageAccountSubscriptionIdType =
  | {
    type: 'Explicit'
    value: string
  }
  | {
    type: 'Current'
  }

@description('Use Current to omit the property or Explicit to pass a storage account subscription ID.')
param storageAccountSubscriptionId storageAccountSubscriptionIdType = {
  type: 'Current'
}

@description('''
Specifies whether audit events are sent to Azure Monitor (Log Analytics). 
Set to true when SQL auditing should (also) emit to Azure Monitor.
This requires a separate diagnostic settings for SQLSecurityAuditEvents having been set on the master database.
''')
param auditingSettingsIsAzureMonitorTargetEnabled bool = true

@description('List of audit action groups to enable.')
param auditActionsAndGroups resourceInput<'Microsoft.Sql/servers/auditingsettings@2025-01-01'>.properties.auditActionsAndGroups = [
  'BATCH_COMPLETED_GROUP'
  'SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP'
  'FAILED_DATABASE_AUTHENTICATION_GROUP'
]

@description('This will enable the setting: Enable Auditing of Microsoft support operations')
param enableDevOpsAuditingSettings bool = true

@description('''
Specifies whether Managed Identity is used to access blob storage. RBAC rights for this identity must have been set on the storage account. 
When set to true, DevOps auditing settings will use managed identity to write to the storage account. 
When set to false, DevOps auditing settings will use storage account access key to write to the storage account.
''')
param devOpsAuditingIsManagedIdentityInUse bool = true

@description('Specifies the state of the audit. If state is Enabled, storageEndpoint or isAzureMonitorTargetEnabled are required.')
param state string = 'Enabled'

@description('The diagnostic settings resource name created on the SQL master database when a diagnostics destination is configured.')
@minLength(1)
@maxLength(260)
param diagnosticSettingsName string = 'AzurePlatformCentralizedLogging'

@description('Set to true to deploy diagnostic settings on the SQL master database. At least one destination must also be provided.')
param enableMasterDiagnosticSettings bool = false

@description('The resource ID of the Log Analytics workspace for SQL audit diagnostics. Leave empty to skip this destination.')
param logAnalyticsWorkspaceResourceId string = ''

@description('The resource ID of the Event Hub authorization rule for SQL audit diagnostics. Leave empty to skip this destination.')
param eventHubAuthorizationRuleId string = ''

@description('The Event Hub name for SQL audit diagnostics when eventHubAuthorizationRuleId is set. Leave empty to use the default entity in the authorization rule.')
param eventHubName string = ''

@description('The resource ID of the Storage Account for SQL audit diagnostics archival. Leave empty to skip this destination.')
param diagnosticsStorageAccountResourceId string = ''


// ================================================= Existing Resources =================================================
@description('Fetch the existing SQL server to apply auditing settings to.')
resource sqlServer 'Microsoft.Sql/servers@2025-01-01' existing = {
  name: sqlServerName
}

@description('Fetch the SQL master database to scope SQL audit diagnostic settings.')
resource masterDatabase 'Microsoft.Sql/servers/databases@2025-01-01' existing = {
  parent: sqlServer
  name: 'master'
}

// ================================================= Resources =================================================
@description('Upsert SQL server auditing settings.')
resource sqlServerAuditingSettings 'Microsoft.Sql/servers/auditingSettings@2025-01-01' = {
  parent: sqlServer
  name: 'default'
  properties: {
    auditActionsAndGroups: auditActionsAndGroups
    state: state
    isAzureMonitorTargetEnabled: auditingSettingsIsAzureMonitorTargetEnabled
    ...(empty(storageEndpoint) ? {} : {
      storageEndpoint: storageEndpoint
    })
    ...(empty(storageAccountAccessKey) ? {} : {
      storageAccountAccessKey: storageAccountAccessKey
      isManagedIdentityInUse: false
    })
    ...(storageAccountSubscriptionId.type == 'Explicit' ? {
      storageAccountSubscriptionId: storageAccountSubscriptionId.value
    } : {})
  }
}

@description('Upsert SQL server DevOps auditing settings.')
resource devOpsAuditingSettings 'Microsoft.Sql/servers/devOpsAuditingSettings@2025-01-01' = if (enableDevOpsAuditingSettings) {
  parent: sqlServer
  name: 'default'
  properties: {
    state: 'Enabled'
    isAzureMonitorTargetEnabled: auditingSettingsIsAzureMonitorTargetEnabled
    isManagedIdentityInUse: devOpsAuditingIsManagedIdentityInUse
    ...(empty(storageEndpoint) ? {} : {
      storageEndpoint: storageEndpoint
    })
    storageAccountAccessKey: devOpsAuditingIsManagedIdentityInUse ? '' : storageAccountAccessKey
    ...(storageAccountSubscriptionId.type == 'Explicit' ? {
      storageAccountSubscriptionId: storageAccountSubscriptionId.value
    } : {})
  }
}

@description('Create diagnostic settings on the SQL master database to route SQL audit events to configured destinations.')
resource sqlAuditDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableMasterDiagnosticSettings) {
  scope: masterDatabase
  name: diagnosticSettingsName
  properties: {
    ...(empty(logAnalyticsWorkspaceResourceId) ? {} : {
      workspaceId: logAnalyticsWorkspaceResourceId
    })
    ...(empty(eventHubAuthorizationRuleId) ? {} : {
      eventHubAuthorizationRuleId: eventHubAuthorizationRuleId
      ...(empty(eventHubName) ? {} : {
        eventHubName: eventHubName
      })
    })
    ...(empty(diagnosticsStorageAccountResourceId) ? {} : {
      storageAccountId: diagnosticsStorageAccountResourceId
    })
    logs: concat([
      {
        category: 'SQLSecurityAuditEvents'
        enabled: true
      }
    ], enableDevOpsAuditingSettings ? [
      {
        category: 'DevOpsOperationsAudit'
        enabled: true
      }
    ] : [])
  }
}

@description('Output the name of the SQL auditing settings resource.')
output auditingSettingsName string = sqlServerAuditingSettings.name
@description('Output the name of the SQL DevOps auditing settings resource.')
output devOpsAuditingSettingsName string = enableDevOpsAuditingSettings ? devOpsAuditingSettings.name : ''
@description('Output the name of the SQL master database diagnostic settings resource.')
output sqlAuditDiagnosticSettingsName string = enableMasterDiagnosticSettings ? sqlAuditDiagnosticSettings.name : ''
