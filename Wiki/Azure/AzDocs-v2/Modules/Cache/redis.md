# redis

Target Scope: resourceGroup

## User Defined Types
| Name | Type | Discriminator | Description
| -- |  -- | -- | -- |
| <a id="accessPolicyAssignmentType">accessPolicyAssignmentType</a>  | <pre>{</pre> |  |  | 

## Synopsis
Creates an Azure Cache for Redis instance

## Description
Creates an Azure Cache for Redis instance with the given specs.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. |
| redisCacheName | string | <input type="checkbox" checked> | Length between 2-60 | <pre></pre> | The name of the Azure Cache for Redis Instance. |
| redisCacheSKU | string | <input type="checkbox" checked> | `'Basic'` or `'Standard'` or `'Premium'` | <pre></pre> | Specify the pricing tier of the new Azure Redis Cache. |
| redisCacheCapacity | int | <input type="checkbox" checked> | `0` or `1` or `2` or `3` or `4` or `5` or `6` | <pre></pre> | Specify the size of the new Azure Redis Cache instance. Valid values: for C (Basic/Standard) family (0, 1, 2, 3, 4, 5, 6), for P (Premium) family (1, 2, 3, 4, 5) |
| identity | object | <input type="checkbox"> | None | <pre>{<br>  type: 'SystemAssigned'<br>}</pre> | Managed service identity to use for this Azure Cache for Redis Instance. Defaults to a system assigned managed identity. For object format, refer to [documentation](https://learn.microsoft.com/en-us/azure/templates/microsoft.cache/redis?pivots=deployment-language-bicep#managedserviceidentity). |
| subnetId | string? | <input type="checkbox" checked> | None | <pre></pre> | The full resource ID of a subnet in a virtual network to deploy the Redis cache in. Example format: /subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/Microsoft.{Network&#124;ClassicNetwork}/VirtualNetworks/vnet1/subnets/subnet1 |
| logAnalyticsWorkspaceResourceId | string? | <input type="checkbox" checked> | Length between 0-* | <pre></pre> | The azure resource id of the log analytics workspace to log any diagnostics to. |
| diagnosticsName | string | <input type="checkbox"> | Length between 1-260 | <pre>'AzurePlatformCentralizedLogging'</pre> | The name of the diagnostics. This defaults to `AzurePlatformCentralizedLogging`. |
| diagnosticSettingsLogsCategories | diagnosticLogCategory[] | <input type="checkbox"> | None | <pre>[<br>  {<br>    categoryGroup: 'allLogs'<br>    enabled: true<br>  }<br>]</pre> | Which log categories to enable; This defaults to `allLogs`. For array/object format, please refer to [docs](https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep#logsettings). |
| diagnosticSettingsMetricsCategories | diagnosticMetricCategory[] | <input type="checkbox"> | None | <pre>[<br>  {<br>    category: 'AllMetrics'<br>    enabled: true<br>  }<br>]</pre> | Which Metrics categories to enable; This defaults to `AllMetrics`. For array/object format, please refer to [docs](https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep&pivots=deployment-language-bicep#metricsettings). |
| disableAccessKeyAuthentication | bool | <input type="checkbox"> | None | <pre>true</pre> | Authentication to Redis through access keys is disabled when set as true. Default value is false. |
| enableEntraBasedAuthentication | bool | <input type="checkbox"> | None | <pre>true</pre> | Specifies whether Entra/AAD based authentication has been enabled or disabled for the cache. Default is true. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs. Resource may inherit tags from the ResourceGroup instead.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| publicNetworkAccess | string | <input type="checkbox"> | `'Enabled'` or `'Disabled'` | <pre>'Disabled'</pre> | Property to allow or block all public traffic. Allowed Values: `Enabled`, `Disabled`. |
| roleAssignments | roleAssignment[] | <input type="checkbox"> | None | <pre>[]</pre> | Setting up role assignments for the resource.<br>Example:<br>&nbsp;&nbsp;[<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;roleDefinitionId: 'e0f68234-74aa-48ed-b826-c38b57376e17' // Redis Cache Contributor (Lets you manage Redis caches, but not access to them.)<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;principalId: '74d905df-d648-4408-9b93-9bc3261b89ef'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;principalType: 'ServicePrincipal'<br>&nbsp;&nbsp;&nbsp;}<br>] |
| accessPolicyAssignments | accessPolicyAssignmentType[] | <input type="checkbox"> | None | <pre>[]</pre> | Setting up access policy assignments for the resource.<br>Example:<br>&nbsp;&nbsp;[<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;accessPolicyName: 'Data Reader'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;principalId: '74d905df-d648-4408-9b93-9bc3261b89ef'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;principalIdAlias: 'principal-alias'<br>&nbsp;&nbsp;&nbsp;}<br>] |
| aofBackupEnabled | bool | <input type="checkbox"> | None | <pre>false</pre> | Specifies whether the aof backup is enabled |
| rdbBackupEnabled | bool | <input type="checkbox"> | None | <pre>false</pre> | Specifies whether the rdb backup is enabled |
| rdbBackupFrequency | int | <input type="checkbox"> | `15` or `30` or `60` or `360` or `720` or `1440` | <pre>15</pre> | Specifies the frequency for creating rdb backup in minutes. Valid values: (15, 30, 60, 360, 720, 1440). |
| rdbBackupMaxSnapshotCount | int | <input type="checkbox"> | None | <pre>1</pre> | Specifies the maximum number of snapshots for rdb backup |
| rdbStorageConnectionString | string? | <input type="checkbox" checked> | None | <pre></pre> | The storage account connection string for storing rdb file.<br>Example (preferredDataPersistenceAuthMethod = ManagedIdentity): "https://[blob storage account hostname]"<br>Example (preferredDataPersistenceAuthMethod = SAS): "DefaultEndpointsProtocol=https;BlobEndpoint=https://[blob storage account hostname]/;AccountName=[storage account name];AccountKey=[key hidden]" |
| aofStorageConnectionString0 | string? | <input type="checkbox" checked> | None | <pre></pre> | The first storage account connection string for storing aof file.<br>Example (preferredDataPersistenceAuthMethod = ManagedIdentity): "https://[blob storage account hostname]"<br>Example (preferredDataPersistenceAuthMethod = SAS): "DefaultEndpointsProtocol=https;BlobEndpoint=https://[blob storage account hostname]/;AccountName=[storage account name];AccountKey=[key hidden]" |
| aofStorageConnectionString1 | string? | <input type="checkbox" checked> | None | <pre></pre> | The optional second storage account connection string for storing aof file.<br>Example (preferredDataPersistenceAuthMethod = ManagedIdentity): "https://[blob storage account hostname]"<br>Example (preferredDataPersistenceAuthMethod = SAS): "DefaultEndpointsProtocol=https;BlobEndpoint=https://[blob storage account hostname]/;AccountName=[storage account name];AccountKey=[key hidden]" |
| preferredDataPersistenceAuthMethod | string | <input type="checkbox"> | `'SAS'` or `'ManagedIdentity'` | <pre>'ManagedIdentity'</pre> | Preferred auth method to communicate to storage account used for data persistence, specify SAS or ManagedIdentity, default value is ManagedIdentity |
| storageSubscriptionId | string | <input type="checkbox"> | None | <pre>subscription().subscriptionId</pre> | SubscriptionId of the storage account for persistence (aof/rdb) using ManagedIdentity. Defaults to the current subscription ID. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| redisCacheName | string | Output the resource name for this Azure Cache for Redis instance. |
| redisCacheResourceId | string | Output the resource id of this Azure Cache for Redis instance. |
| redisCachePrincipalId | string | Output the principal id of the managed identity for this Azure Cache for Redis instance. |

## Examples
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

## Links
- [Bicep Microsoft.Cache redis](https://learn.microsoft.com/en-us/azure/templates/microsoft.cache/redis?pivots=deployment-language-bicep)<br>
- [Quickstart: Create an Azure Cache for Redis using Bicep](https://learn.microsoft.com/en-us/azure/redis/redis-cache-bicep-provision?tabs=CLI)
