// TODO: Code documentation
@description('Specifies the Azure location where the key vault should be created.')
param location string = resourceGroup().location

@description('The resource name of this Data Factory.')
@minLength(3)
@maxLength(63)
param dataFactoryName string

@description('Enables system assigned managed identity on the resource')
param systemAssignedIdentity bool = true

@description('The user assigned ID(s) to assign to the resource. For formatting, please refer to: https://docs.microsoft.com/en-us/azure/templates/microsoft.datafactory/factories?pivots=deployment-language-bicep#factoryidentity.')
param userAssignedIdentities object = {}

@description('Enable or disable public network access.')
@allowed([
  'Disabled'
  'Enabled'
])
param publicNetworkAccess string = 'Disabled'

@description('''
The tags to apply to this resource. This is an object with key/value pairs.
Example:
{
  FirstTag: myvalue
  SecondTag: another value
}
''')
param tags object = {}

@description('Configure Azure Data Factory to store the pipelines, datasets, data flows, and so on in a GIT repository. This allows you to automate your workflow using (for example) Azure DevOps pipelines or GitHub actions. For more information, refer to https://docs.microsoft.com/en-us/azure/data-factory/continuous-integration-delivery.')
param repoConfiguration object = {}

@description('The azure resource id of the log analytics workspace to log the diagnostics to. If you set this to an empty string, logging & diagnostics will be disabled.')
@minLength(0)
param logAnalyticsWorkspaceResourceId string

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

@description('Which Metrics categories to enable; This defaults to `AllMetrics`. For array/object format, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep&pivots=deployment-language-bicep#metricsettings')
param diagnosticSettingsMetricsCategories array = [
  {
    categoryGroup: 'AllMetrics'
    enabled: true
  }
]

@description('Determine the correct identityType for this Azure Data Factory based on the users input.')
var identityType = systemAssignedIdentity ? (!empty(userAssignedIdentities) ? 'SystemAssigned,UserAssigned' : 'SystemAssigned') : (!empty(userAssignedIdentities) ? 'UserAssigned' : 'None')

@description('Upsert the Azure Data Factory using the given parameters.')
resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: dataFactoryName
  location: location
  tags: tags
  identity: {
    type: identityType
  }
  properties: {
    repoConfiguration: repoConfiguration
    publicNetworkAccess: publicNetworkAccess
  }
}

@description('Upsert the diagnostics for this Azure Data Factory with the given parameters.')
resource diagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceResourceId)) {
  scope: dataFactory
  name: diagnosticsName
  properties: {
    workspaceId: empty(logAnalyticsWorkspaceResourceId) ? null : logAnalyticsWorkspaceResourceId
    logs: diagnosticSettingsLogsCategories
    metrics: diagnosticSettingsMetricsCategories
  }
}

@description('Output the resource name of the Azure Data Factory.')
output dataFactoryName string = dataFactory.name
