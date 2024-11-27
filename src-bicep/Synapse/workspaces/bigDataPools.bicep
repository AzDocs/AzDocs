/*
.SYNOPSIS
Create a Synapse Workspace Spark big data pool.
.DESCRIPTION
Create a Synapse Workspace firewall big data pool with the given specs.
.EXAMPLE
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
.LINKS
- [Bicep Microsoft.Synapse workspaces big data pools](https://learn.microsoft.com/en-us/azure/templates/microsoft.synapse/workspaces/bigdatapools?pivots=deployment-language-bicep)
*/
// ================================================= Parameters =================================================
@description('Required. Name of the existing Synapse Workspace.')
param synapseWorkSpaceName string

@description('Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location.')
param location string = resourceGroup().location

@description('''
The tags to apply to this resource. This is an object with key/value pairs.
Example:
{
  FirstTag: myvalue
  SecondTag: another value
}
''')
param tags object = {}

@maxLength(15)
param sparkPoolName string = 'sparkpoolname'

@description('Optional. Enable Autoscale feature.')
param sparkAutoScaleEnabled bool = true

@description('Optional. Maximum number of nodes to be allocated in the specified Spark pool. This parameter must be specified when Auto-scale is enabled.')
@maxValue(200)
@minValue(3)
param sparkAutoScaleMaxNodeCount int = 6

@description('Optional. Minimum number of nodes to be allocated in the specified Spark pool. This parameter must be specified when Auto-Scale is enabled.')
@maxValue(199)
@minValue(3)
param sparkAutoScaleMinNodeCount int = 3

@description('Optional. Whether compute isolation is required or not. (Feature not available in all regions)')
@allowed([
  false
])
param sparkIsolatedComputeEnabled bool = false

@description('Number of nodes to be allocated in the Spark pool (If Autoscale is not enabled)')
param sparkNodeCount int = 1

@description('Optional. The kind of nodes that the Spark Pool provides.')
@allowed([
  'MemoryOptimized'
  'HardwareAccelerated'
])
param sparkNodeSizeFamily string = 'MemoryOptimized'

@description('Optional. The level of compute power that each node in the Big Data pool has.')
@allowed([
  'Small'
  'Medium'
  'Large'
  'XLarge'
  'XXLarge'
])
param sparkNodeSize string = 'Medium'

@description('Optional. Whether auto-pausing is enabled for the Big Data pool.')
param sparkAutoPauseEnabled bool = true

@description('Optional. Number of minutes of idle time before the Big Data pool is automatically paused.')
param sparkAutoPauseDelayInMinutes int = 7

@description('Optional. The Apache Spark version.')
@allowed([
  '3.3'
  '3.2'
  '3.1'
])
param sparkVersion string = '3.3'

@description('Optional. Indicates whether Dynamic Executor Allocation is enabled or not')
param sparkDynamicExecutorEnabled bool = true

@description('Optional. The minimum number of executors allocated')
@minValue(1)
@maxValue(198)
param sparkMinExecutorCount int = 1

@description('Optional. The Maximum number of executors allocated')
@minValue(2)
@maxValue(199)
param sparkMaxExecutorCount int = 3

@description('Optional. The allocated Cache Size (in percentage)')
@minValue(0)
@maxValue(100)
param sparkCacheSize int = 25

@description('Optional. The filename of the spark config properties file.')
param sparkConfigPropertiesFileName string = ''

@description('Optional. The spark config properties.')
param sparkConfigPropertiesContent string = ''

@description('Optional. Whether session level packages enabled.	')
param sessionLevelPackagesEnabled bool = false

// ================================================= Existing Resources ========================================
@description('Existing Synapse Workspace')
resource synapseWorkspace 'Microsoft.Synapse/workspaces@2021-06-01' existing = {
  name: synapseWorkSpaceName
}

// ================================================= Resources =================================================
resource sparkPool 'Microsoft.Synapse/workspaces/bigDataPools@2021-06-01' = {
  parent: synapseWorkspace
  name: sparkPoolName
  location: location
  tags: tags
  properties: {
    nodeCount: !sparkAutoScaleEnabled ? sparkNodeCount : 0
    nodeSizeFamily: sparkNodeSizeFamily
    nodeSize: sparkNodeSize
    autoScale: {
      enabled: sparkAutoScaleEnabled
      minNodeCount: sparkAutoScaleEnabled ? sparkAutoScaleMinNodeCount : null
      maxNodeCount: sparkAutoScaleEnabled ? sparkAutoScaleMaxNodeCount : null
    }
    autoPause: {
      enabled: sparkAutoPauseEnabled
      delayInMinutes: sparkAutoPauseDelayInMinutes
    }
    sparkVersion: sparkVersion
    sparkConfigProperties: {
      filename: sparkConfigPropertiesFileName
      content: sparkConfigPropertiesContent
    }
    isComputeIsolationEnabled: sparkIsolatedComputeEnabled
    sessionLevelPackagesEnabled: sessionLevelPackagesEnabled
    dynamicExecutorAllocation: {
      enabled: sparkDynamicExecutorEnabled
      minExecutors: sparkMinExecutorCount
      maxExecutors: sparkMaxExecutorCount
    }
    // To investigate the cacheSize related warning - 'Warning: BCP073 The Property CacheSize is ReadOnly'
    cacheSize: sparkCacheSize
  }
}

@description('Output the name of the Spark Pool.')
output sparkPoolName string = sparkPool.name
@description('Output the resourceId of the Spark Pool.')
output sparkPoolResourceId string = sparkPool.id
@description('Outputs the name of the existing Synapse workspace.')
output synapseWorkspaceName string = synapseWorkspace.name
@description('Outputs the resourceId of the existing Synapse workspace.')
output SynapseWorkSpaceResourceId string = synapseWorkspace.id
@description('Outputs the endpoint of the development endpoint of the existing Synapse workspace.')
output developmentEndpoint string = synapseWorkspace.properties.connectivityEndpoints.dev
