metadata name = 'Bot Service'
metadata description = 'This module deploys an Azure Bot Service.'

// ================================================= Imports =================================================
import { diagnosticLogCategory, diagnosticMetricCategory } from '../Common/diagnosticTypes.bicep'

/*
.SYNOPSIS
Creating an Azure Bot Service
.DESCRIPTION
Creating an Azure Bot Service with the given specifications. This module supports various bot kinds including SDK, Function, and Azure Bot.
.EXAMPLE
<pre>
module botService 'br:contosoregistry.azurecr.io/botservice/botservices:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 55), 'bot')
  params: {
    botName: 'mybot-${environmentName}'
    location: 'global'
    kind: 'azurebot'
    skuName: 'F0'
    displayName: 'My Bot'
    endpoint: 'https://mybot.azurewebsites.net/api/messages'
    msaAppId: 'your-app-id'
    tags: tags
  }
}
</pre>
<p>Creates an Azure Bot Service with the name mybot-${environmentName}</p>
.LINKS
- [Bicep Microsoft.BotService botServices](https://learn.microsoft.com/en-us/azure/templates/microsoft.botservice/botservices?pivots=deployment-language-bicep)
- [Azure Bot Service](https://learn.microsoft.com/en-us/azure/bot-service/)
*/

// ================================================= Parameters =================================================
@description('Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location.')
param location string = resourceGroup().location

@description('''
The name of the Bot Service to create.
Bot name restrictions:
- Bot names must be between 2 and 64 characters in length
- Bot names can contain alphanumeric characters, hyphens, underscores, and periods
- Bot names must start with an alphanumeric character
- Your bot name must be unique within Azure.
''')
@minLength(2)
@maxLength(64)
param botName string

@description('''
The tags to apply to this resource. This is an object with key/value pairs.
Example:
{
  FirstTag: myvalue
  SecondTag: another value
}
''')
param tags object = {}

@description('Required. Kind of the Bot Service.')
@allowed([
  'azurebot'
  'bot'
  'designer'
  'function'
  'sdk'
])
param kind string

@description('Optional. SKU of the Bot Service.')
@allowed([
  'F0'
  'S1'
])
param skuName string = 'F0'

@description('Required. The display name of the bot.')
param displayName string

@description('Required. The bot endpoint for incoming messages.')
param endpoint string

@description('Required. Microsoft App Id for the bot.')
param msaAppId string

@description('Optional. Microsoft App Tenant Id for the bot.')
param msaAppTenantId string = ''

@description('Optional. Microsoft App Type for the bot.')
@allowed([
  'MultiTenant'
  'SingleTenant'
  'UserAssignedMSI'
])
param msaAppType string = 'MultiTenant'

@description('Optional. Microsoft App Managed Identity Resource Id for the bot (required when using UserAssignedMSI).')
param msaAppMSIResourceId string = ''

@description('Optional. The bot description.')
param botDescription string = ''

@description('Optional. The Icon Url of the bot.')
param iconUrl string = ''

@description('Optional. The hint (e.g. keyVault secret resourceId) on how to fetch the app secret.')
@secure()
param appPasswordHint string = ''

@description('Optional. Whether the bot is streaming supported.')
param isStreamingSupported bool = false

@description('Optional. Whether the bot is in an isolated network.')
@allowed([
  'Disabled'
  'Enabled'
  'SecuredByPerimeter'
])
param publicNetworkAccess string = 'Enabled'

@description('Optional. Opt-out of local authentication and ensure only MSI and AAD can be used exclusively for authentication.')
param disableLocalAuth bool = false

@description('Optional. Collection of LUIS App Ids.')
param luisAppIds array = []

@description('Optional. The LUIS Key.')
@secure()
param luisKey string = ''

@description('Optional. The Application Insights key.')
@secure()
param developerAppInsightKey string = ''

@description('Optional. The Application Insights Api Key.')
@secure()
param developerAppInsightsApiKey string = ''

@description('Optional. The Application Insights App Id.')
param developerAppInsightsApplicationId string = ''

@description('Optional. Whether Cmek is enabled.')
param isCmekEnabled bool = false

@description('Optional. The CMK Url.')
param cmekKeyVaultUrl string = ''

@description('Optional. The storage resourceId for the bot.')
param storageResourceId string = ''

@description('Optional. The bot\'s manifest url.')
param manifestUrl string = ''

@description('Optional. The channel schema transformation version for the bot.')
param schemaTransformationVersion string = ''

@description('Optional. Contains resource all settings defined as key/value pairs.')
param allSettings object = {}

@description('Optional. Contains resource parameters defined as key/value pairs.')
param botParameters object = {}

@description('The azure resource id of the log analytics workspace to log the diagnostics to. If you set this to an empty string, logging & diagnostics will be disabled.')
param logAnalyticsWorkspaceResourceId string = ''

@description('The name of the diagnostics. This defaults to `AzurePlatformCentralizedLogging`.')
@minLength(1)
@maxLength(260)
param diagnosticsName string = 'AzurePlatformCentralizedLogging'

@description('Which log categories to enable; This defaults to `allLogs`. For array/object format, please refer to [docs](https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep#logsettings).')
param diagnosticSettingsLogsCategories diagnosticLogCategory[] = [
  {
    categoryGroup: 'allLogs'
    enabled: true
    retentionPolicy: {
      days: 7
      enabled: true
    }
  }
]

@description('Which Metrics categories to enable; This defaults to `AllMetrics`. For array/object format, please refer to [docs](https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep&pivots=deployment-language-bicep#metricsettings).')
param diagnosticSettingsMetricsCategories diagnosticMetricCategory[] = [
  {
    category: 'AllMetrics'
    enabled: true
    retentionPolicy: {
      days: 7
      enabled: true
    }
  }
]

// ================================================= Resources =================================================
@description('Create the Bot Service')
resource botService 'Microsoft.BotService/botServices@2023-09-15-preview' = {
  name: botName
  location: location
  kind: kind
  sku: {
    name: skuName
  }
  tags: tags
  properties: {
    displayName: displayName
    endpoint: endpoint
    msaAppId: msaAppId
    msaAppTenantId: !empty(msaAppTenantId) ? msaAppTenantId : null
    msaAppType: msaAppType
    msaAppMSIResourceId: !empty(msaAppMSIResourceId) ? msaAppMSIResourceId : null
    description: !empty(botDescription) ? botDescription : null
    iconUrl: !empty(iconUrl) ? iconUrl : null
    appPasswordHint: !empty(appPasswordHint) ? appPasswordHint : null
    isStreamingSupported: isStreamingSupported
    publicNetworkAccess: publicNetworkAccess
    disableLocalAuth: disableLocalAuth
    luisAppIds: !empty(luisAppIds) ? luisAppIds : null
    luisKey: !empty(luisKey) ? luisKey : null
    developerAppInsightKey: !empty(developerAppInsightKey) ? developerAppInsightKey : null
    developerAppInsightsApiKey: !empty(developerAppInsightsApiKey) ? developerAppInsightsApiKey : null
    developerAppInsightsApplicationId: !empty(developerAppInsightsApplicationId) ? developerAppInsightsApplicationId : null
    isCmekEnabled: isCmekEnabled
    cmekKeyVaultUrl: !empty(cmekKeyVaultUrl) ? cmekKeyVaultUrl : null
    storageResourceId: !empty(storageResourceId) ? storageResourceId : null
    manifestUrl: !empty(manifestUrl) ? manifestUrl : null
    schemaTransformationVersion: !empty(schemaTransformationVersion) ? schemaTransformationVersion : null
    allSettings: !empty(allSettings) ? allSettings : null
    parameters: !empty(botParameters) ? botParameters : null
  }
}

@description('Conditionally create the diagnostic settings for the Bot Service')
resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceResourceId)) {
  scope: botService
  name: diagnosticsName
  properties: {
    workspaceId: logAnalyticsWorkspaceResourceId
    logs: diagnosticSettingsLogsCategories
    metrics: diagnosticSettingsMetricsCategories
  }
}

// ================================================= Outputs =================================================
@description('The name of the created Bot Service')
output botName string = botService.name

@description('The resource ID of the created Bot Service')
output botResourceId string = botService.id

@description('The endpoint of the created Bot Service')
output endpoint string = botService.properties.endpoint

@description('The Microsoft App Id of the created Bot Service')
output msaAppId string = botService.properties.msaAppId
