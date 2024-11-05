# bigDataPools

Target Scope: resourceGroup

## Synopsis
Create a Synapse Workspace Spark big data pool.

## Description
Create a Synapse Workspace firewall big data pool with the given specs.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| synapseWorkSpaceName | string | <input type="checkbox" checked> | None | <pre></pre> | Required. Name of the existing Synapse Workspace. |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| sparkPoolName | string | <input type="checkbox"> | Length between 0-15 | <pre>'sparkpoolname'</pre> |  |
| sparkAutoScaleEnabled | bool | <input type="checkbox"> | None | <pre>true</pre> | Optional. Enable Autoscale feature. |
| sparkAutoScaleMaxNodeCount | int | <input type="checkbox"> | Value between 3-200 | <pre>6</pre> | Optional. Maximum number of nodes to be allocated in the specified Spark pool. This parameter must be specified when Auto-scale is enabled. |
| sparkAutoScaleMinNodeCount | int | <input type="checkbox"> | Value between 3-199 | <pre>3</pre> | Optional. Minimum number of nodes to be allocated in the specified Spark pool. This parameter must be specified when Auto-Scale is enabled. |
| sparkIsolatedComputeEnabled | bool | <input type="checkbox"> | `false` | <pre>false</pre> | Optional. Whether compute isolation is required or not. (Feature not available in all regions) |
| sparkNodeCount | int | <input type="checkbox"> | None | <pre>1</pre> | Number of nodes to be allocated in the Spark pool (If Autoscale is not enabled) |
| sparkNodeSizeFamily | string | <input type="checkbox"> | `'MemoryOptimized'` or `'HardwareAccelerated'` | <pre>'MemoryOptimized'</pre> | Optional. The kind of nodes that the Spark Pool provides. |
| sparkNodeSize | string | <input type="checkbox"> | `'Small'` or `'Medium'` or `'Large'` or `'XLarge'` or `'XXLarge'` | <pre>'Medium'</pre> | Optional. The level of compute power that each node in the Big Data pool has. |
| sparkAutoPauseEnabled | bool | <input type="checkbox"> | None | <pre>true</pre> | Optional. Whether auto-pausing is enabled for the Big Data pool. |
| sparkAutoPauseDelayInMinutes | int | <input type="checkbox"> | None | <pre>7</pre> | Optional. Number of minutes of idle time before the Big Data pool is automatically paused. |
| sparkVersion | string | <input type="checkbox"> | `'3.3'` or `'3.2'` or `'3.1'` | <pre>'3.3'</pre> | Optional. The Apache Spark version. |
| sparkDynamicExecutorEnabled | bool | <input type="checkbox"> | None | <pre>true</pre> | Optional. Indicates whether Dynamic Executor Allocation is enabled or not |
| sparkMinExecutorCount | int | <input type="checkbox"> | Value between 1-198 | <pre>1</pre> | Optional. The minimum number of executors allocated |
| sparkMaxExecutorCount | int | <input type="checkbox"> | Value between 2-199 | <pre>3</pre> | Optional. The Maximum number of executors allocated |
| sparkCacheSize | int | <input type="checkbox"> | Value between 0-100 | <pre>25</pre> | Optional. The allocated Cache Size (in percentage) |
| sparkConfigPropertiesFileName | string | <input type="checkbox"> | None | <pre>''</pre> | Optional. The filename of the spark config properties file. |
| sparkConfigPropertiesContent | string | <input type="checkbox"> | None | <pre>''</pre> | Optional. The spark config properties. |
| sessionLevelPackagesEnabled | bool | <input type="checkbox"> | None | <pre>false</pre> | Optional. Whether session level packages enabled.	 |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| sparkPoolName | string | Output the name of the Spark Pool. |
| sparkPoolResourceId | string | Output the resourceId of the Spark Pool. |
| synapseWorkspaceName | string | Outputs the name of the existing Synapse workspace. |
| SynapseWorkSpaceResourceId | string | Outputs the resourceId of the existing Synapse workspace. |
| developmentEndpoint | string | Outputs the endpoint of the development endpoint of the existing Synapse workspace. |

## Examples
<pre>
module synapsebigdata 'br:contosoregistry.azurecr.io/synapse/workspaces/bigdatapools:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 50), 'synapsebdp')
  params: {
    synapseWorkSpaceName: 'synapsews'
    sparkPoolName: 'sparkpool'
  }
}
</pre>
<p>Creates an Synapse Analytics Workspace big data Pool.</p>

## Links
- [Bicep Microsoft.Synapse workspaces big data pools](https://learn.microsoft.com/en-us/azure/templates/microsoft.synapse/workspaces/bigdatapools?pivots=deployment-language-bicep)
