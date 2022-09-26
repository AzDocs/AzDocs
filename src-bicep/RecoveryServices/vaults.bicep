@description('Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location.')
param location string = resourceGroup().location

@description('''
The tags to apply to this resource. This is an object with key/value pairs.
Example:
{
  FirstTag: myvalue
  SecondTag: another value
}
''')
param tags object = {}

@description('''
The name of the recovery services vault to create.
The Azure Recovery Services vault includes Azure Backup and Site Recovery, two services that let you to secure your data outside of your own data center.
''')
@minLength(2)
@maxLength(50)
param recoveryServicesVaultName string

@description('''
Define the sku you want to use for this Recovery Services vault. For formatting & options, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.recoveryservices/vaults?pivots=deployment-language-bicep.
Quick examples:
Among others, options are:
`capacity`: capacity for the recovery vault services sku.
`family`: family for the recovery vault services.
`name`: name for the recovery vault services sku.
`size`: size for the recovery vault services sku.
`tier`: tier for the recovery vault services sku.
''')
param recoveryServicesVaultSku object = {
  name: 'RS0'
  tier: 'Standard'
}

// @description('Enable system identity for Recovery Services vault')
// param enableSystemIdentity bool = true

@description('''
Sets the identity property for the vault
Examples:
{
  type: 'UserAssigned'
  userAssignedIdentities: {}
}
{
  type: enableSystemIdentity ? 'SystemAssigned' : 'None'
}
''')
param identity object = {
  type: 'SystemAssigned'
}

@description('Which Metrics categories to enable; This defaults to `AllMetrics`. For array/object format, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep&pivots=deployment-language-bicep#metricsettings')
param diagnosticSettingsMetricsCategories array = [
  {
    categoryGroup: 'AllMetrics'
    enabled: true
  }
]

@description('The azure resource id of the log analytics workspace to log the diagnostics to.')
param logAnalyticsWorkspaceResourceId string = ''

@description('The name of the diagnostics. This defaults to `AzurePlatformCentralizedLogging`.')
@minLength(1)
@maxLength(260)
param diagnosticsName string = 'AzurePlatformCentralizedLogging'

@description('Which log categories to enable; This defaults to `allLogs`. For array/object format, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep#logsettings.')
param diagnosticSettingsLogsCategories array = [
  {
    categoryGroup: 'allLogs'
    enabled: true
  }
]

@description('''
The recovery services vault to create. A Recovery Services vault is a management entity that stores recovery points created over time and provides an interface to perform backup-related operations.
The Azure Recovery Services vault includes Azure Backup and Site Recovery, two services that let you to secure your data outside of your own data center.
The data that can be stored here is VMs configuration information, backup of your workstation and Azure SQL databases, etc.
''')
resource recoveryServicesVault 'Microsoft.RecoveryServices/vaults@2022-04-01' = {
  name: recoveryServicesVaultName
  location: location
  tags: tags
  properties: {}
  sku: recoveryServicesVaultSku
  identity: identity
}

@description('Upsert the diagnostics for this Azure Data Factory with the given parameters.')
resource diagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceResourceId)) {
  scope: recoveryServicesVault
  name: diagnosticsName
  properties: {
    workspaceId: empty(logAnalyticsWorkspaceResourceId) ? null : logAnalyticsWorkspaceResourceId
    logs: diagnosticSettingsLogsCategories
    metrics: diagnosticSettingsMetricsCategories
  }
}

@description('Output the resource name for this Recovery Services Vault.')
output vaultResourceName string = recoveryServicesVault.name
@description('Output the resource id for this Recovery Services Vault.')
output vaultResourceId string = recoveryServicesVault.id
@description('Output the system assigned managed identity for this Recovery Services Vault.')
output vaultIdentityPrincipalId string = recoveryServicesVault.identity.principalId


