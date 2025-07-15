/*
.SYNOPSIS
Creates an Azure Cache for Redis instance
.DESCRIPTION
Creates an Azure Cache for Redis instance with the given specs.
.EXAMPLE
<pre>
module webApp 'br:contosoregistry.azurecr.io/cache/redis:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 58), 'redis')
  params: {
    redisCacheName: redisCacheName
    redisCacheSKU: redisCacheSKU
    redisCacheCapacity: redisCacheCapacity
  }
}
</pre>
<p>Creates an Azure Cache for Redis with the name 'redisCacheName'</p>
.LINKS
- [Bicep Microsoft.Cache redis](https://learn.microsoft.com/en-us/azure/templates/microsoft.cache/redis?pivots=deployment-language-bicep)
- [Quickstart: Create an Azure Cache for Redis using Bicep](https://learn.microsoft.com/en-us/azure/redis/redis-cache-bicep-provision?tabs=CLI)
*/

// ================================================= Imports =================================================
import { diagnosticLogCategory, diagnosticMetricCategory } from '../_common/diagnosticTypes.bicep'

// ================================================= User-Defined Types =================================================
type roleAssignmentType = {
  @description('Required. The role to assign. You can provide either the display name of the role definition, the role definition GUID, or its fully qualified ID in the following format: \'/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11\'.')
  roleDefinitionIdOrName: string

  @description('Required. The principal ID of the principal (user/group/identity) to assign the role to.')
  principalId: string

  @description('Optional. The principal type of the assigned principal ID.')
  principalType: ('ServicePrincipal' | 'Group' | 'User' | 'ForeignGroup' | 'Device')?

  @description('Optional. The description of the role assignment.')
  description: string?

  @description('Optional. The conditions on the role assignment. This limits the resources it can be assigned to. e.g.: @Resource[Microsoft.Storage/storageAccounts/blobServices/containers:ContainerName] StringEqualsIgnoreCase "foo_storage_container".')
  condition: string?

  @description('Optional. Version of the condition.')
  conditionVersion: '2.0'?

  @description('Optional. The Resource Id of the delegated managed identity resource.')
  delegatedManagedIdentityResourceId: string?
}

// ================================================= Parameters =================================================
@description('Specifies the Azure location where the resource should be created.')
param location string = resourceGroup().location

@description('The name of the Azure Cache for Redis Instance.')
@minLength(2)
@maxLength(60)
param redisCacheName string

@description('Specify the pricing tier of the new Azure Redis Cache.')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param redisCacheSKU string

@description('Specify the size of the new Azure Redis Cache instance. Valid values: for C (Basic/Standard) family (0, 1, 2, 3, 4, 5, 6), for P (Premium) family (1, 2, 3, 4, 5)')
@allowed([
  0
  1
  2
  3
  4
  5
  6
])
param redisCacheCapacity int

@description('Managed service identity to use for this Azure Cache for Redis Instance. Defaults to a system assigned managed identity. For object format, refer to [documentation](https://learn.microsoft.com/en-us/azure/templates/microsoft.cache/redis?pivots=deployment-language-bicep#managedserviceidentity).')
param identity object = {
  type: 'SystemAssigned'
}

@description('The full resource ID of a subnet in a virtual network to deploy the Redis cache in. Example format: /subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/Microsoft.{Network|ClassicNetwork}/VirtualNetworks/vnet1/subnets/subnet1')
param subnetId string?

@description('The azure resource id of the log analytics workspace to log any diagnostics to.')
@minLength(0)
param logAnalyticsWorkspaceResourceId string?

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

@description('Authentication to Redis through access keys is disabled when set as true. Default value is false.')
param disableAccessKeyAuthentication bool = true

@description('Specifies whether Entra/AAD based authentication has been enabled or disabled for the cache. Default is true.')
param enableEntraBasedAuthentication bool = true

@description('''
The tags to apply to this resource. This is an object with key/value pairs. Resource may inherit tags from the ResourceGroup instead.
Example:
{
  FirstTag: myvalue
  SecondTag: another value
}
''')
param tags object = {}

@description('Property to allow or block all public traffic. Allowed Values: `Enabled`, `Disabled`.')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Disabled'

@description('''
Setting up roleassignments for the resource.
Example:
 [
  {
    roleDefinitionId: 'e0f68234-74aa-48ed-b826-c38b57376e17' // Redis Cache Contributor (Lets you manage Redis caches, but not access to them.)
    principalId: '74d905df-d648-4408-9b93-9bc3261b89ef'
    principalType: 'ServicePrincipal'
  }
]
''')
param roleAssignments roleAssignmentType[] = []

@description('Specifies whether the aof backup is enabled')
param aofBackupEnabled bool = false

@description('Specifies whether the rdb backup is enabled')
param rdbBackupEnabled bool = false

@description('Specifies the frequency for creating rdb backup in minutes. Valid values: (15, 30, 60, 360, 720, 1440).')
@allowed([
  15
  30
  60
  360
  720
  1440
])
param rdbBackupFrequency int = 15

@description('Specifies the maximum number of snapshots for rdb backup')
param rdbBackupMaxSnapshotCount int = 1

@description('''
The storage account connection string for storing rdb file.
Example (preferredDataPersistenceAuthMethod = ManagedIdentity): "https://[blob storage account hostname]"
Example (preferredDataPersistenceAuthMethod = SAS): "DefaultEndpointsProtocol=https;BlobEndpoint=https://[blob storage account hostname]/;AccountName=[storage account name];AccountKey=[key hidden]"
''')
param rdbStorageConnectionString string?

@description('''
The first storage account connection string for storing aof file.
Example (preferredDataPersistenceAuthMethod = ManagedIdentity): "https://[blob storage account hostname]"
Example (preferredDataPersistenceAuthMethod = SAS): "DefaultEndpointsProtocol=https;BlobEndpoint=https://[blob storage account hostname]/;AccountName=[storage account name];AccountKey=[key hidden]"
''')
param aofStorageConnectionString0 string?

@description('''
The optional second storage account connection string for storing aof file.
Example (preferredDataPersistenceAuthMethod = ManagedIdentity): "https://[blob storage account hostname]"
Example (preferredDataPersistenceAuthMethod = SAS): "DefaultEndpointsProtocol=https;BlobEndpoint=https://[blob storage account hostname]/;AccountName=[storage account name];AccountKey=[key hidden]"
''')
param aofStorageConnectionString1 string?

@description('Preferred auth method to communicate to storage account used for data persistence, specify SAS or ManagedIdentity, default value is ManagedIdentity')
@allowed([
  'SAS'
  'ManagedIdentity'
])
param preferredDataPersistenceAuthMethod string = 'ManagedIdentity'

@description('SubscriptionId of the storage account for persistence (aof/rdb) using ManagedIdentity. Defaults to the current subscription ID.')
param storageSubscriptionId string = subscription().subscriptionId

// ================================================= Variables =================================================
@description('The family for the sku. C = Basic/Standard, P = Premium.')
var redisCacheFamily = redisCacheSKU == 'Premium' ? 'P' : 'C'

// Only add vars if they're needed to prevent variables from failing with invalid values such as null.
var redisConfiguration = union(
  {
    'aad-enabled': enableEntraBasedAuthentication ? 'true' : 'false'
    'preferred-data-persistence-auth-method': preferredDataPersistenceAuthMethod
    'storage-subscription-id': storageSubscriptionId
  },
  aofBackupEnabled == true
    ? {
        'aof-backup-enabled': 'true'
        'aof-storage-connection-string-0': aofStorageConnectionString0
        'aof-storage-connection-string-1': aofStorageConnectionString1
      }
    : {},
  rdbBackupEnabled == true
    ? {
        'rdb-backup-enabled': 'true'
        'rdb-storage-connection-string': rdbStorageConnectionString
        'rdb-backup-frequency': '${rdbBackupFrequency}'
        'rdb-backup-max-snapshot-count': '${rdbBackupMaxSnapshotCount}'
      }
    : {}
)

// This will cause deployment to fail if the specified capacity is not supported for the given SKU.
var validateCapacity = redisCacheSKU == 'Premium' && redisCacheCapacity > 0 && redisCacheCapacity < 6
  ? true
  : fail('redisCacheCapacity must be between 1 and 5 (inclusive) when the SKU is set to Premium. Selected capacity: ${redisCacheCapacity}')

var builtInRoleNames = {
  Contributor: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
  Owner: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '8e3af657-a8ff-443c-a75c-2fe8c4bcb635')
  Reader: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'acdd72a7-3385-48ef-bd42-f606fba81ae7')
  'Redis Cache Contributor': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'e0f68234-74aa-48ed-b826-c38b57376e17'
  )
}

// ================================================= Resources =================================================
@description('Upsert the Redis cache and potential VNet integration with the given parameters.')
resource redisCache 'Microsoft.Cache/redis@2024-11-01' = {
  identity: identity
  location: location
  name: redisCacheName
  properties: {
    disableAccessKeyAuthentication: disableAccessKeyAuthentication
    enableNonSslPort: false
    minimumTlsVersion: '1.2'
    publicNetworkAccess: publicNetworkAccess
    subnetId: subnetId
    sku: {
      capacity: validateCapacity ? redisCacheCapacity : redisCacheCapacity // This ensures validation is evaluated
      family: redisCacheFamily
      name: redisCacheSKU
    }
    redisConfiguration: redisConfiguration
  }
  tags: tags
}

@description('Upsert the diagnostic settings for the Redis cache with the given parameters.')
resource redisCacheDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceResourceId)) {
  name: diagnosticsName
  scope: redisCache
  properties: {
    workspaceId: logAnalyticsWorkspaceResourceId
    logs: diagnosticSettingsLogsCategories
    metrics: diagnosticSettingsMetricsCategories
  }
}

resource redisCacheRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (roleAssignment, index) in roleAssignments: {
    name: guid(redisCache.id, roleAssignment.principalId, roleAssignment.roleDefinitionIdOrName)
    properties: {
      roleDefinitionId: contains(builtInRoleNames, roleAssignment.?roleDefinitionIdOrName)
        ? builtInRoleNames[roleAssignment.roleDefinitionIdOrName]
        : contains(roleAssignment.roleDefinitionIdOrName, '/providers/Microsoft.Authorization/roleDefinitions/')
            ? roleAssignment.roleDefinitionIdOrName
            : subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleAssignment.roleDefinitionIdOrName)
      principalId: roleAssignment.principalId
      description: roleAssignment.?description
      principalType: roleAssignment.?principalType
      condition: roleAssignment.?condition
      conditionVersion: !empty(roleAssignment.?condition) ? (roleAssignment.?conditionVersion ?? '2.0') : null // Must only be set if condtion is set
      delegatedManagedIdentityResourceId: roleAssignment.?delegatedManagedIdentityResourceId
    }
    scope: redisCache
  }
]

// ================================================= Outputs =================================================
@description('Output the resource name for this Azure Cache for Redis instance.')
output redisCacheName string = redisCache.name

@description('Output the resource id of this Azure Cache for Redis instance.')
output redisCacheResourceId string = redisCache.id

@description('Output the principal id of the managed identity for this Azure Cache for Redis instance.')
output redisCachePrincipalId string = redisCache.identity.principalId
