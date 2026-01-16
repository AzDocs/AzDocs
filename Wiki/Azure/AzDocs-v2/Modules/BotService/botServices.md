# botServices

Target Scope: resourceGroup

## Synopsis
Creating an Azure Bot Service

## Description
Creating an Azure Bot Service with the given specifications. This module supports various bot kinds including SDK, Function, and Azure Bot.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location. |
| botName | string | <input type="checkbox" checked> | Length between 2-64 | <pre></pre> | The name of the Bot Service to create.<br>Bot name restrictions:<br>- Bot names must be between 2 and 64 characters in length<br>- Bot names can contain alphanumeric characters, hyphens, underscores, and periods<br>- Bot names must start with an alphanumeric character<br>- Your bot name must be unique within Azure. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| kind | string | <input type="checkbox" checked> | `'azurebot'` or `'bot'` or `'designer'` or `'function'` or `'sdk'` | <pre></pre> | Required. Kind of the Bot Service. |
| skuName | string | <input type="checkbox"> | `'F0'` or `'S1'` | <pre>'F0'</pre> | Optional. SKU of the Bot Service. |
| displayName | string | <input type="checkbox" checked> | None | <pre></pre> | Required. The display name of the bot. |
| endpoint | string | <input type="checkbox" checked> | None | <pre></pre> | Required. The bot endpoint for incoming messages. |
| msaAppId | string | <input type="checkbox" checked> | None | <pre></pre> | Required. Microsoft App Id for the bot. |
| msaAppTenantId | string | <input type="checkbox"> | None | <pre>''</pre> | Optional. Microsoft App Tenant Id for the bot. |
| msaAppType | string | <input type="checkbox"> | `'MultiTenant'` or `'SingleTenant'` or `'UserAssignedMSI'` | <pre>'MultiTenant'</pre> | Optional. Microsoft App Type for the bot. |
| msaAppMSIResourceId | string | <input type="checkbox"> | None | <pre>''</pre> | Optional. Microsoft App Managed Identity Resource Id for the bot (required when using UserAssignedMSI). |
| botDescription | string | <input type="checkbox"> | None | <pre>''</pre> | Optional. The bot description. |
| iconUrl | string | <input type="checkbox"> | None | <pre>''</pre> | Optional. The Icon Url of the bot. |
| appPasswordHint | string | <input type="checkbox"> | None | <pre>''</pre> | Optional. The hint (e.g. keyVault secret resourceId) on how to fetch the app secret. |
| isStreamingSupported | bool | <input type="checkbox"> | None | <pre>false</pre> | Optional. Whether the bot is streaming supported. |
| publicNetworkAccess | string | <input type="checkbox"> | `'Disabled'` or `'Enabled'` or `'SecuredByPerimeter'` | <pre>'Enabled'</pre> | Optional. Whether the bot is in an isolated network. |
| disableLocalAuth | bool | <input type="checkbox"> | None | <pre>false</pre> | Optional. Opt-out of local authentication and ensure only MSI and AAD can be used exclusively for authentication. |
| luisAppIds | array | <input type="checkbox"> | None | <pre>[]</pre> | Optional. Collection of LUIS App Ids. |
| luisKey | string | <input type="checkbox"> | None | <pre>''</pre> | Optional. The LUIS Key. |
| developerAppInsightKey | string | <input type="checkbox"> | None | <pre>''</pre> | Optional. The Application Insights key. |
| developerAppInsightsApiKey | string | <input type="checkbox"> | None | <pre>''</pre> | Optional. The Application Insights Api Key. |
| developerAppInsightsApplicationId | string | <input type="checkbox"> | None | <pre>''</pre> | Optional. The Application Insights App Id. |
| isCmekEnabled | bool | <input type="checkbox"> | None | <pre>false</pre> | Optional. Whether Cmek is enabled. |
| cmekKeyVaultUrl | string | <input type="checkbox"> | None | <pre>''</pre> | Optional. The CMK Url. |
| storageResourceId | string | <input type="checkbox"> | None | <pre>''</pre> | Optional. The storage resourceId for the bot. |
| manifestUrl | string | <input type="checkbox"> | None | <pre>''</pre> | Optional. The bot\'s manifest url. |
| schemaTransformationVersion | string | <input type="checkbox"> | None | <pre>''</pre> | Optional. The channel schema transformation version for the bot. |
| allSettings | object | <input type="checkbox"> | None | <pre>{}</pre> | Optional. Contains resource all settings defined as key/value pairs. |
| botParameters | object | <input type="checkbox"> | None | <pre>{}</pre> | Optional. Contains resource parameters defined as key/value pairs. |
| logAnalyticsWorkspaceResourceId | string | <input type="checkbox"> | None | <pre>''</pre> | The azure resource id of the log analytics workspace to log the diagnostics to. If you set this to an empty string, logging & diagnostics will be disabled. |
| diagnosticsName | string | <input type="checkbox"> | Length between 1-260 | <pre>'AzurePlatformCentralizedLogging'</pre> | The name of the diagnostics. This defaults to `AzurePlatformCentralizedLogging`. |
| diagnosticSettingsLogsCategories | diagnosticLogCategory[] | <input type="checkbox"> | None | <pre>[<br>  {<br>    categoryGroup: 'allLogs'<br>    enabled: true<br>    retentionPolicy: {<br>      days: 7<br>      enabled: true<br>    }<br>  }<br>]</pre> | Which log categories to enable; This defaults to `allLogs`. For array/object format, please refer to [docs](https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep#logsettings). |
| diagnosticSettingsMetricsCategories | diagnosticMetricCategory[] | <input type="checkbox"> | None | <pre>[<br>  {<br>    category: 'AllMetrics'<br>    enabled: true<br>    retentionPolicy: {<br>      days: 7<br>      enabled: true<br>    }<br>  }<br>]</pre> | Which Metrics categories to enable; This defaults to `AllMetrics`. For array/object format, please refer to [docs](https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep&pivots=deployment-language-bicep#metricsettings). |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| botName | string | The name of the created Bot Service |
| botResourceId | string | The resource ID of the created Bot Service |
| endpoint | string | The endpoint of the created Bot Service |
| msaAppId | string | The Microsoft App Id of the created Bot Service |

## Examples
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

## Links
- [Bicep Microsoft.BotService botServices](https://learn.microsoft.com/en-us/azure/templates/microsoft.botservice/botservices?pivots=deployment-language-bicep)<br>
- [Azure Bot Service](https://learn.microsoft.com/en-us/azure/bot-service/)
