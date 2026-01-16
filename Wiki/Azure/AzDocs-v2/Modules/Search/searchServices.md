# searchServices

Target Scope: resourceGroup

## User Defined Types
| Name | Type | Discriminator | Description
| -- |  -- | -- | -- |
| <a id="aadOrApiKeyAuthOption">aadOrApiKeyAuthOption</a>  | <pre>{</pre> |  | Azure AD or API key authentication option for data plane | 
| <a id="authOptions">authOptions</a>  | <pre>{</pre> |  | Data plane authentication options for the search service | 
| <a id="dataExfiltrationProtection">dataExfiltrationProtection</a>  | <pre>'BlockAll'</pre> |  | Data exfiltration protection scenarios that can be explicitly disallowed for the search service | 

## Synopsis
Creating an Azure Search Service (Cognitive Search)

## Description
Creating an Azure Search Service with the given specifications. This module supports various search service configurations including semantic search capabilities.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location. |
| searchServiceName | string | <input type="checkbox" checked> | Length between 2-60 | <pre></pre> | The name of the Search Service to create.<br>Search service name restrictions:<br>- Search service names must be between 2 and 60 characters in length<br>- Search service names can contain lowercase letters, digits, and hyphens<br>- Search service names must start and end with a letter or digit<br>- Search service names cannot contain consecutive hyphens<br>- Your search service name must be unique within Azure. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| skuName | string | <input type="checkbox"> | `'free'` or `'basic'` or `'standard'` or `'standard2'` or `'standard3'` or `'storage_optimized_l1'` or `'storage_optimized_l2'` | <pre>'basic'</pre> | The SKU name for the Search Service. |
| replicaCount | int | <input type="checkbox"> | Value between 1-12 | <pre>1</pre> | The number of replicas in the search service. If specified, it must be a value between 1 and 12 inclusive for standard skus, or between 1 and 3 inclusive for basic sku. |
| partitionCount | int | <input type="checkbox"> | `1` or `2` or `3` or `4` or `6` or `12` | <pre>1</pre> | The number of partitions in the search service; if specified, it can be 1, 2, 3, 4, 6, or 12. Values greater than 1 are only valid for standard skus. |
| publicNetworkAccess | string | <input type="checkbox"> | `'enabled'` or `'disabled'` or `'securedByPerimeter'` | <pre>'disabled'</pre> | Whether public network access is allowed for this resource. |
| ipRules | ipRule[] | <input type="checkbox"> | None | <pre>[]</pre> | Array of IP rules for network access control.<br>Example:<br>[<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;value: '203.0.113.0/24'<br>&nbsp;&nbsp;&nbsp;}<br>] |
| networkRuleSetBypass | string | <input type="checkbox"> | `'None'` or `'AzureServices'` | <pre>'None'</pre> | The bypass options for network access control. |
| hostingMode | string | <input type="checkbox"> | `'default'` or `'highDensity'` | <pre>'default'</pre> | The hosting mode for the search service. |
| disableLocalAuth | bool | <input type="checkbox"> | None | <pre>true</pre> | Whether local authentication is disabled. |
| authenticationOptions | authOptions? | <input type="checkbox" checked> | None | <pre></pre> | Defines the options for how the data plane API of a search service authenticates requests. This cannot be set if disableLocalAuth is set to true. |
| semanticSearch | string | <input type="checkbox"> | `'disabled'` or `'free'` or `'standard'` | <pre>'free'</pre> | The semantic search configuration. |
| encryptionWithCmkEnforcement | string | <input type="checkbox"> | `'Disabled'` or `'Enabled'` or `'Unspecified'` | <pre>'Unspecified'</pre> | The encryption with customer-managed keys enforcement. |
| dataExfiltrationProtections | dataExfiltrationProtection[] | <input type="checkbox"> | None | <pre>[]</pre> | Array of data exfiltration protection scenarios that are explicitly disallowed for the search service. |
| identity | object | <input type="checkbox"> | None | <pre>{<br>  type: 'SystemAssigned'<br>}</pre> | Managed service identity to use for this Azure Search Service. Defaults to a system assigned managed identity. For object format, refer to [documentation](https://docs.microsoft.com/en-us/azure/templates/microsoft.search/searchservices?tabs=bicep#identity). |
| logAnalyticsWorkspaceResourceId | string | <input type="checkbox"> | None | <pre>''</pre> | The azure resource id of the log analytics workspace to log the diagnostics to. If you set this to an empty string, logging & diagnostics will be disabled. |
| diagnosticsName | string | <input type="checkbox"> | Length between 1-260 | <pre>'AzurePlatformCentralizedLogging'</pre> | The name of the diagnostics. This defaults to `AzurePlatformCentralizedLogging`. |
| diagnosticSettingsLogsCategories | diagnosticLogCategory[] | <input type="checkbox"> | None | <pre>[<br>  {<br>    categoryGroup: 'allLogs'<br>    enabled: true<br>    retentionPolicy: {<br>      days: 7<br>      enabled: true<br>    }<br>  }<br>]</pre> | Which log categories to enable; This defaults to `allLogs`. For array/object format, please refer to [docs](https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep#logsettings). |
| diagnosticSettingsMetricsCategories | diagnosticMetricCategory[] | <input type="checkbox"> | None | <pre>[<br>  {<br>    category: 'AllMetrics'<br>    enabled: true<br>    retentionPolicy: {<br>      days: 7<br>      enabled: true<br>    }<br>  }<br>]</pre> | Which Metrics categories to enable; This defaults to `AllMetrics`. For array/object format, please refer to [docs](https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep&pivots=deployment-language-bicep#metricsettings). |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| searchServiceName | string | The name of the created Search Service |
| searchServiceResourceId | string | The resource ID of the created Search Service |
| searchServiceEndpoint | string | The endpoint URL of the created Search Service |
| searchServicePrincipalId | string | The principal ID of the system assigned managed identity |

## Examples
<pre>
module searchService 'br:contosoregistry.azurecr.io/search/searchservices:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 50), 'search')
  params: {
    searchServiceName: 'mysearch-${environmentName}'
    location: location
    skuName: 'basic'
    tags: tags
    publicNetworkAccess: 'enabled'
    semanticSearch: 'free'    identity: {
      type: 'SystemAssigned'
    }
    authenticationOptions: {
      apiKeyOnly: {}
    }
  }
}
</pre>
<p>Creates an Azure Search Service with the name mysearch-${environmentName} and system-assigned managed identity</p>

<p>Example with Azure AD authentication:</p>
<pre>
module searchServiceWithAAD 'br:contosoregistry.azurecr.io/search/searchservices:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 45), 'search-aad')
  params: {
    searchServiceName: 'mysearch-aad-${environmentName}'
    location: location
    skuName: 'standard'
    disableLocalAuth: false
    authenticationOptions: {
      aadOrApiKey: {
        aadAuthFailureMode: 'http401WithBearerChallenge'
      }
    }
  }
}
</pre>

## Links
- [Bicep Microsoft.Search searchServices](https://learn.microsoft.com/en-us/azure/templates/microsoft.search/2025-05-01/searchservices?pivots=deployment-language-bicep)<br>
- [Azure Cognitive Search](https://learn.microsoft.com/en-us/azure/search/)
