# agentPools

Target Scope: resourceGroup

## Synopsis
Creating an AKS Agent Pool.

## Description
Creating an AKS Agent Nodepool with the given specs.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| aksName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the existing AKS. |
| aksPoolName | string | <input type="checkbox" checked> | Length between 1-12 | <pre></pre> | The name of the agent pool to upsert in the AKS. |
| availabilityZones | array | <input type="checkbox"> | Length between 0-3 | <pre>[]</pre> | The zones to use for a node pool<br>Example:<br>[<br>&nbsp;&nbsp;&nbsp;'1'<br>&nbsp;&nbsp;&nbsp;'2'<br>&nbsp;&nbsp;&nbsp;'3'<br>] |
| aksNodeVmSize | string | <input type="checkbox"> | None | <pre>'Standard_D4ds_v5'</pre> | The sku for the system Vm Nodes used in the cluster. VM size availability varies by region.<br>If a node contains insufficient compute resources (memory, cpu, etc) pods might fail to run correctly. For more details on restricted VM sizes, see: [link](https://docs.microsoft.com/azure/aks/quotas-skus-regions) |
| osDiskSizeGB | int | <input type="checkbox"> | None | <pre>0</pre> | The size of the OS Disk of the Vms used for the nodes. OS Disk Size in GB to be used to specify the disk size for every machine in the agent pool.<br>If you specify 0, it will apply the default osDisk size according to the vmSize specified. |
| agentCount | int | <input type="checkbox"> | Value between 0-1000 | <pre>1</pre> | The number of agents for the user node poolNumber of agents (VMs) to host docker containers.<br>Allowed values must be in the range of 0 to 1000 (inclusive) for user pools. The default value is 1. |
| agentCountMax | int | <input type="checkbox"> | None | <pre>3</pre> | The maximum number of nodes for the user node pool |
| aksNodeScaleDownMode | string | <input type="checkbox"> | None | <pre>'Delete'</pre> | This also effects the cluster autoscaler behavior. If not specified, it defaults to Delete. |
| aksNodeMaxPods | int | <input type="checkbox"> | Value between 10-250 | <pre>110</pre> | The maximum number of pods that can run on a node. The Kubenet default is 110, Azure CNI default is 30. |
| nodeTaints | array | <input type="checkbox"> | None | <pre>[]</pre> | The taints added to new nodes during node pool create and scale. For example, key=value:NoSchedule,eg CoreOnly=true:NoSchedule. |
| nodeLabels | object | <input type="checkbox"> | None | <pre>{}</pre> | Any labels that should be applied to the node pool<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;'node.kubernetes.io/component': 'Supplementary'<br>} |
| nodePoolVmOsType | string | <input type="checkbox"> | None | <pre>'Linux'</pre> | OS Type for the node pool |
| nodePoolVmOsSKU | string | <input type="checkbox"> | None | <pre>nodePoolVmOsType == 'Linux' ? 'Ubuntu' : 'Windows'</pre> | Specifies the OS SKU used by the agent pool. If not specified, the default is Ubuntu if OSType=Linux or Windows2019 if OSType=Windows.<br>And the default Windows OSSKU will be changed to Windows2022 after Windows2019 is deprecated. |
| nodePublicIPPrefixID | string | <input type="checkbox"> | None | <pre>''</pre> | Define a block of public IPs for nodes.<br>This is of the form: /subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Network/publicIPPrefixes/{publicIPPrefixName} |
| enableNodePublicIP | bool | <input type="checkbox"> | None | <pre>false</pre> | Assign a public IP per node |
| autoTaintWindows | bool | <input type="checkbox"> | None | <pre>false</pre> | Apply a default sku taint to Windows node pools |
| aksNodePoolMode | string | <input type="checkbox"> | None | <pre>'User'</pre> | A cluster must have already at least one \'System\' Agent Pool at all times. For additional information on agent pool restrictions and best practices, see: /azure/aks/use-system-pools |
| aksNodePoolType | string | <input type="checkbox"> | None | <pre>'VirtualMachineScaleSets'</pre> | The type of AKS nodepool. |
| upgradeSettingsMaxSurge | string | <input type="checkbox"> | None | <pre>'33%'</pre> | This can either be set to an integer (e.g. '5') or a percentage (e.g. '50%'). If a percentage is specified, it is the percentage of the total agent pool size at the time of the upgrade.<br>For percentages, fractional nodes are rounded up. If not specified, the default is 1. For more information, including best practices, see: [info](https://learn.microsoft.com/en-us/azure/aks/upgrade-cluster?tabs=azure-cli).<br>For production node pools, it is recommended to use a max-surge setting of 33%. |
| enableEncryptionAtHost | bool | <input type="checkbox"> | None | <pre>true</pre> | Whether the Disks of the VMs should have encryption at host. This is only supported on certain VM sizes and in certain Azure regions. For more [information](https://docs.microsoft.com/azure/aks/enable-host-encryption). |
| aksNodeKubeletDiskType | string | <input type="checkbox"> | None | <pre>'OS'</pre> | Determines the placement of emptyDir volumes, container runtime data root, and Kubelet ephemeral storage. |
| enableUltraSSD | bool | <input type="checkbox"> | None | <pre>false</pre> | Whether to enable UltraSSD. |
| kubeletConfig | object | <input type="checkbox"> | None | <pre>{}</pre> | The Kubelet configuration on the agent pool nodes. |
| vnetSubnetID | string | <input type="checkbox"> | None | <pre>''</pre> | The subnet the node pool will use. If you are using byo subnet, this id should be the same subnet as the system pool is using<br>or at least a subnet in the same resourcegroup using the same routetable as the system node. |
| linuxOSConfig | object | <input type="checkbox"> | None | <pre>{}</pre> | The OS configuration of Linux agent nodes. |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| agentPoolName | string | The name of the upserted agent pool. |
| agentPoolResourceId | string | The resource id of the upserted agent pool. |
## Examples
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

## Links
- [Bicep Microsoft.ContainerService managedclusters agentpools](https://learn.microsoft.com/en-us/azure/templates/microsoft.containerservice/managedclusters/agentpools?pivots=deployment-language-bicep)


