metadata name = 'Cognitive Services'
metadata description = 'This module deploys a Cognitive Service.'

// ================================================= Imports =================================================
import { diagnosticLogCategory, diagnosticMetricCategory } from '../Common/diagnosticTypes.bicep'
import { virtualNetworkRule, ipRule } from '../Common/networkTypes.bicep'

/*
.SYNOPSIS
Creating an Azure Cognitive Services account (including Azure OpenAI)
.DESCRIPTION
Creating an Azure Cognitive Services account with the given specifications. This module supports various Cognitive Services including Azure OpenAI.
.EXAMPLE
<pre>
module openAiAccount 'br:contosoregistry.azurecr.io/cognitiveservices/accounts:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 55), 'openai')
  params: {
    accountName: 'myopenai-${environmentName}'
    location: location
    kind: 'OpenAI'
    skuName: 'S0'
    tags: tags
    publicNetworkAccess: 'Enabled'
    networkAclsDefaultAction: 'Allow'
  }
}
</pre>
<p>Creates an Azure OpenAI account with the name myopenai-${environmentName}</p>
.LINKS
- [Bicep Microsoft.CognitiveServices accounts](https://learn.microsoft.com/en-us/azure/templates/microsoft.cognitiveservices/accounts?pivots=deployment-language-bicep)
- [Azure OpenAI Service](https://learn.microsoft.com/en-us/azure/ai-services/openai/)
*/

// ================================================= User-Defined Types =================================================
@description('API properties for the Cognitive Services account')
type apiPropertiesType = {
  @description('AAD client ID for custom domain')
  aadClientId: string?

  @description('AAD tenant ID for custom domain')
  aadTenantId: string?

  @description('Event hub connection string for audit logs')
  eventHubConnectionString: string?

  @description('Azure Search endpoint ID for Q&A service')
  qnaAzureSearchEndpointId: string?

  @description('Azure Search endpoint key for Q&A service')
  qnaAzureSearchEndpointKey: string?

  @description('Custom questions and answers runtime endpoint')
  qnaRuntimeEndpoint: string?

  @description('Statistics enabled flag')
  statisticsEnabled: bool?

  @description('Storage account connection string for audit logs')
  storageAccountConnectionString: string?

  @description('Super user for Personalizer')
  superUser: string?

  @description('Website name for Personalizer')
  websiteName: string?
}

// ================================================= Parameters =================================================
@description('Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location.')
param location string = resourceGroup().location

@description('''
The name of the Cognitive Services account to create.
Account name restrictions:
- Account names must be between 2 and 64 characters in length
- Account names can contain alphanumeric characters and hyphens
- Account names must start with an alphanumeric character
- Your account name must be unique within Azure.
''')
@minLength(2)
@maxLength(64)
param accountName string

@description('''
The tags to apply to this resource. This is an object with key/value pairs.
Example:
{
  FirstTag: myvalue
  SecondTag: another value
}
''')
param tags object = {}

@description('Required. Kind of the Cognitive Services account. Use \'Get-AzCognitiveServicesAccountSku\' to determine a valid combinations of \'kind\' and \'SKU\' for your Azure region.')
@allowed([
  'AIServices'
  'AnomalyDetector'
  'CognitiveServices'
  'ComputerVision'
  'ContentModerator'
  'ContentSafety'
  'ConversationalLanguageUnderstanding'
  'CustomVision.Prediction'
  'CustomVision.Training'
  'Face'
  'FormRecognizer'
  'HealthInsights'
  'ImmersiveReader'
  'Internal.AllInOne'
  'LUIS'
  'LUIS.Authoring'
  'LanguageAuthoring'
  'MetricsAdvisor'
  'OpenAI'
  'Personalizer'
  'QnAMaker.v2'
  'SpeechServices'
  'TextAnalytics'
  'TextTranslation'
])
param kind string

@description('Optional. SKU of the Cognitive Services account. Use \'Get-AzCognitiveServicesAccountSku\' to determine a valid combinations of \'kind\' and \'SKU\' for your Azure region.')
@allowed([
  'C2'
  'C3'
  'C4'
  'F0'
  'F1'
  'S'
  'S0'
  'S1'
  'S10'
  'S2'
  'S3'
  'S4'
  'S5'
  'S6'
  'S7'
  'S8'
  'S9'
])
param skuName string = 'S0'

@description('The custom subdomain name to use for this account. If not specified, the account name will be used.')
param customSubDomainName string = ''

@description('Whether public network access is allowed for this resource.')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Disabled'

@description('The default action to take when no network rules match.')
@allowed([
  'Allow'
  'Deny'
])
param networkAclsDefaultAction string = 'Deny'

@description('The bypass options for network access control.')
@allowed([
  'None'
  'AzureServices'
])
param networkRuleSetBypass string = 'None'

@description('''
Array of virtual network rules for network access control.
Example:
[
  {
    id: '/subscriptions/{subscription-id}/resourceGroups/{resource-group}/providers/Microsoft.Network/virtualNetworks/{vnet-name}/subnets/{subnet-name}'
    ignoreMissingVnetServiceEndpoint: false
  }
]
''')
param virtualNetworkRules virtualNetworkRule[] = []

@description('''
Array of IP rules for network access control.
Example:
[
  {
    value: '203.0.113.0/24'
  }
]
''')
param ipRules ipRule[] = []

@description('API properties for the Cognitive Services account.')
param apiProperties apiPropertiesType = {}

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

// ================================================= Variables =================================================
@description('Determine the custom subdomain name to use')
var resolvedCustomSubDomainName = empty(customSubDomainName) ? accountName : customSubDomainName

// ================================================= Resources =================================================
@description('Create the Cognitive Services account')
resource cognitiveServicesAccount 'Microsoft.CognitiveServices/accounts@2024-10-01' = {
  name: accountName
  location: location
  tags: tags
  sku: {
    name: skuName
  }
  kind: kind
  properties: {
    apiProperties: apiProperties
    customSubDomainName: resolvedCustomSubDomainName
    networkAcls: {
      defaultAction: networkAclsDefaultAction
      virtualNetworkRules: virtualNetworkRules
      ipRules: ipRules
      bypass: networkRuleSetBypass
    }
    publicNetworkAccess: publicNetworkAccess
  }
}

@description('Conditionally create the diagnostic settings for the Cognitive Services account')
resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceResourceId)) {
  name: diagnosticsName
  scope: cognitiveServicesAccount
  properties: {
    workspaceId: logAnalyticsWorkspaceResourceId
    logs: diagnosticSettingsLogsCategories
    metrics: diagnosticSettingsMetricsCategories
  }
}

// ================================================= Outputs =================================================
@description('The name of the created Cognitive Services account')
output accountName string = cognitiveServicesAccount.name

@description('The resource ID of the created Cognitive Services account')
output accountResourceId string = cognitiveServicesAccount.id

@description('The endpoint of the created Cognitive Services account')
output endpoint string = cognitiveServicesAccount.properties.endpoint

@description('The custom subdomain name of the created Cognitive Services account')
output customSubDomainName string = cognitiveServicesAccount.properties.customSubDomainName
