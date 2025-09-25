metadata name = 'Azure Search Service'
metadata description = 'This module deploys an Azure Search Service.'

// ================================================= Imports =================================================
import { diagnosticLogCategory, diagnosticMetricCategory } from '../Common/diagnosticTypes.bicep'
import { ipRule } from '../Common/networkTypes.bicep'

// ================================================= User-Defined Types =================================================
@description('Azure AD or API key authentication option for data plane')
type aadOrApiKeyAuthOption = {
  @description('Describes what response the data plane API would send for requests that failed authentication')
  aadAuthFailureMode: 'http401WithBearerChallenge' | 'http403'
}

@description('Data plane authentication options for the search service')
type authOptions = {
  @description('Indicates that either the API key or an access token from a Microsoft Entra ID tenant can be used for authentication')
  aadOrApiKey: aadOrApiKeyAuthOption?

  @description('Indicates that only the API key can be used for authentication')
  apiKeyOnly: object?
}

@description('Data exfiltration protection scenarios that can be explicitly disallowed for the search service')
type dataExfiltrationProtection = 'BlockAll'

/*
.SYNOPSIS
Creating an Azure Search Service (Cognitive Search)
.DESCRIPTION
Creating an Azure Search Service with the given specifications. This module supports various search service configurations including semantic search capabilities.
.EXAMPLE
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
.LINKS
- [Bicep Microsoft.Search searchServices](https://learn.microsoft.com/en-us/azure/templates/microsoft.search/searchservices?pivots=deployment-language-bicep)
- [Azure Cognitive Search](https://learn.microsoft.com/en-us/azure/search/)
*/

// ================================================= Parameters =================================================
@description('Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location.')
param location string = resourceGroup().location

@description('''
The name of the Search Service to create.
Search service name restrictions:
- Search service names must be between 2 and 60 characters in length
- Search service names can contain lowercase letters, digits, and hyphens
- Search service names must start and end with a letter or digit
- Search service names cannot contain consecutive hyphens
- Your search service name must be unique within Azure.
''')
@minLength(2)
@maxLength(60)
param searchServiceName string

@description('''
The tags to apply to this resource. This is an object with key/value pairs.
Example:
{
  FirstTag: myvalue
  SecondTag: another value
}
''')
param tags object = {}

@description('The SKU name for the Search Service.')
@allowed([
  'free'
  'basic'
  'standard'
  'standard2'
  'standard3'
  'storage_optimized_l1'
  'storage_optimized_l2'
])
param skuName string = 'basic'

@description('The number of replicas in the search service. If specified, it must be a value between 1 and 12 inclusive for standard skus, or between 1 and 3 inclusive for basic sku.')
@minValue(1)
@maxValue(12)
param replicaCount int = 1

@description('The number of partitions in the search service; if specified, it can be 1, 2, 3, 4, 6, or 12. Values greater than 1 are only valid for standard skus.')
@allowed([
  1
  2
  3
  4
  6
  12
])
param partitionCount int = 1

// Validate that partition count > 1 is only allowed for standard SKUs
var isStandardSku = contains(
  ['standard', 'standard2', 'standard3', 'storage_optimized_l1', 'storage_optimized_l2'],
  skuName
)

// This will cause deployment to fail if partition count > 1 and SKU is not standard
var validatePartitionCount = partitionCount > 1 && !isStandardSku
  ? fail('Partition count greater than 1 is only valid for standard SKUs (standard, standard2, standard3, storage_optimized_l1, storage_optimized_l2). Current SKU: ${skuName}, Partition Count: ${partitionCount}')
  : true

@description('Whether public network access is allowed for this resource.')
@allowed([
  'enabled'
  'disabled'
  'securedByPerimeter'
])
param publicNetworkAccess string = 'disabled'

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

@description('The bypass options for network access control.')
@allowed([
  'None'
  'AzureServices'
])
param networkRuleSetBypass string = 'None'

@description('The hosting mode for the search service.')
@allowed([
  'default'
  'highDensity'
])
param hostingMode string = 'default'

@description('Whether local authentication is disabled.')
param disableLocalAuth bool = true

@description('Defines the options for how the data plane API of a search service authenticates requests. This cannot be set if disableLocalAuth is set to true.')
param authenticationOptions authOptions?

@description('The semantic search configuration.')
@allowed([
  'disabled'
  'free'
  'standard'
])
param semanticSearch string = 'free'

@description('The encryption with customer-managed keys enforcement.')
@allowed([
  'Disabled'
  'Enabled'
  'Unspecified'
])
param encryptionWithCmkEnforcement string = 'Unspecified'

@description('Array of data exfiltration protection scenarios that are explicitly disallowed for the search service.')
param dataExfiltrationProtections dataExfiltrationProtection[] = []

@description('Managed service identity to use for this Azure Search Service. Defaults to a system assigned managed identity. For object format, refer to [documentation](https://docs.microsoft.com/en-us/azure/templates/microsoft.search/searchservices?tabs=bicep#identity).')
param identity object = {
  type: 'SystemAssigned'
}

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
@description('Create the Search Service')
resource searchService 'Microsoft.Search/searchServices@2025-02-01-Preview' = {
  name: searchServiceName
  location: location
  tags: tags
  sku: {
    name: skuName
  }
  identity: identity
  properties: {
    replicaCount: replicaCount
    partitionCount: validatePartitionCount ? partitionCount : partitionCount // This ensures validation is evaluated
    hostingMode: hostingMode
    publicNetworkAccess: publicNetworkAccess
    networkRuleSet: {
      ipRules: ipRules
      bypass: networkRuleSetBypass
    }
    encryptionWithCmk: {
      enforcement: encryptionWithCmkEnforcement
    }
    disableLocalAuth: disableLocalAuth
    authOptions: authenticationOptions
    dataExfiltrationProtections: dataExfiltrationProtections
    semanticSearch: semanticSearch
  }
}

@description('Conditionally create the diagnostic settings for the Search Service')
resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceResourceId)) {
  name: diagnosticsName
  scope: searchService
  properties: {
    workspaceId: logAnalyticsWorkspaceResourceId
    logs: diagnosticSettingsLogsCategories
    metrics: diagnosticSettingsMetricsCategories
  }
}

// ================================================= Outputs =================================================
@description('The name of the created Search Service')
output searchServiceName string = searchService.name

@description('The resource ID of the created Search Service')
output searchServiceResourceId string = searchService.id

@description('The endpoint URL of the created Search Service')
output searchServiceEndpoint string = 'https://${searchService.name}.search.windows.net'

@description('The principal ID of the system assigned managed identity')
output searchServicePrincipalId string = identity.type == 'SystemAssigned'
  ? searchService.identity.principalId
  : identity.type == 'SystemAssigned, UserAssigned' ? searchService.identity.principalId : ''
