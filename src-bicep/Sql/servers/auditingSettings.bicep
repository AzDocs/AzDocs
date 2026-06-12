/*
.SYNOPSIS
Configuring auditing settings for an existing SQL server.
.DESCRIPTION
Creates or updates auditing settings and optional DevOps auditing settings on an existing Azure SQL server.
.EXAMPLE
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
.LINKS
- [Bicep Microsoft.Sql servers/auditingSettings](https://learn.microsoft.com/en-us/azure/templates/microsoft.sql/servers/auditingsettings?pivots=deployment-language-bicep)
- [Bicep Microsoft.Sql servers/devOpsAuditingSettings](https://learn.microsoft.com/en-us/azure/templates/microsoft.sql/servers/devopsauditingsettings?pivots=deployment-language-bicep)
*/

// ================================================= Parameters =================================================
@description('The name of the existing SQL Server.')
@minLength(1)
@maxLength(63)
param sqlServerName string

@description('The storage endpoint used by SQL auditing settings. Example: https://mystorage.blob.core.windows.net/.')
param storageEndpoint string

@description('Specifies whether audit events are sent to Azure Monitor.')
param auditingSettingsIsAzureMonitorTargetEnabled bool = true

@description('List of audit action groups to enable.')
param auditActionsAndGroups array = [
  'BATCH_COMPLETED_GROUP'
  'SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP'
  'FAILED_DATABASE_AUTHENTICATION_GROUP'
]

@description('Deploy DevOps auditing settings in addition to SQL auditing settings.')
param enableDevOpsAuditingSettings bool = true

@description('Specifies whether managed identity is used by DevOps auditing settings.')
param devOpsAuditingIsManagedIdentityInUse bool = true

// ================================================= Existing Resources =================================================
@description('Fetch the existing SQL server to apply auditing settings to.')
resource sqlServer 'Microsoft.Sql/servers@2025-01-01' existing = {
  name: sqlServerName
}

// ================================================= Resources =================================================
@description('Upsert SQL server auditing settings.')
resource sqlServerAuditingSettings 'Microsoft.Sql/servers/auditingSettings@2025-01-01' = {
  parent: sqlServer
  name: 'default'
  properties: {
    auditActionsAndGroups: auditActionsAndGroups
    state: 'Enabled'
    isAzureMonitorTargetEnabled: auditingSettingsIsAzureMonitorTargetEnabled
    storageEndpoint: storageEndpoint
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
    storageEndpoint: storageEndpoint
  }
}

@description('Output the name of the SQL auditing settings resource.')
output auditingSettingsName string = sqlServerAuditingSettings.name
@description('Output the name of the SQL DevOps auditing settings resource.')
output devOpsAuditingSettingsName string = enableDevOpsAuditingSettings ? devOpsAuditingSettings.name : ''
