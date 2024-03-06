# managedClusters

Target Scope: resourceGroup

## Synopsis
Creating an AKS Cluster.

## Description
Creating an AKS cluster with the given specs.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| aksName | string | <input type="checkbox" checked> | Length between 1-63 | <pre></pre> | The name for the AKS cluster. |
| nodeResourceGroup | string | <input type="checkbox"> | None | <pre>''</pre> | The name of the resourcegroup you want to place the nodes in, defaults to MC_<resourcegroupname_of_akscluster>_<name_of_cluster>_<region_of_deployment> |
| userAssignedManagedIdentityName | string | <input type="checkbox"> | None | <pre>''</pre> | The name of the already existing user assigned managed identity. If you provide it, a user assigned managed identity will be used instead of a system assigned identity created.<br>Needed when you want to use a custom private DNS zone or a byo vnetsubnetid. Using Custom, BYO networking and PrivateApiZones requires User Assigned Managed Identity. |
| userAssignedIdentityResourceGroupName | string | <input type="checkbox"> | None | <pre>az.resourceGroup().name</pre> | The resourcegroup where the user assigned managed identity is in. |
| aksClusterSkuTier | string | <input type="checkbox"> | `'Free'` or `'Standard'` or `'Premium'` | <pre>'Free'</pre> | The sku for the aks cluster. If not provided it is set to free. |
| aksKubernetesVersion | string | <input type="checkbox"> | None | <pre>'1.28.3'</pre> | The kubernetes version of the AKS cluster. |
| nodePoolOrchestratorVersion | string | <input type="checkbox"> | None | <pre>'1.28.3'</pre> | Node pool version. Both patch version <major.minor.patch> and <major.minor> are supported. When <major.minor> is specified, the latest supported patch version is chosen automatically.<br>As best practice, you should have all node pools in an AKS cluster to the same Kubernetes version. The node pool version must have the same major version as the control plane.<br>The node pool minor version must be within two minor versions of the control plane version. The node pool version cannot be greater than the control plane version. |
| aksNodeCount | int | <input type="checkbox"> | Value between 1-1000 | <pre>1</pre> | The number of nodes you want to host in the aks cluster. Number of agents (VMs) to host docker containers.<br>Allowed values must be in the range of 0 to 1000 (inclusive) for user pools and in the range of 1 to 1000 (inclusive) for system pools. The default value is 1 |
| aksNodeVmSize | string | <input type="checkbox"> | None | <pre>'Standard_D4ds_v5'</pre> | The sku for the system Vm Nodes used in the cluster. VM size availability varies by region.<br>If a node contains insufficient compute resources (memory, cpu, etc) pods might fail to run correctly. For more details on restricted VM sizes, see: [link](https://docs.microsoft.com/azure/aks/quotas-skus-regions) |
| aksNodeOsDiskSizeGB | int | <input type="checkbox"> | None | <pre>0</pre> | The size of the OS Disk of the Vms used for the system nodes. OS Disk Size in GB to be used to specify the disk size for every machine in the master/agent pool.<br>If you specify 0, it will apply the default osDisk size according to the vmSize specified. |
| aksNodeKubeletDiskType | string | <input type="checkbox"> | `'OS'` or `'Temporary'` | <pre>'OS'</pre> | Determines the placement of emptyDir volumes, container runtime data root, and Kubelet ephemeral storage. |
| aksVirtualNetworkName | string | <input type="checkbox"> | None | <pre>''</pre> | The name of the virtual network that holds the byo subnet for AKS. When used, it should already be existing. |
| aksVirtualNetworkResourceGroupName | string | <input type="checkbox"> | None | <pre>az.resourceGroup().name</pre> | The resourcegroup that holds the existing byo virtual network and byo subnet for AKS when used. |
| aksSubnetName | string | <input type="checkbox"> | None | <pre>''</pre> | The name of a subnet in an existing VNet into which to deploy the aks cluster. If this is not specified, a VNET and subnet will be generated and used. If no podSubnetID is specified, this applies to nodes and pods, otherwise it applies to just nodes. |
| aksNodeMaxPods | int | <input type="checkbox"> | Value between 10-250 | <pre>110</pre> | The maximum number of pods that can run on a node. The Kubenet default is 110, Azure CNI default is 30. |
| aksNodePoolType | string | <input type="checkbox"> | `'VirtualMachineScaleSets'` or `'AvailabilitySet'` | <pre>'VirtualMachineScaleSets'</pre> | The type of Agent Pool. |
| availabilityZones | array | <input type="checkbox"> | Length between 0-3 | <pre>[]</pre> | The list of Availability zones to use for nodes. This can only be specified if the AgentPoolType property is VirtualMachineScaleSets<br>Example:<br>[<br>&nbsp;&nbsp;&nbsp;'1'<br>&nbsp;&nbsp;&nbsp;'2'<br>&nbsp;&nbsp;&nbsp;'3'<br>] |
| aksNodeAutoScaler | bool | <input type="checkbox"> | None | <pre>false</pre> | Whether to enable auto-scaler. |
| aksNodeScaleDownMode | string | <input type="checkbox"> | `'Delete'` or `'DeAllocate'` | <pre>'Delete'</pre> | This also effects the cluster autoscaler behavior. If not specified, it defaults to Delete. |
| enableNodePublicIP | bool | <input type="checkbox"> | None | <pre>false</pre> | Assign a public IP per node for user node pools. Some scenarios may require nodes in a node pool to receive their own dedicated public IP addresses.<br>A common scenario is for gaming workloads, where a console needs to make a direct connection to a cloud virtual machine to minimize hops. |
| nodeTaints | array | <input type="checkbox"> | None | <pre>[<br>  'CriticalAddonsOnly=true:NoSchedule'<br>]</pre> | The taints added to new nodes during node pool create and scale. For example, key=value:NoSchedule. |
| nodeLabels | object | <input type="checkbox"> | None | <pre>{<br>  'node.kubernetes.io/component': 'System'<br>}</pre> | Any labels that should be applied to the node pool |
| enableEncryptionAtHost | bool | <input type="checkbox"> | None | <pre>true</pre> | Whether the Disks of the VMs should have encryption at host. This is only supported on certain VM sizes and in certain Azure regions. For more [information](https://docs.microsoft.com/azure/aks/enable-host-encryption). |
| enableUltraSSD | bool | <input type="checkbox"> | None | <pre>false</pre> | Whether to enable UltraSSD. |
| nodePoolVmOsType | string | <input type="checkbox"> | `'Linux'` or `'Windows'` | <pre>'Linux'</pre> | The operating system type. The system node pool must be Linux. The default is Linux. |
| nodePoolVmOsSKU | string | <input type="checkbox"> | None | <pre>nodePoolVmOsType == 'Linux' ? 'Ubuntu' : 'Windows'</pre> | Specifies the OS SKU used by the agent pool. If not specified, the default is Ubuntu if OSType=Linux or Windows2019 if OSType=Windows.<br>And the default Windows OSSKU will be changed to Windows2022 after Windows2019 is deprecated. |
| azurepolicy | string | <input type="checkbox"> | `''` or `'audit'` or `'deny'` | <pre>''</pre> | Enable the Azure Policy addon |
| azurePolicyInitiative | string | <input type="checkbox"> | `'Baseline'` or `'Restricted'` | <pre>'Baseline'</pre> |  |
| keyVaultAksCSIPollInterval | string | <input type="checkbox"> | None | <pre>'2m'</pre> | Rotation poll interval for the AKS KV CSI provider |
| azureKeyvaultSecretsProviderEnabled | bool | <input type="checkbox"> | None | <pre>true</pre> | Installs the AKS KV CSI provider |
| openServiceMeshAddon | bool | <input type="checkbox"> | None | <pre>false</pre> | Enables Open Service Mesh |
| sgxPlugin | bool | <input type="checkbox"> | None | <pre>false</pre> | Enables SGX Confidential Compute plugin |
| omsagent | bool | <input type="checkbox"> | None | <pre>false</pre> | Enable AKS logs |
| logAnalyticsWorkspaceResourceId | string | <input type="checkbox"> | Length between 0-* | <pre>''</pre> | The Azure resource id of the log analytics workspace to log to. |
| logAnalyticsWorkspaceName | string | <input type="checkbox"> | None | <pre>!empty(logAnalyticsWorkspaceResourceId) ? last(split(logAnalyticsWorkspaceResourceId, '/')) : ''</pre> | The name of the log analytics workspace when used. |
| aksDiagCategories | array | <input type="checkbox"> | None | <pre>[<br>  'cluster-autoscaler'<br>  'kube-controller-manager'<br>  'kube-audit-admin'<br>  'guard'<br>]</pre> | Diagnostic categories to log |
| enableSysLog | bool | <input type="checkbox"> | None | <pre>false</pre> | Enable SysLogs and send to log analytics |
| networkProfileNetworkPlugin | string | <input type="checkbox"> | `'kubenet'` or `'azure'` or `'none'` | <pre>'kubenet'</pre> | Network plugin used for building the Kubernetes network. |
| networkPluginMode | string | <input type="checkbox"> | `''` or `'Overlay'` | <pre>''</pre> | The network plugin type |
| networkPolicy | string | <input type="checkbox"> | `''` or `'azure'` or `'calico'` or `'cilium'` | <pre>''</pre> | The network policy to use. |
| networkProfileloadBalancerProfileIdleTimeoutInMinutes | int | <input type="checkbox"> | None | <pre>4</pre> | Desired outbound flow idle timeout in minutes. Allowed values are in the range of 4 to 120 (inclusive). The default value is 30 minutes. |
| networkProfilePodCidr | string | <input type="checkbox"> | None | <pre>'100.64.0.0/16'</pre> | A CIDR notation IP range from which to assign pod IPs when kubenet is used. |
| networkProfileServiceCidr | string | <input type="checkbox"> | None | <pre>'100.65.0.0/16'</pre> | A CIDR notation IP range from which to assign service cluster IPs. It must not overlap with any Subnet IP ranges. |
| networkProfileDnsServiceIP | string | <input type="checkbox"> | None | <pre>'100.65.0.10'</pre> | An IP address assigned to the Kubernetes DNS service. It must be within the Kubernetes service address range specified in serviceCidr |
| networkProfileOutboundType | string | <input type="checkbox"> | `'loadBalancer'` or `'managedNATGateway'` or `'userAssignedNATGateway'` or `'userDefinedRouting'` | <pre>'loadBalancer'</pre> | Egress outbound type. Can only be set at creation time. |
| ipv6PodCidr | string | <input type="checkbox"> | None | <pre>''</pre> | The ipv6 podcidr for a dual-stack aks cluster.<br>Example:<br>'fdfd:fdfd:0:2::/64' |
| networkProfilePodCidrs | array | <input type="checkbox"> | None | <pre>!empty(ipv6PodCidr) ? [ networkProfilePodCidr, ipv6PodCidr ] : [ networkProfilePodCidr ]</pre> | One IPv4 CIDR is expected for single-stack networking. Two CIDRs, one for each IP family (IPv4/IPv6), is expected for dual-stack networking.<br>Example:<br>[<br>&nbsp;&nbsp;&nbsp;'100.64.0.0/16'<br>&nbsp;&nbsp;&nbsp;'fdfd:fdfd:0:2::/64'<br>] |
| networkProfileIpFamilies | array | <input type="checkbox"> | `'IPv4'` or `'IPv6'` | <pre>[<br>  'IPv4'<br>]</pre> | The ipv6 servicecidr for a dual-stack aks cluster.<br>Example:<br>'fdfd:fdfd:0:3::/108'<br>'''<br>)<br>param ipv6ServiceCidr string = ''<br><br>@description('One IPv4 CIDR is expected for single-stack networking. Two CIDRs, one for each IP family (IPv4/IPv6), is expected for dual-stack networking. They must not overlap with any Subnet IP ranges')<br>param serviceCidrs array = !empty(ipv6ServiceCidr) ? [ networkProfileServiceCidr, ipv6ServiceCidr ] : [ networkProfileServiceCidr ]<br><br>@description('''<br>IP families are used to determine single-stack or dual-stack clusters. For single-stack, the expected value is IPv4.<br>For dual-stack, the expected values are IPv4 and IPv6. If you configure this with both IPv4 and IPv6 and you do not set a byo network, the network will be created with ipv4 and ipv6.<br>And serviceCidrs and podsCidrs will also be configured automatically with both.<br>Otherwise with byo network, this is expected to be present. |
| enableRBAC | bool | <input type="checkbox"> | None | <pre>true</pre> | Whether to enable Kubernetes Role-Based Access Control. |
| aadProfileManaged | bool | <input type="checkbox"> | None | <pre>true</pre> | Whether to enable managed AAD. |
| aadProfileEnableAzureRBAC | bool | <input type="checkbox"> | None | <pre>true</pre> | Whether to enable Azure RBAC for Kubernetes authorization. |
| aadProfileAdminGroupObjectIDs | array | <input type="checkbox"> | None | <pre>[]</pre> | The list of AAD group object IDs that will have admin role of the cluster. |
| privateClusterDnsMethod | string | <input type="checkbox"> | `'system'` or `'none'` or `'privateDnsZone'` | <pre>'none'</pre> | Private cluster dns advertisment method, leverages the dnsApiPrivateZoneId parameter. Setting "system" means that aks will create the zone, "none" means no zone is used.<br>Using privateDnsZone means you will use byo / custom DNS Zone. In that case the deployment tries to make a virtual link from the zone to the virtual network used. Either byo or system created. |
| dnsPrefix | string | <input type="checkbox"> | None | <pre>'&#36;{aksName}-dns'</pre> |  |
| apiServerAccessProfileEnablePrivateCluster | bool | <input type="checkbox"> | None | <pre>false</pre> | Whether you want your aks cluster to be private. When true, must be used with fqdnSubdomain. |
| aksFqdnSubdomain | string | <input type="checkbox"> | None | <pre>privateClusterDnsMethod == 'privateDnsZone' ? aksName : ''</pre> | The subdomain to create the AKS cluster in. This cannot be updated once the Managed Cluster has been created. When used, must be used together with private cluster and custom private dns zone (not "none"). |
| enablePrivateClusterPublicFQDN | bool | <input type="checkbox"> | None | <pre>true</pre> | Whether to create additional public FQDN for private cluster or not. Optionally when enabledprivatecluster is true.<br>When you have set the parameter privateDnsZone to none, you must set the public FQDN feature to true. |
| disableLocalAccounts | bool | <input type="checkbox"> | None | <pre>true</pre> | If set to true, getting static credentials will be disabled for this cluster. This must only be used on Managed Clusters that are AAD enabled.  |
| authorizedIPRanges | object | <input type="checkbox"> | None | <pre>{}</pre> | IP ranges are specified in CIDR format, e.g. 137.117.106.88/29 that are allowed on this cluster.<br>This feature is not compatible with clusters that use Public IP Per Node, or clusters that are using a Basic Load Balancer. For more information see API server authorized IP ranges. |
| privateDnsZoneResourceGroupName | string | <input type="checkbox"> | None | <pre>az.resourceGroup().name</pre> | The resourcegroup where the private DNS zone can be found. |
| privateDNSZoneSubscriptionId | string | <input type="checkbox"> | None | <pre>subscription().subscriptionId</pre> | The subscriptionId of the subscription that holds the resourcegroup for the Private DNS Zone. |
| upgradeSettingsMaxSurge | string | <input type="checkbox"> | None | <pre>'33%'</pre> | The percentage of the total agent pool size at the time of the upgrade.<br>For percentages, fractional nodes are rounded up. If not specified, the default is 1. For more information, including best practices, see:[info](https://learn.microsoft.com/en-us/azure/aks/upgrade-cluster?tabs=azure-cli)<br>For production node pools, it is recommended to use a max-surge setting of 33%. |
| managedOutboundIPsIPv4 | int | <input type="checkbox"> | Value between 1-100 | <pre>1</pre> | The desired number of IPv4 outbound IPs created/managed by Azure for the cluster load balancer. Allowed values must be in the range of 1 to 100 (inclusive). The default value is 1. |
| managedOutboundIPsIPv6 | int | <input type="checkbox"> | Value between 0-100 | <pre>1</pre> | The desired number of IPv6 outbound IPs created/managed by Azure for the cluster load balancer. Allowed values must be in the range of 1 to 100 (inclusive). The default value is 0 for single-stack and 1 for dual-stack. |
| vmssPublicKey | string | <input type="checkbox"> | None | <pre>''</pre> | The public key you want to use for logging into your VMSS.<br>Example:<br>param vmssPublicKey string = loadTextContent('id_rsa.pub') |
| linuxProfile | object | <input type="checkbox"> | None | <pre>{<br>  adminUsername: 'azureuser'<br>  ssh: {<br>    publicKeys: [<br>      {<br>        keyData: vmssPublicKey<br>      }<br>    ]<br>  }<br>}</pre> | The linuxprofile object for the VMSS of the cluster. |
| defenderForContainers | bool | <input type="checkbox"> | None | <pre>false</pre> | Enable Microsoft Defender for Containers (preview) |
| kedaAddon | bool | <input type="checkbox"> | None | <pre>false</pre> | Enables Kubernetes Event-driven Autoscaling (KEDA). As of now needs enablement of resource provider "Feature Microsoft.ContainerService/AKS-KedaPreview" |
| blobCSIDriver | bool | <input type="checkbox"> | None | <pre>false</pre> | Enables the Blob CSI driver |
| fileCSIDriver | bool | <input type="checkbox"> | None | <pre>true</pre> | Enables the File CSI driver |
| diskCSIDriver | bool | <input type="checkbox"> | None | <pre>true</pre> | Enables the Disk CSI driver |
| snapshotController | bool | <input type="checkbox"> | None | <pre>true</pre> | Enables the snapshot controller |
| upgradeChannel | string | <input type="checkbox"> | `'none'` or `'patch'` or `'stable'` or `'rapid'` or `'node-image'` | <pre>'none'</pre> | AKS upgrade channel. The default is none. More [info](https://learn.microsoft.com/en-us/azure/aks/auto-upgrade-cluster). |
| azureKeyvaultSecrProviderEnableSecrRotation | string | <input type="checkbox"> | None | <pre>'true'</pre> | Whether to enable secret rotation when using the keyvault secrets provider. |
| loadBalancerProfileAllocatedOutboundPorts | int | <input type="checkbox"> | Value between 0-64000 | <pre>0</pre> | The desired number of allocated SNAT ports per VM. Allowed values are in the range of 1 to 64000 (inclusive).<br>The default value is 0 which results in that Azure dynamically allocates the ports. |
| diagnosticSettingsLogsEnabled | bool | <input type="checkbox"> | None | <pre>false</pre> | Determine if you want to enable logcategories in diagnostic settings. |
| diagnosticSettingsMetricsEnabled | bool | <input type="checkbox"> | None | <pre>false</pre> | Determine if you want to enable metrics in diagnostic settings. |
| omsagentUseAADAuth | bool | <input type="checkbox"> | None | <pre>false</pre> | Container insights for Azure Kubernetes Service (AKS) cluster using managed identity towards the log analytics workspace. |
| workloadIdentity | bool | <input type="checkbox"> | None | <pre>false</pre> | Workload identity enables Kubernetes applications to access Azure cloud resources securely with Azure AD. See [link](https://aka.ms/aks/wi) for more details |
| oidcIssuerProfile | bool | <input type="checkbox"> | None | <pre>false</pre> | The OpenID Connect provider issuer profile of the Managed Cluster, used with the workloadIdentity. See [link](https://learn.microsoft.com/en-us/azure/aks/use-oidc-issuer) |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| aksResourceId | string | The resource id of the AKS cluster created. |
| aksClusterName | string | The name of the Aks cluster created. |
| kubeletObjectId | string | The objectid of the identity of the AKS cluster created. |
| aksClusterSubnetId | string | The resource id of the subnet the pool is deployed in. |

## Examples
<pre>
module aks 'br:contosoregistry.azurecr.io/containerservice/managedclusters:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 60), 'aks')
  params: {
    aksName: myaks
  }
}
</pre>
<p>creates a public aks cluster with the name myaks and all default provided values from the parameters.</p>

<pre>
module aks 'br:acrazdocsprd.azurecr.io/containerservice/managedclusters: 2023.08.24.1-main' = {
  name: format('{0}-{1}', take('${deployment().name}', 53), 'akscluster')
  scope: resourceGroup(aksResourceGroupName)
  params: {
    aksName: aksName
    workloadIdentity: false
    omsagentUseAADAuth: false
    aksKubernetesVersion: '1.26.6'
    nodePoolOrchestratorVersion: '1.26.6'
    azureKeyvaultSecrProviderEnableSecrRotation: 'false'
    location: location
    aksClusterSkuTier: 'Free'
    apiServerAccessProfileEnablePrivateCluster: true
    aksNodeCount: 1
    userAssignedManagedIdentityName: userAssignedManagedIdentityName
    aksVirtualNetworkName: 'shared-dev-001-vnet'
    aksVirtualNetworkResourceGroupName: 'azure-aksdemo-dev'
    aksSubnetName: 'frontend-subnet'
    privateClusterDnsMethod: 'none'
    aksNodePoolType: 'VirtualMachineScaleSets'
    availabilityZones: [ '1' ]
    nodePoolVmOsType: 'Linux'
    enableEncryptionAtHost: true
    omsagent: omsagent
    enableSysLog: true
    logAnalyticsWorkspaceResourceId: law.outputs.logAnalyticsWorkspaceResourceId
    networkProfileIpFamilies: [
      'IPv4'
    ]
  }
  dependsOn: [userassmanidentityaks]
}
</pre>
<p>Creates a private cluster without private dnszone.</p>

## Links
- [Bicep Microsoft.ContainerService managed clusters](https://learn.microsoft.com/en-us/azure/templates/microsoft.containerservice/managedclusters?pivots=deployment-language-bicep)
