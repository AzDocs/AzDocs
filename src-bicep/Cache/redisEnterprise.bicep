/*
.SYNOPSIS
Creates an Azure Managed Redis (Redis Enterprise) cluster
.DESCRIPTION
Creates a Microsoft.Cache/redisEnterprise cluster with its required default database. Azure Managed Redis
and Azure Cache for Redis Enterprise share this resource type; the SKU decides which product you get.
The Balanced, MemoryOptimized, ComputeOptimized and FlashOptimized SKUs are Azure Managed Redis, the
Enterprise and EnterpriseFlash SKUs are Azure Cache for Redis Enterprise. A cluster without a database
does not serve traffic, so the database is always created alongside the cluster.
.EXAMPLE
<pre>
module redisEnterprise 'br:contosoregistry.azurecr.io/cache/redisenterprise:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 46), 'redisenterprise')
  params: {
    redisEnterpriseName: redisEnterpriseName
    skuName: 'Balanced_B0'
    accessPolicyAssignments: [
      {
        principalId: '74d905df-d648-4408-9b93-9bc3261b89ef'
      }
    ]
  }
}
</pre>
<p>Creates an Azure Managed Redis cluster named 'redisEnterpriseName' with a default database on port 10000</p>
<p>
Public network access defaults to Disabled, so pair this with a private endpoint. Deploy
'network/privateendpoints' alongside it, passing the redisEnterpriseResourceId output as
targetResourceId and 'redisEnterprise' as the privateEndpointGroupId. That group id is not the one
Azure Cache for Redis uses ('redisCache'), and the two resolve to different private DNS zones, so
picking the wrong one fails when a client connects rather than when the deployment runs.
</p>
<p>
Opening only the database port is not enough under the default OSSCluster policy. A client makes its
first connection on the database port (10000) and then connects to each shard directly on a port in
the 8500-8599 range, discovered through CLUSTER NODES. Those shard ports reach the same private
endpoint IP, so a network rule can stay pinned to that one address, but it must cover both 10000 and
8500-8599. A rule that allows only 10000 lets the client connect and then fail on its first command.
Set clusteringPolicy to EnterpriseCluster if a single port is worth more than the throughput: that
routes everything through one endpoint on 10000. The policy cannot be changed after creation without
deleting the database.
</p>
.LINKS
- [Bicep Microsoft.Cache redisEnterprise](https://learn.microsoft.com/en-us/azure/templates/microsoft.cache/redisenterprise?pivots=deployment-language-bicep)
- [Bicep Microsoft.Cache redisEnterprise/databases](https://learn.microsoft.com/en-us/azure/templates/microsoft.cache/redisenterprise/databases?pivots=deployment-language-bicep)
- [Use Microsoft Entra for cache authentication with Azure Managed Redis](https://learn.microsoft.com/en-us/azure/redis/entra-for-authentication)
- [Azure Managed Redis overview](https://learn.microsoft.com/en-us/azure/redis/overview)
*/

// ================================================= Imports =================================================
import { diagnosticLogCategory, diagnosticMetricCategory } from '../Common/diagnosticTypes.bicep'
import { roleAssignment } from '../Common/authorizationTypes.bicep'

// ================================================= User-Defined Types =================================================
type accessPolicyAssignmentType = {
  @description('Object Id of the user, group or service principal to grant data-plane access to. Note that Azure Managed Redis does not resolve Entra group memberships, so assign individual principals.')
  @minLength(36)
  @maxLength(36)
  principalId: string

  @description('The name of the assignment resource. Defaults to the principalId when omitted.')
  name: string?
}

type persistenceType = {
  @description('Sets whether AOF persistence is enabled. At most one of AOF or RDB persistence may be enabled.')
  aofEnabled: bool?

  @description('The frequency at which data is written to disk when AOF persistence is enabled.')
  aofFrequency: ('1s' | 'always')?

  @description('Sets whether RDB persistence is enabled. At most one of AOF or RDB persistence may be enabled.')
  rdbEnabled: bool?

  @description('The frequency at which a snapshot of the database is created when RDB persistence is enabled.')
  rdbFrequency: ('1h' | '6h' | '12h')?
}

type redisModuleType = {
  @description('The name of the redis module, for example `RedisBloom`, `RediSearch` or `RedisTimeSeries`.')
  name: string

  @description('Configuration options for the module, for example `ERROR_RATE 0.01 INITIAL_SIZE 400`.')
  args: string?
}

// ================================================= Parameters =================================================
@description('Specifies the Azure location where the resource should be created.')
param location string = resourceGroup().location

@description('The name of the Azure Managed Redis cluster. Letters, numbers and dashes only; it cannot start or end with a dash.')
@minLength(1)
@maxLength(60)
param redisEnterpriseName string

@description('''
The SKU to deploy. The `Balanced_*`, `MemoryOptimized_*`, `ComputeOptimized_*` and `FlashOptimized_*` SKUs are
Azure Managed Redis. The `Enterprise_*` and `EnterpriseFlash_*` SKUs are Azure Cache for Redis Enterprise and are
the only ones that use `skuCapacity`.
''')
@allowed([
  'Balanced_B0'
  'Balanced_B1'
  'Balanced_B3'
  'Balanced_B5'
  'Balanced_B10'
  'Balanced_B20'
  'Balanced_B50'
  'Balanced_B100'
  'Balanced_B150'
  'Balanced_B250'
  'Balanced_B350'
  'Balanced_B500'
  'Balanced_B700'
  'Balanced_B1000'
  'MemoryOptimized_M10'
  'MemoryOptimized_M20'
  'MemoryOptimized_M50'
  'MemoryOptimized_M100'
  'MemoryOptimized_M150'
  'MemoryOptimized_M250'
  'MemoryOptimized_M350'
  'MemoryOptimized_M500'
  'MemoryOptimized_M700'
  'MemoryOptimized_M1000'
  'MemoryOptimized_M1500'
  'MemoryOptimized_M2000'
  'ComputeOptimized_X3'
  'ComputeOptimized_X5'
  'ComputeOptimized_X10'
  'ComputeOptimized_X20'
  'ComputeOptimized_X50'
  'ComputeOptimized_X100'
  'ComputeOptimized_X150'
  'ComputeOptimized_X250'
  'ComputeOptimized_X350'
  'ComputeOptimized_X500'
  'ComputeOptimized_X700'
  'FlashOptimized_A250'
  'FlashOptimized_A500'
  'FlashOptimized_A700'
  'FlashOptimized_A1000'
  'FlashOptimized_A1500'
  'FlashOptimized_A2000'
  'FlashOptimized_A4500'
  'Enterprise_E1'
  'Enterprise_E5'
  'Enterprise_E10'
  'Enterprise_E20'
  'Enterprise_E50'
  'Enterprise_E100'
  'Enterprise_E200'
  'Enterprise_E400'
  'EnterpriseFlash_F300'
  'EnterpriseFlash_F700'
  'EnterpriseFlash_F1500'
])
param skuName string

@description('The size of the cluster. Only used by the `Enterprise_*` and `EnterpriseFlash_*` SKUs: valid values are (2, 4, 6, ...) for Enterprise and (3, 9, 15, ...) for EnterpriseFlash. Ignored for every Azure Managed Redis SKU.')
param skuCapacity int?

@description('Replicates the data set to protect against node loss. Only applies to the Azure Managed Redis SKUs. Disabling it lowers the availability SLA and increases the risk of data loss, which is why it defaults to `Enabled`. Note that the smallest SKUs, such as `Balanced_B0`, do not support high availability.')
@allowed([
  'Enabled'
  'Disabled'
])
param highAvailability string = 'Enabled'

@description('The minimum TLS version the cluster accepts. TLS 1.0 and 1.1 are obsolete and cannot be used.')
@allowed([
  '1.2'
])
param minimumTlsVersion string = '1.2'

@description('Property to allow or block all public traffic. Allowed Values: `Enabled`, `Disabled`.')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Disabled'

@description('Managed service identity to use for this cluster. Defaults to a system assigned managed identity. For object format, refer to [documentation](https://learn.microsoft.com/en-us/azure/templates/microsoft.cache/redisenterprise?pivots=deployment-language-bicep#managedserviceidentity).')
param identity object = {
  type: 'SystemAssigned'
}

@description('Encryption-at-rest configuration. An empty object means Microsoft-managed key encryption, which is the default. For customer-managed keys, refer to [documentation](https://learn.microsoft.com/en-us/azure/templates/microsoft.cache/redisenterprise?pivots=deployment-language-bicep#clusterpropertiesencryption).')
param encryption object = {}

@description('The availability zones to spread the cluster across. Leave empty to let the platform decide. Not every SKU and region supports zones.')
param zones string[] = []

@description('''
The tags to apply to this resource. This is an object with key/value pairs. Resource may inherit tags from the ResourceGroup instead.
Example:
{
  FirstTag: myvalue
  SecondTag: another value
}
''')
param tags object = {}

@description('The name of the database to create on the cluster. Azure Managed Redis supports exactly one database and it must be named `default`.')
@minLength(1)
@maxLength(60)
param redisEnterpriseDatabaseName string = 'default'

@description('Whether clients connect over a TLS-encrypted or a plaintext redis protocol. Defaults to encrypted.')
@allowed([
  'Encrypted'
  'Plaintext'
])
param clientProtocol string = 'Encrypted'

@description('The clustering policy of the database. `OSSCluster` is the default and cannot be changed after creation without deleting the database. Use `EnterpriseCluster` for clients that do not speak the OSS cluster protocol.')
@allowed([
  'EnterpriseCluster'
  'NoCluster'
  'OSSCluster'
])
param clusteringPolicy string = 'OSSCluster'

@description('The redis eviction policy applied when the database reaches its memory limit.')
@allowed([
  'AllKeysLFU'
  'AllKeysLRU'
  'AllKeysRandom'
  'NoEviction'
  'VolatileLFU'
  'VolatileLRU'
  'VolatileRandom'
  'VolatileTTL'
])
param evictionPolicy string = 'VolatileLRU'

@description('TCP port of the database endpoint. Azure Managed Redis listens on 10000 by default, which differs from the 6380 used by Azure Cache for Redis.')
param redisEnterpriseDatabasePort int = 10000

@description('Allows or denies access with the access keys. Defaults to `Disabled` so that only Entra based authentication is accepted. Only applies to the Azure Managed Redis SKUs.')
@allowed([
  'Enabled'
  'Disabled'
])
param accessKeysAuthentication string = 'Disabled'

@description('Whether to defer the upgrade when a newer redis version is released. Refer to [documentation](https://aka.ms/redisversionupgrade).')
@allowed([
  'Deferred'
  'NotDeferred'
])
param deferUpgrade string = 'NotDeferred'

@description('Optional set of redis modules to enable on the database. Modules can only be added at creation time.')
param redisModules redisModuleType[] = []

@description('Persistence settings for the database. At most one of AOF or RDB persistence may be enabled.')
param persistence persistenceType?

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
  }
]

@description('Which Metrics categories to enable; This defaults to `AllMetrics`. For array/object format, please refer to [docs](https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep&pivots=deployment-language-bicep#metricsettings).')
param diagnosticSettingsMetricsCategories diagnosticMetricCategory[] = [
  {
    category: 'AllMetrics'
    enabled: true
  }
]

@description('''
Setting up control-plane role assignments for the resource. These govern who may manage the cluster, not who may read or write data.
Example:
 [
  {
    roleDefinitionIdOrName: 'Redis Cache Contributor'
    principalId: '74d905df-d648-4408-9b93-9bc3261b89ef'
    principalType: 'ServicePrincipal'
  }
]
''')
param roleAssignments roleAssignment[] = []

@description('''
Setting up data-plane access for the database. Azure Managed Redis has a single built-in access policy called `default`,
which grants full access to all keys and commands; it has no reader or contributor equivalent. Entra groups are not
resolved, so assign individual principals.
Example:
 [
  {
    principalId: '74d905df-d648-4408-9b93-9bc3261b89ef'
  }
]
''')
param accessPolicyAssignments accessPolicyAssignmentType[] = []

// ================================================= Variables =================================================
@description('The Azure Managed Redis SKUs, as opposed to the Azure Cache for Redis Enterprise ones. They differ in which properties the platform accepts.')
var isAzureManagedRedis = startsWith(skuName, 'Balanced_') || startsWith(skuName, 'MemoryOptimized_') || startsWith(skuName, 'ComputeOptimized_') || startsWith(skuName, 'FlashOptimized_')

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
@description('Upsert the Azure Managed Redis cluster with the given parameters.')
resource redisEnterprise 'Microsoft.Cache/redisEnterprise@2025-07-01' = {
  identity: identity
  location: location
  name: redisEnterpriseName
  properties: {
    encryption: encryption
    highAvailability: isAzureManagedRedis ? highAvailability : null
    minimumTlsVersion: minimumTlsVersion
    publicNetworkAccess: publicNetworkAccess
  }
  sku: {
    capacity: isAzureManagedRedis ? null : skuCapacity
    name: skuName
  }
  tags: tags
  zones: empty(zones) ? null : zones
}

@description('Upsert the database on the cluster. A cluster without a database does not serve traffic.')
resource redisEnterpriseDatabase 'Microsoft.Cache/redisEnterprise/databases@2025-07-01' = {
  parent: redisEnterprise
  name: redisEnterpriseDatabaseName
  properties: {
    accessKeysAuthentication: isAzureManagedRedis ? accessKeysAuthentication : null
    clientProtocol: clientProtocol
    clusteringPolicy: clusteringPolicy
    deferUpgrade: deferUpgrade
    evictionPolicy: evictionPolicy
    modules: redisModules
    persistence: persistence
    port: redisEnterpriseDatabasePort
  }
}

@description('Upsert the data-plane access policy assignments for the database with the given parameters.')
resource redisEnterpriseAccessPolicyAssignments 'Microsoft.Cache/redisEnterprise/databases/accessPolicyAssignments@2025-07-01' = [
  for accessPolicyAssignment in accessPolicyAssignments: {
    parent: redisEnterpriseDatabase
    name: accessPolicyAssignment.?name ?? accessPolicyAssignment.principalId
    properties: {
      accessPolicyName: 'default'
      user: {
        objectId: accessPolicyAssignment.principalId
      }
    }
  }
]

@description('Upsert the diagnostic settings for the cluster with the given parameters.')
resource redisEnterpriseDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceResourceId)) {
  name: diagnosticsName
  scope: redisEnterprise
  properties: {
    workspaceId: logAnalyticsWorkspaceResourceId
    logs: diagnosticSettingsLogsCategories
    metrics: diagnosticSettingsMetricsCategories
  }
}

resource redisEnterpriseRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for roleAssignment in roleAssignments: {
    name: uniqueString(redisEnterprise.id, roleAssignment.principalId, roleAssignment.roleDefinitionIdOrName)
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
    scope: redisEnterprise
  }
]

// ================================================= Outputs =================================================
@description('Output the resource name for this Azure Managed Redis cluster.')
output redisEnterpriseName string = redisEnterprise.name

@description('Output the resource id of this Azure Managed Redis cluster.')
output redisEnterpriseResourceId string = redisEnterprise.id

@description('Output the hostname of this Azure Managed Redis cluster.')
output redisEnterpriseHostName string = redisEnterprise.properties.hostName

@description('Output the name of the database on this Azure Managed Redis cluster.')
output redisEnterpriseDatabaseName string = redisEnterpriseDatabase.name

@description('Output the resource id of the database on this Azure Managed Redis cluster.')
output redisEnterpriseDatabaseResourceId string = redisEnterpriseDatabase.id

@description('Output the TCP port the database endpoint listens on.')
output redisEnterpriseDatabasePort int = redisEnterpriseDatabase.properties.port

@description('Output the principal id of the managed identity for this Azure Managed Redis cluster.')
output redisEnterprisePrincipalId string = redisEnterprise.identity.principalId
