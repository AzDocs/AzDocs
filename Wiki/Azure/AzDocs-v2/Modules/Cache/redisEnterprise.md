# redisEnterprise

Target Scope: resourceGroup

## User Defined Types
| Name | Type | Discriminator | Description
| -- |  -- | -- | -- |
| <a id="accessPolicyAssignmentType">accessPolicyAssignmentType</a>  | <pre>{<br>&nbsp;&nbsp;&nbsp;@description('Object Id of the user, group or service principal to grant data-plane access to. Note that Azure Managed Redis does not resolve Entra group memberships, so assign individual principals.')<br>&nbsp;&nbsp;&nbsp;@minLength(36)<br>&nbsp;&nbsp;&nbsp;@maxLength(36)<br>&nbsp;&nbsp;&nbsp;principalId: string<br><br>&nbsp;&nbsp;&nbsp;@description('The name of the assignment resource. Defaults to the principalId when omitted.')<br>&nbsp;&nbsp;&nbsp;name: string?<br>}<br></pre> |  |  | 
| <a id="persistenceType">persistenceType</a>  | <pre>{<br>&nbsp;&nbsp;&nbsp;@description('Sets whether AOF persistence is enabled. At most one of AOF or RDB persistence may be enabled.')<br>&nbsp;&nbsp;&nbsp;aofEnabled: bool?<br><br>&nbsp;&nbsp;&nbsp;@description('The frequency at which data is written to disk when AOF persistence is enabled.')<br>&nbsp;&nbsp;&nbsp;aofFrequency: ('1s' &#124; 'always')?<br><br>&nbsp;&nbsp;&nbsp;@description('Sets whether RDB persistence is enabled. At most one of AOF or RDB persistence may be enabled.')<br>&nbsp;&nbsp;&nbsp;rdbEnabled: bool?<br><br>&nbsp;&nbsp;&nbsp;@description('The frequency at which a snapshot of the database is created when RDB persistence is enabled.')<br>&nbsp;&nbsp;&nbsp;rdbFrequency: ('1h' &#124; '6h' &#124; '12h')?<br>}<br></pre> |  |  | 
| <a id="redisModuleType">redisModuleType</a>  | <pre>{<br>&nbsp;&nbsp;&nbsp;@description('The name of the redis module, for example `RedisBloom`, `RediSearch` or `RedisTimeSeries`.')<br>&nbsp;&nbsp;&nbsp;name: string<br><br>&nbsp;&nbsp;&nbsp;@description('Configuration options for the module, for example `ERROR_RATE 0.01 INITIAL_SIZE 400`.')<br>&nbsp;&nbsp;&nbsp;args: string?<br>}<br></pre> |  |  | 

## Synopsis
Creates an Azure Managed Redis (Redis Enterprise) cluster

## Description
Creates a Microsoft.Cache/redisEnterprise cluster with its required default database. Azure Managed Redis<br>
and Azure Cache for Redis Enterprise share this resource type; the SKU decides which product you get.<br>
The Balanced, MemoryOptimized, ComputeOptimized and FlashOptimized SKUs are Azure Managed Redis, the<br>
Enterprise and EnterpriseFlash SKUs are Azure Cache for Redis Enterprise. A cluster without a database<br>
does not serve traffic, so the database is always created alongside the cluster.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. |
| redisEnterpriseName | string | <input type="checkbox" checked> | Length between 1-60 | <pre></pre> | The name of the Azure Managed Redis cluster. Letters, numbers and dashes only; it cannot start or end with a dash. |
| skuName | string | <input type="checkbox" checked> | `'Balanced_B0'` or `'Balanced_B1'` or `'Balanced_B3'` or `'Balanced_B5'` or `'Balanced_B10'` or `'Balanced_B20'` or `'Balanced_B50'` or `'Balanced_B100'` or `'Balanced_B150'` or `'Balanced_B250'` or `'Balanced_B350'` or `'Balanced_B500'` or `'Balanced_B700'` or `'Balanced_B1000'` or `'MemoryOptimized_M10'` or `'MemoryOptimized_M20'` or `'MemoryOptimized_M50'` or `'MemoryOptimized_M100'` or `'MemoryOptimized_M150'` or `'MemoryOptimized_M250'` or `'MemoryOptimized_M350'` or `'MemoryOptimized_M500'` or `'MemoryOptimized_M700'` or `'MemoryOptimized_M1000'` or `'MemoryOptimized_M1500'` or `'MemoryOptimized_M2000'` or `'ComputeOptimized_X3'` or `'ComputeOptimized_X5'` or `'ComputeOptimized_X10'` or `'ComputeOptimized_X20'` or `'ComputeOptimized_X50'` or `'ComputeOptimized_X100'` or `'ComputeOptimized_X150'` or `'ComputeOptimized_X250'` or `'ComputeOptimized_X350'` or `'ComputeOptimized_X500'` or `'ComputeOptimized_X700'` or `'FlashOptimized_A250'` or `'FlashOptimized_A500'` or `'FlashOptimized_A700'` or `'FlashOptimized_A1000'` or `'FlashOptimized_A1500'` or `'FlashOptimized_A2000'` or `'FlashOptimized_A4500'` or `'Enterprise_E1'` or `'Enterprise_E5'` or `'Enterprise_E10'` or `'Enterprise_E20'` or `'Enterprise_E50'` or `'Enterprise_E100'` or `'Enterprise_E200'` or `'Enterprise_E400'` or `'EnterpriseFlash_F300'` or `'EnterpriseFlash_F700'` or `'EnterpriseFlash_F1500'` | <pre></pre> | The SKU to deploy. The `Balanced_*`, `MemoryOptimized_*`, `ComputeOptimized_*` and `FlashOptimized_*` SKUs are<br>Azure Managed Redis. The `Enterprise_*` and `EnterpriseFlash_*` SKUs are Azure Cache for Redis Enterprise and are<br>the only ones that use `skuCapacity`. |
| skuCapacity | int? | <input type="checkbox" checked> | None | <pre></pre> | The size of the cluster. Only used by the `Enterprise_*` and `EnterpriseFlash_*` SKUs: valid values are (2, 4, 6, ...) for Enterprise and (3, 9, 15, ...) for EnterpriseFlash. Ignored for every Azure Managed Redis SKU. |
| highAvailability | string | <input type="checkbox"> | `'Enabled'` or `'Disabled'` | <pre>'Enabled'</pre> | Replicates the data set to protect against node loss. Only applies to the Azure Managed Redis SKUs. Disabling it lowers the availability SLA and increases the risk of data loss, which is why it defaults to `Enabled`. Note that the smallest SKUs, such as `Balanced_B0`, do not support high availability. |
| minimumTlsVersion | string | <input type="checkbox"> | `'1.2'` | <pre>'1.2'</pre> | The minimum TLS version the cluster accepts. TLS 1.0 and 1.1 are obsolete and cannot be used. |
| publicNetworkAccess | string | <input type="checkbox"> | `'Enabled'` or `'Disabled'` | <pre>'Disabled'</pre> | Property to allow or block all public traffic. Allowed Values: `Enabled`, `Disabled`. |
| identity | object | <input type="checkbox"> | None | <pre>{<br>  type: 'SystemAssigned'<br>}</pre> | Managed service identity to use for this cluster. Defaults to a system assigned managed identity. For object format, refer to [documentation](https://learn.microsoft.com/en-us/azure/templates/microsoft.cache/redisenterprise?pivots=deployment-language-bicep#managedserviceidentity). |
| encryption | object | <input type="checkbox"> | None | <pre>{}</pre> | Encryption-at-rest configuration. An empty object means Microsoft-managed key encryption, which is the default. For customer-managed keys, refer to [documentation](https://learn.microsoft.com/en-us/azure/templates/microsoft.cache/redisenterprise?pivots=deployment-language-bicep#clusterpropertiesencryption). |
| zones | string[] | <input type="checkbox"> | None | <pre>[]</pre> | The availability zones to spread the cluster across. Leave empty to let the platform decide. Not every SKU and region supports zones. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs. Resource may inherit tags from the ResourceGroup instead.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| redisEnterpriseDatabaseName | string | <input type="checkbox"> | Length between 1-60 | <pre>'default'</pre> | The name of the database to create on the cluster. Azure Managed Redis supports exactly one database and it must be named `default`. |
| clientProtocol | string | <input type="checkbox"> | `'Encrypted'` or `'Plaintext'` | <pre>'Encrypted'</pre> | Whether clients connect over a TLS-encrypted or a plaintext redis protocol. Defaults to encrypted. |
| clusteringPolicy | string | <input type="checkbox"> | `'EnterpriseCluster'` or `'NoCluster'` or `'OSSCluster'` | <pre>'OSSCluster'</pre> | The clustering policy of the database. `OSSCluster` is the default and cannot be changed after creation without deleting the database. Use `EnterpriseCluster` for clients that do not speak the OSS cluster protocol. |
| evictionPolicy | string | <input type="checkbox"> | `'AllKeysLFU'` or `'AllKeysLRU'` or `'AllKeysRandom'` or `'NoEviction'` or `'VolatileLFU'` or `'VolatileLRU'` or `'VolatileRandom'` or `'VolatileTTL'` | <pre>'VolatileLRU'</pre> | The redis eviction policy applied when the database reaches its memory limit. |
| redisEnterpriseDatabasePort | int | <input type="checkbox"> | None | <pre>10000</pre> | TCP port of the database endpoint. Azure Managed Redis listens on 10000 by default, which differs from the 6380 used by Azure Cache for Redis. |
| accessKeysAuthentication | string | <input type="checkbox"> | `'Enabled'` or `'Disabled'` | <pre>'Disabled'</pre> | Allows or denies access with the access keys. Defaults to `Disabled` so that only Entra based authentication is accepted. Only applies to the Azure Managed Redis SKUs. |
| deferUpgrade | string | <input type="checkbox"> | `'Deferred'` or `'NotDeferred'` | <pre>'NotDeferred'</pre> | Whether to defer the upgrade when a newer redis version is released. Refer to [documentation](https://aka.ms/redisversionupgrade). |
| redisModules | [redisModuleType](#redisModuleType)[] | <input type="checkbox"> | None | <pre>[]</pre> | Optional set of redis modules to enable on the database. Modules can only be added at creation time. |
| persistence | [persistenceType](#persistenceType)? | <input type="checkbox" checked> | None | <pre></pre> | Persistence settings for the database. At most one of AOF or RDB persistence may be enabled. |
| logAnalyticsWorkspaceResourceId | string? | <input type="checkbox" checked> | Length between 0-* | <pre></pre> | The azure resource id of the log analytics workspace to log any diagnostics to. |
| diagnosticsName | string | <input type="checkbox"> | Length between 1-260 | <pre>'AzurePlatformCentralizedLogging'</pre> | The name of the diagnostics. This defaults to `AzurePlatformCentralizedLogging`. |
| diagnosticSettingsLogsCategories | diagnosticLogCategory[] | <input type="checkbox"> | None | <pre>[<br>  {<br>    categoryGroup: 'allLogs'<br>    enabled: true<br>  }<br>]</pre> | Which log categories to enable; This defaults to `allLogs`. For array/object format, please refer to [docs](https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep#logsettings). |
| diagnosticSettingsMetricsCategories | diagnosticMetricCategory[] | <input type="checkbox"> | None | <pre>[<br>  {<br>    category: 'AllMetrics'<br>    enabled: true<br>  }<br>]</pre> | Which Metrics categories to enable; This defaults to `AllMetrics`. For array/object format, please refer to [docs](https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep&pivots=deployment-language-bicep#metricsettings). |
| roleAssignments | roleAssignment[] | <input type="checkbox"> | None | <pre>[]</pre> | Setting up control-plane role assignments for the resource. These govern who may manage the cluster, not who may read or write data.<br>Example:<br>&nbsp;&nbsp;[<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;roleDefinitionIdOrName: 'Redis Cache Contributor'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;principalId: '74d905df-d648-4408-9b93-9bc3261b89ef'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;principalType: 'ServicePrincipal'<br>&nbsp;&nbsp;&nbsp;}<br>] |
| accessPolicyAssignments | [accessPolicyAssignmentType](#accessPolicyAssignmentType)[] | <input type="checkbox"> | None | <pre>[]</pre> | Setting up data-plane access for the database. Azure Managed Redis has a single built-in access policy called `default`,<br>which grants full access to all keys and commands; it has no reader or contributor equivalent. Entra groups are not<br>resolved, so assign individual principals.<br>Example:<br>&nbsp;&nbsp;[<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;principalId: '74d905df-d648-4408-9b93-9bc3261b89ef'<br>&nbsp;&nbsp;&nbsp;}<br>] |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| redisEnterpriseName | string | Output the resource name for this Azure Managed Redis cluster. |
| redisEnterpriseResourceId | string | Output the resource id of this Azure Managed Redis cluster. |
| redisEnterpriseHostName | string | Output the hostname of this Azure Managed Redis cluster. |
| redisEnterpriseDatabaseName | string | Output the name of the database on this Azure Managed Redis cluster. |
| redisEnterpriseDatabaseResourceId | string | Output the resource id of the database on this Azure Managed Redis cluster. |
| redisEnterpriseDatabasePort | int | Output the TCP port the database endpoint listens on. |
| redisEnterprisePrincipalId | string | Output the principal id of the managed identity for this Azure Managed Redis cluster. |

## Examples
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

## Links
- [Bicep Microsoft.Cache redisEnterprise](https://learn.microsoft.com/en-us/azure/templates/microsoft.cache/redisenterprise?pivots=deployment-language-bicep)<br>
- [Bicep Microsoft.Cache redisEnterprise/databases](https://learn.microsoft.com/en-us/azure/templates/microsoft.cache/redisenterprise/databases?pivots=deployment-language-bicep)<br>
- [Use Microsoft Entra for cache authentication with Azure Managed Redis](https://learn.microsoft.com/en-us/azure/redis/entra-for-authentication)<br>
- [Azure Managed Redis overview](https://learn.microsoft.com/en-us/azure/redis/overview)
