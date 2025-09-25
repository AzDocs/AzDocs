# accounts

Target Scope: resourceGroup

## User Defined Types
| Name | Type | Discriminator | Description
| -- |  -- | -- | -- |
| <a id="apiPropertiesType">apiPropertiesType</a>  | <pre>{</pre> |  | API properties for the Cognitive Services account | 

## Synopsis
Creating an Azure Cognitive Services account (including Azure OpenAI)

## Description
Creating an Azure Cognitive Services account with the given specifications. This module supports various Cognitive Services including Azure OpenAI.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location. |
| accountName | string | <input type="checkbox" checked> | Length between 2-64 | <pre></pre> | The name of the Cognitive Services account to create.<br>Account name restrictions:<br>- Account names must be between 2 and 64 characters in length<br>- Account names can contain alphanumeric characters and hyphens<br>- Account names must start with an alphanumeric character<br>- Your account name must be unique within Azure. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| kind | string | <input type="checkbox" checked> | `'AIServices'` or `'AnomalyDetector'` or `'CognitiveServices'` or `'ComputerVision'` or `'ContentModerator'` or `'ContentSafety'` or `'ConversationalLanguageUnderstanding'` or `'CustomVision.Prediction'` or `'CustomVision.Training'` or `'Face'` or `'FormRecognizer'` or `'HealthInsights'` or `'ImmersiveReader'` or `'Internal.AllInOne'` or `'LUIS'` or `'LUIS.Authoring'` or `'LanguageAuthoring'` or `'MetricsAdvisor'` or `'OpenAI'` or `'Personalizer'` or `'QnAMaker.v2'` or `'SpeechServices'` or `'TextAnalytics'` or `'TextTranslation'` | <pre></pre> | Required. Kind of the Cognitive Services account. Use \'Get-AzCognitiveServicesAccountSku\' to determine a valid combinations of \'kind\' and \'SKU\' for your Azure region. |
| skuName | string | <input type="checkbox"> | `'C2'` or `'C3'` or `'C4'` or `'F0'` or `'F1'` or `'S'` or `'S0'` or `'S1'` or `'S10'` or `'S2'` or `'S3'` or `'S4'` or `'S5'` or `'S6'` or `'S7'` or `'S8'` or `'S9'` | <pre>'S0'</pre> | Optional. SKU of the Cognitive Services account. Use \'Get-AzCognitiveServicesAccountSku\' to determine a valid combinations of \'kind\' and \'SKU\' for your Azure region. |
| customSubDomainName | string | <input type="checkbox"> | None | <pre>''</pre> | The custom subdomain name to use for this account. If not specified, the account name will be used. |
| publicNetworkAccess | string | <input type="checkbox"> | `'Enabled'` or `'Disabled'` | <pre>'Disabled'</pre> | Whether public network access is allowed for this resource. |
| networkAclsDefaultAction | string | <input type="checkbox"> | `'Allow'` or `'Deny'` | <pre>'Deny'</pre> | The default action to take when no network rules match. |
| networkRuleSetBypass | string | <input type="checkbox"> | `'None'` or `'AzureServices'` | <pre>'None'</pre> | The bypass options for network access control. |
| virtualNetworkRules | virtualNetworkRule[] | <input type="checkbox"> | None | <pre>[]</pre> | Array of virtual network rules for network access control.<br>Example:<br>[<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;id: '/subscriptions/{subscription-id}/resourceGroups/{resource-group}/providers/Microsoft.Network/virtualNetworks/{vnet-name}/subnets/{subnet-name}'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ignoreMissingVnetServiceEndpoint: false<br>&nbsp;&nbsp;&nbsp;}<br>] |
| ipRules | ipRule[] | <input type="checkbox"> | None | <pre>[]</pre> | Array of IP rules for network access control.<br>Example:<br>[<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;value: '203.0.113.0/24'<br>&nbsp;&nbsp;&nbsp;}<br>] |
| apiProperties | [apiPropertiesType](#apiPropertiesType) | <input type="checkbox"> | None | <pre>{}</pre> | API properties for the Cognitive Services account. |
| logAnalyticsWorkspaceResourceId | string | <input type="checkbox"> | None | <pre>''</pre> | The azure resource id of the log analytics workspace to log the diagnostics to. If you set this to an empty string, logging & diagnostics will be disabled. |
| diagnosticsName | string | <input type="checkbox"> | Length between 1-260 | <pre>'AzurePlatformCentralizedLogging'</pre> | The name of the diagnostics. This defaults to `AzurePlatformCentralizedLogging`. |
| diagnosticSettingsLogsCategories | diagnosticLogCategory[] | <input type="checkbox"> | None | <pre>[<br>  {<br>    categoryGroup: 'allLogs'<br>    enabled: true<br>    retentionPolicy: {<br>      days: 7<br>      enabled: true<br>    }<br>  }<br>]</pre> | Which log categories to enable; This defaults to `allLogs`. For array/object format, please refer to [docs](https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep#logsettings). |
| diagnosticSettingsMetricsCategories | diagnosticMetricCategory[] | <input type="checkbox"> | None | <pre>[<br>  {<br>    category: 'AllMetrics'<br>    enabled: true<br>    retentionPolicy: {<br>      days: 7<br>      enabled: true<br>    }<br>  }<br>]</pre> | Which Metrics categories to enable; This defaults to `AllMetrics`. For array/object format, please refer to [docs](https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep&pivots=deployment-language-bicep#metricsettings). |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| accountName | string | The name of the created Cognitive Services account |
| accountResourceId | string | The resource ID of the created Cognitive Services account |
| endpoint | string | The endpoint of the created Cognitive Services account |
| customSubDomainName | string | The custom subdomain name of the created Cognitive Services account |

## Examples
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

## Links
- [Bicep Microsoft.CognitiveServices accounts](https://learn.microsoft.com/en-us/azure/templates/microsoft.cognitiveservices/accounts?pivots=deployment-language-bicep)<br>
- [Azure OpenAI Service](https://learn.microsoft.com/en-us/azure/ai-services/openai/)
