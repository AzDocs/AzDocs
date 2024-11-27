/*
.SYNOPSIS
Creating an AKS Agent Pool.
.DESCRIPTION
Creating an AKS Agent Nodepool with the given specs.
.EXAMPLE
<pre>
module agentpool 'br:contosoregistry.azurecr.io/containerservice/managedclusters/agentpools:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 47), 'aksagentpool')
  params: {
    aksName: aksName
    aksPoolName: 'myuserpool'
  }
}
</pre>
<p>Creates an aks agentpool called 'myuserpool' in an existing aks cluster.</p>
.LINKS
- [Bicep Microsoft.ContainerService managedclusters agentpools](https://learn.microsoft.com/en-us/azure/templates/microsoft.containerservice/managedclusters/agentpools?pivots=deployment-language-bicep)
*/

// ================================================= Parameters =================================================
@description('The name of the existing AKS.')
param aksName string

@description('The name of the agent pool to upsert in the AKS.')
@minLength(1)
@maxLength(12)
param aksPoolName string

@description('''
The zones to use for a node pool
Example:
[
  '1'
  '2'
  '3'
]
''')
@maxLength(3)
param availabilityZones array = []

@description('''
The sku for the system Vm Nodes used in the cluster. VM size availability varies by region.
If a node contains insufficient compute resources (memory, cpu, etc) pods might fail to run correctly. For more details on restricted VM sizes, see: [link](https://docs.microsoft.com/azure/aks/quotas-skus-regions)
''')
param aksNodeVmSize string = 'Standard_D4ds_v5'

@description('''
The size of the OS Disk of the Vms used for the nodes. OS Disk Size in GB to be used to specify the disk size for every machine in the agent pool.
If you specify 0, it will apply the default osDisk size according to the vmSize specified.
''')
param osDiskSizeGB int = 0

@description('''
The number of agents for the user node poolNumber of agents (VMs) to host docker containers.
Allowed values must be in the range of 0 to 1000 (inclusive) for user pools. The default value is 1.
''')
@minValue(0)
@maxValue(1000)
param agentCount int = 1

@description('The maximum number of nodes for the user node pool')
param agentCountMax int = 3
var autoScale = agentCountMax > agentCount

@description('This also effects the cluster autoscaler behavior. If not specified, it defaults to Delete.')
@allowed([
  'Delete'
  'DeAllocate'
])
param aksNodeScaleDownMode string = 'Delete'

@description('The maximum number of pods that can run on a node. The Kubenet default is 110, Azure CNI default is 30.')
@minValue(10)
@maxValue(250)
param aksNodeMaxPods int = 110

@description('The taints added to new nodes during node pool create and scale. For example, key=value:NoSchedule,eg CoreOnly=true:NoSchedule.')
param nodeTaints array = []
var taints = autoTaintWindows ? union(nodeTaints, ['sku=Windows:NoSchedule']) : nodeTaints

@description('''
Any labels that should be applied to the node pool
Example:
{
  'node.kubernetes.io/component': 'Supplementary'
}
''')
param nodeLabels object = {}

@description('OS Type for the node pool')
@allowed([
  'Linux'
  'Windows'
])
param nodePoolVmOsType string = 'Linux'

@description('''
Specifies the OS SKU used by the agent pool. If not specified, the default is Ubuntu if OSType=Linux or Windows2019 if OSType=Windows.
And the default Windows OSSKU will be changed to Windows2022 after Windows2019 is deprecated.
''')
param nodePoolVmOsSKU string = nodePoolVmOsType == 'Linux' ? 'Ubuntu' : 'Windows'

@description('''
Define a block of public IPs for nodes.
This is of the form: /subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Network/publicIPPrefixes/{publicIPPrefixName}
''')
param nodePublicIPPrefixID string = ''

@description('Assign a public IP per node')
param enableNodePublicIP bool = false

@description('Apply a default sku taint to Windows node pools')
param autoTaintWindows bool = false

@description('A cluster must have already at least one \'System\' Agent Pool at all times. For additional information on agent pool restrictions and best practices, see: /azure/aks/use-system-pools')
param aksNodePoolMode string = 'User'

@description('The type of AKS nodepool.')
@allowed([
  'VirtualMachineScaleSets'
  'AvailabilitySet'
])
param aksNodePoolType string = 'VirtualMachineScaleSets'

@description('''
This can either be set to an integer (e.g. '5') or a percentage (e.g. '50%'). If a percentage is specified, it is the percentage of the total agent pool size at the time of the upgrade.
For percentages, fractional nodes are rounded up. If not specified, the default is 1. For more information, including best practices, see: [info](https://learn.microsoft.com/en-us/azure/aks/upgrade-cluster?tabs=azure-cli).
For production node pools, it is recommended to use a max-surge setting of 33%.
''')
param upgradeSettingsMaxSurge string = '33%'

@description('''
Whether the Disks of the VMs should have encryption at host. This is only supported on certain VM sizes and in certain Azure regions. For more [information](https://docs.microsoft.com/azure/aks/enable-host-encryption).
''')
param enableEncryptionAtHost bool = true

@description('Determines the placement of emptyDir volumes, container runtime data root, and Kubelet ephemeral storage.')
@allowed([
  'OS'
  'Temporary'
])
param aksNodeKubeletDiskType string = 'OS'

@description('Whether to enable UltraSSD.')
param enableUltraSSD bool = false

@description('The Kubelet configuration on the agent pool nodes.')
param kubeletConfig object = {}

@description('''
The subnet the node pool will use. If you are using byo subnet, this id should be the same subnet as the system pool is using
or at least a subnet in the same resourcegroup using the same routetable as the system node.
''')
param vnetSubnetID string = ''

@description('The OS configuration of Linux agent nodes.')
param linuxOSConfig object = {}

@description('The already existing AKS cluster.')
resource aks 'Microsoft.ContainerService/managedClusters@2023-05-01' existing = {
  name: aksName
}

resource agentPool 'Microsoft.ContainerService/managedClusters/agentPools@2023-06-01' = {
  parent: aks
  name: aksPoolName
  properties: {
    availabilityZones: !empty(availabilityZones) ? availabilityZones : null
    count: agentCount
    enableAutoScaling: autoScale
    enableEncryptionAtHost: enableEncryptionAtHost
    enableNodePublicIP: !empty(nodePublicIPPrefixID) ? true : enableNodePublicIP
    enableUltraSSD: enableUltraSSD
    kubeletConfig: !empty(kubeletConfig) ? kubeletConfig : null //TODO can be empty object or null?
    kubeletDiskType: aksNodeKubeletDiskType
    linuxOSConfig: !empty(linuxOSConfig) ? linuxOSConfig : null
    maxCount: autoScale ? agentCountMax : null
    maxPods: aksNodeMaxPods
    minCount: autoScale ? agentCount : null
    mode: aksNodePoolMode
    nodeLabels: nodeLabels
    nodeTaints: taints
    nodePublicIPPrefixID: !empty(nodePublicIPPrefixID) ? nodePublicIPPrefixID : null
    osDiskSizeGB: osDiskSizeGB
    osSKU: nodePoolVmOsSKU
    osType: nodePoolVmOsType
    scaleDownMode: aksNodeScaleDownMode
    type: aksNodePoolType
    vmSize: aksNodeVmSize
    vnetSubnetID: !empty(vnetSubnetID)
      ? vnetSubnetID
      : first(filter(aks.properties.agentPoolProfiles, x => x.name == 'system')).?vnetSubnetID
    upgradeSettings: {
      maxSurge: upgradeSettingsMaxSurge
    }
  }
}

@description('The name of the upserted agent pool.')
output agentPoolName string = agentPool.name
@description('The resource id of the upserted agent pool.')
output agentPoolResourceId string = agentPool.id
