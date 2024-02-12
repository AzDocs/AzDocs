/*
.SYNOPSIS
Creating an AKS Cluster.
.DESCRIPTION
Creating an AKS cluster with the given specs.
.EXAMPLE
<pre>
module aks 'br:contosoregistry.azurecr.io/containerservice/managedclusters:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 60), 'aks')
  params: {
    aksName: myaks
  }
}
</pre>
<p>creates a public aks cluster with the name myaks and all default provided values from the parameters.</p>

.EXAMPLE
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
.LINKS
- [Bicep Microsoft.ContainerService managed clusters](https://learn.microsoft.com/en-us/azure/templates/microsoft.containerservice/managedclusters?pivots=deployment-language-bicep)
*/

// ================================================= Parameters =================================================
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

@description('The name for the AKS cluster.')
@minLength(1)
@maxLength(63)
param aksName string

@description('The name of the resourcegroup you want to place the nodes in, defaults to MC_<resourcegroupname_of_akscluster>_<name_of_cluster>_<region_of_deployment>')
param nodeResourceGroup string = ''

@description('''
The name of the already existing user assigned managed identity. If you provide it, a user assigned managed identity will be used instead of a system assigned identity created.
Needed when you want to use a custom private DNS zone or a byo vnetsubnetid. Using Custom, BYO networking and PrivateApiZones requires User Assigned Managed Identity.
''')
param userAssignedManagedIdentityName string = ''

@description('The resourcegroup where the user assigned managed identity is in.')
param userAssignedIdentityResourceGroupName string = az.resourceGroup().name

@description('The sku for the aks cluster. If not provided it is set to free.')
@allowed([
  'Free'
  'Standard'
  'Premium'
])
param aksClusterSkuTier string = 'Free'

@description('The kubernetes version of the AKS cluster.')
param aksKubernetesVersion string = '1.28.3'

@description('''
Node pool version. Both patch version <major.minor.patch> and <major.minor> are supported. When <major.minor> is specified, the latest supported patch version is chosen automatically.
As best practice, you should have all node pools in an AKS cluster to the same Kubernetes version. The node pool version must have the same major version as the control plane.
The node pool minor version must be within two minor versions of the control plane version. The node pool version cannot be greater than the control plane version.
''')
param nodePoolOrchestratorVersion string = '1.28.3'

@description('''
The number of nodes you want to host in the aks cluster. Number of agents (VMs) to host docker containers.
Allowed values must be in the range of 0 to 1000 (inclusive) for user pools and in the range of 1 to 1000 (inclusive) for system pools. The default value is 1
''')
@minValue(1)
@maxValue(1000)
param aksNodeCount int = 1

@description('''
The sku for the system Vm Nodes used in the cluster. VM size availability varies by region.
If a node contains insufficient compute resources (memory, cpu, etc) pods might fail to run correctly. For more details on restricted VM sizes, see: [link](https://docs.microsoft.com/azure/aks/quotas-skus-regions)
''')
param aksNodeVmSize string = 'Standard_D4ds_v5'

@description('''
The size of the OS Disk of the Vms used for the system nodes. OS Disk Size in GB to be used to specify the disk size for every machine in the master/agent pool.
If you specify 0, it will apply the default osDisk size according to the vmSize specified.
''')
param aksNodeOsDiskSizeGB int = 0

@description('Determines the placement of emptyDir volumes, container runtime data root, and Kubelet ephemeral storage.')
@allowed([ 'OS', 'Temporary' ])
param aksNodeKubeletDiskType string = 'OS'

@description('The name of the virtual network that holds the byo subnet for AKS. When used, it should already be existing.')
param aksVirtualNetworkName string = ''

@description('The resourcegroup that holds the existing byo virtual network and byo subnet for AKS when used.')
param aksVirtualNetworkResourceGroupName string = az.resourceGroup().name

@description('''
The name of a subnet in an existing VNet into which to deploy the aks cluster. If this is not specified, a VNET and subnet will be generated and used. If no podSubnetID is specified, this applies to nodes and pods, otherwise it applies to just nodes.
''')
param aksSubnetName string = ''

@description('The maximum number of pods that can run on a node. The Kubenet default is 110, Azure CNI default is 30.')
@minValue(10)
@maxValue(250)
param aksNodeMaxPods int = 110

@description('The type of Agent Pool.')
@allowed([ 'VirtualMachineScaleSets', 'AvailabilitySet' ])
param aksNodePoolType string = 'VirtualMachineScaleSets'

@description('''
The list of Availability zones to use for nodes. This can only be specified if the AgentPoolType property is VirtualMachineScaleSets
Example:
[
  '1'
  '2'
  '3'
]
''')
@maxLength(3)
param availabilityZones array = []

@description('Whether to enable auto-scaler.')
param aksNodeAutoScaler bool = false

@description('This also effects the cluster autoscaler behavior. If not specified, it defaults to Delete.')
@allowed([ 'Delete', 'DeAllocate' ])
param aksNodeScaleDownMode string = 'Delete'

@description('''
Assign a public IP per node for user node pools. Some scenarios may require nodes in a node pool to receive their own dedicated public IP addresses.
A common scenario is for gaming workloads, where a console needs to make a direct connection to a cloud virtual machine to minimize hops.
''')
param enableNodePublicIP bool = false

@description('The taints added to new nodes during node pool create and scale. For example, key=value:NoSchedule.')
param nodeTaints array = [
  'CriticalAddonsOnly=true:NoSchedule'
]

@description('Any labels that should be applied to the node pool')
param nodeLabels object = {
  'node.kubernetes.io/component': 'System'
}

@description('''
Whether the Disks of the VMs should have encryption at host. This is only supported on certain VM sizes and in certain Azure regions. For more [information](https://docs.microsoft.com/azure/aks/enable-host-encryption).
''')
param enableEncryptionAtHost bool = true

@description('Whether to enable UltraSSD.')
param enableUltraSSD bool = false

@description('The operating system type. The system node pool must be Linux. The default is Linux.')
@allowed([ 'Linux', 'Windows' ])
param nodePoolVmOsType string = 'Linux'

@description('''
Specifies the OS SKU used by the agent pool. If not specified, the default is Ubuntu if OSType=Linux or Windows2019 if OSType=Windows.
And the default Windows OSSKU will be changed to Windows2022 after Windows2019 is deprecated.
''')
param nodePoolVmOsSKU string = nodePoolVmOsType == 'Linux' ? 'Ubuntu' : 'Windows'

@allowed([
  ''
  'audit'
  'deny'
])
@description('Enable the Azure Policy addon')
param azurepolicy string = ''

@allowed([
  'Baseline'
  'Restricted'
])
param azurePolicyInitiative string = 'Baseline'

@description('Rotation poll interval for the AKS KV CSI provider')
param keyVaultAksCSIPollInterval string = '2m'

@description('Installs the AKS KV CSI provider')
param azureKeyvaultSecretsProviderEnabled bool = true

@description('Enables Open Service Mesh')
param openServiceMeshAddon bool = false

@description('Enables SGX Confidential Compute plugin')
param sgxPlugin bool = false

@description('Enable AKS logs')
param omsagent bool = false

@description('The Azure resource id of the log analytics workspace to log to.')
@minLength(0)
param logAnalyticsWorkspaceResourceId string = ''

@description('The name of the log analytics workspace when used.')
param logAnalyticsWorkspaceName string = !empty(logAnalyticsWorkspaceResourceId) ? last(split(logAnalyticsWorkspaceResourceId, '/')) : ''

@description('Diagnostic categories to log')
param aksDiagCategories array = [
  'cluster-autoscaler'
  'kube-controller-manager'
  'kube-audit-admin'
  'guard'
]

@description('Enable SysLogs and send to log analytics')
param enableSysLog bool = false

@description('Network plugin used for building the Kubernetes network.')
@allowed([ 'kubenet', 'azure', 'none' ])
param networkProfileNetworkPlugin string = 'kubenet'

@allowed([
  ''
  'Overlay'
])
@description('The network plugin type')
param networkPluginMode string = ''

@allowed([
  ''
  'azure'
  'calico'
  'cilium'
])
@description('The network policy to use.')
param networkPolicy string = ''

@description('Desired outbound flow idle timeout in minutes. Allowed values are in the range of 4 to 120 (inclusive). The default value is 30 minutes.')
param networkProfileloadBalancerProfileIdleTimeoutInMinutes int = 4

@description('A CIDR notation IP range from which to assign pod IPs when kubenet is used.')
param networkProfilePodCidr string = '100.64.0.0/16'

@description('A CIDR notation IP range from which to assign service cluster IPs. It must not overlap with any Subnet IP ranges.')
param networkProfileServiceCidr string = '100.65.0.0/16'

@description('An IP address assigned to the Kubernetes DNS service. It must be within the Kubernetes service address range specified in serviceCidr')
param networkProfileDnsServiceIP string = '100.65.0.10'

@description('Egress outbound type. Can only be set at creation time.')
@allowed([ 'loadBalancer', 'managedNATGateway', 'userAssignedNATGateway', 'userDefinedRouting' ])
param networkProfileOutboundType string = 'loadBalancer'

@description('''
The ipv6 podcidr for a dual-stack aks cluster.
Example:
'fdfd:fdfd:0:2::/64'
''')
param ipv6PodCidr string = ''

@description('''
One IPv4 CIDR is expected for single-stack networking. Two CIDRs, one for each IP family (IPv4/IPv6), is expected for dual-stack networking.
Example:
[
  '100.64.0.0/16'
  'fdfd:fdfd:0:2::/64'
]
''')
param networkProfilePodCidrs array = !empty(ipv6PodCidr) ? [ networkProfilePodCidr, ipv6PodCidr ] : [ networkProfilePodCidr ]

@description('''
The ipv6 servicecidr for a dual-stack aks cluster.
Example:
'fdfd:fdfd:0:3::/108'
'''
)
param ipv6ServiceCidr string = ''

@description('One IPv4 CIDR is expected for single-stack networking. Two CIDRs, one for each IP family (IPv4/IPv6), is expected for dual-stack networking. They must not overlap with any Subnet IP ranges')
param serviceCidrs array = !empty(ipv6ServiceCidr) ? [ networkProfileServiceCidr, ipv6ServiceCidr ] : [ networkProfileServiceCidr ]

@description('''
IP families are used to determine single-stack or dual-stack clusters. For single-stack, the expected value is IPv4.
For dual-stack, the expected values are IPv4 and IPv6. If you configure this with both IPv4 and IPv6 and you do not set a byo network, the network will be created with ipv4 and ipv6.
And serviceCidrs and podsCidrs will also be configured automatically with both.
Otherwise with byo network, this is expected to be present.
''')
@allowed([ 'IPv4', 'IPv6' ])
param networkProfileIpFamilies array = [
  'IPv4'
]

@description('Whether to enable Kubernetes Role-Based Access Control.')
param enableRBAC bool = true

@description('Whether to enable managed AAD.')
param aadProfileManaged bool = true

@description('Whether to enable Azure RBAC for Kubernetes authorization.')
param aadProfileEnableAzureRBAC bool = true

@description('The list of AAD group object IDs that will have admin role of the cluster.')
param aadProfileAdminGroupObjectIDs array = []

@allowed([
  'system'
  'none'
  'privateDnsZone'
])
@description('''
Private cluster dns advertisment method, leverages the dnsApiPrivateZoneId parameter. Setting "system" means that aks will create the zone, "none" means no zone is used.
Using privateDnsZone means you will use byo / custom DNS Zone. In that case the deployment tries to make a virtual link from the zone to the virtual network used. Either byo or system created.
''')
param privateClusterDnsMethod string = 'none'

@description('''
DNS prefix. Defaults to {resourceName}-dns that will be used to prefix "fqdn" and "privateFQDN" if you do not provide "aksFqdnSubdomain".
You cannot both use fqdnSubdomain and dnsPrefix.
This cannot be updated once the Managed Cluster has been created.
''')
@minLength(1)
@maxLength(54)
#disable-next-line BCP335 //Disabling validation of this parameter to cope with warning of name too long because of prefilled value.
param dnsPrefix string = '${aksName}-dns'

//## private cluster
@description('Whether you want your aks cluster to be private. When true, must be used with fqdnSubdomain.')
param apiServerAccessProfileEnablePrivateCluster bool = false

@description('The subdomain to create the AKS cluster in. This cannot be updated once the Managed Cluster has been created. When used, must be used together with private cluster and custom private dns zone (not "none").')
param aksFqdnSubdomain string = privateClusterDnsMethod == 'privateDnsZone' ? aksName : ''

@description('''
Whether to create additional public FQDN for private cluster or not. Optionally when enabledprivatecluster is true.
When you have set the parameter privateDnsZone to none, you must set the public FQDN feature to true.
''')
param enablePrivateClusterPublicFQDN bool = true

@description('If set to true, getting static credentials will be disabled for this cluster. This must only be used on Managed Clusters that are AAD enabled. ')
param disableLocalAccounts bool = true

@description('''
IP ranges are specified in CIDR format, e.g. 137.117.106.88/29 that are allowed on this cluster.
This feature is not compatible with clusters that use Public IP Per Node, or clusters that are using a Basic Load Balancer. For more information see API server authorized IP ranges.
''')
param authorizedIPRanges object = {}

@description('The resourcegroup where the private DNS zone can be found.')
param privateDnsZoneResourceGroupName string = az.resourceGroup().name

@description('The subscriptionId of the subscription that holds the resourcegroup for the Private DNS Zone.')
param privateDNSZoneSubscriptionId string = subscription().subscriptionId

@description('''
The percentage of the total agent pool size at the time of the upgrade.
For percentages, fractional nodes are rounded up. If not specified, the default is 1. For more information, including best practices, see:[info](https://learn.microsoft.com/en-us/azure/aks/upgrade-cluster?tabs=azure-cli)
For production node pools, it is recommended to use a max-surge setting of 33%.
''')
param upgradeSettingsMaxSurge string = '33%'

@description('The desired number of IPv4 outbound IPs created/managed by Azure for the cluster load balancer. Allowed values must be in the range of 1 to 100 (inclusive). The default value is 1.')
@minValue(1)
@maxValue(100)
param managedOutboundIPsIPv4 int = 1

@description('The desired number of IPv6 outbound IPs created/managed by Azure for the cluster load balancer. Allowed values must be in the range of 1 to 100 (inclusive). The default value is 0 for single-stack and 1 for dual-stack.')
@minValue(0)
@maxValue(100)
param managedOutboundIPsIPv6 int = 1

@description('''
The public key you want to use for logging into your VMSS.
Example:
param vmssPublicKey string = loadTextContent('id_rsa.pub')
''')
@secure()
param vmssPublicKey string = ''

@description('The linuxprofile object for the VMSS of the cluster.')
param linuxProfile object = {
  adminUsername: 'azureuser'
  ssh: {
    publicKeys: [
      {
        keyData: vmssPublicKey
      }
    ]
  }
}

@description('Enable Microsoft Defender for Containers (preview)')
param defenderForContainers bool = false

@description('Enables Kubernetes Event-driven Autoscaling (KEDA). As of now needs enablement of resource provider "Feature Microsoft.ContainerService/AKS-KedaPreview"')
param kedaAddon bool = false

@description('Enables the Blob CSI driver')
param blobCSIDriver bool = false

@description('Enables the File CSI driver')
param fileCSIDriver bool = true

@description('Enables the Disk CSI driver')
param diskCSIDriver bool = true

@description('Enables the snapshot controller')
param snapshotController bool = true

@description('AKS upgrade channel. The default is none. More [info](https://learn.microsoft.com/en-us/azure/aks/auto-upgrade-cluster).')
@allowed([
  'none'
  'patch'
  'stable'
  'rapid'
  'node-image'
])
param upgradeChannel string = 'none'

@description('Whether to enable secret rotation when using the keyvault secrets provider.')
param azureKeyvaultSecrProviderEnableSecrRotation string = 'true'

@minValue(0)
@maxValue(64000)
@description('''
The desired number of allocated SNAT ports per VM. Allowed values are in the range of 1 to 64000 (inclusive).
The default value is 0 which results in that Azure dynamically allocates the ports.
''')
param loadBalancerProfileAllocatedOutboundPorts int = 0

@description('Determine if you want to enable logcategories in diagnostic settings.')
param diagnosticSettingsLogsEnabled bool = false

@description('Determine if you want to enable metrics in diagnostic settings.')
param diagnosticSettingsMetricsEnabled bool = false

@description('Container insights for Azure Kubernetes Service (AKS) cluster using managed identity towards the log analytics workspace.')
param omsagentUseAADAuth bool = false

@description('Workload identity enables Kubernetes applications to access Azure cloud resources securely with Azure AD. See [link](https://aka.ms/aks/wi) for more details')
param workloadIdentity bool = false

@description('The OpenID Connect provider issuer profile of the Managed Cluster, used with the workloadIdentity. See [link](https://learn.microsoft.com/en-us/azure/aks/use-oidc-issuer)')
param oidcIssuerProfile bool = false

// ===================================== Variables =====================================
var aks_addons = union({
    azurepolicy: {
      config: {
        version: !empty(azurepolicy) ? 'v2' : null
      }
      enabled: !empty(azurepolicy)
    }
    azureKeyvaultSecretsProvider: {
      config: {
        enableSecretRotation: azureKeyvaultSecrProviderEnableSecrRotation
        rotationPollInterval: keyVaultAksCSIPollInterval
      }
      enabled: azureKeyvaultSecretsProviderEnabled
    }
    openServiceMesh: !openServiceMeshAddon ? null : {
      enabled: openServiceMeshAddon
      config: {}
    }
    ACCSGXDevicePlugin: !sgxPlugin ? null : {
      enabled: sgxPlugin
      config: {}
    }
  }, omsagent && !empty(logAnalyticsWorkspaceResourceId) ? {
    omsagent: {
      enabled: true
      config: union({
          logAnalyticsWorkspaceResourceID: logAnalyticsWorkspaceResourceId
        }, omsagentUseAADAuth ? { useAADAuth: 'true' } : {}
      )
    }
  } : {}
)

@description('The private DNS Zone Name for the private AKS cluster.')
var privateDnsZoneName = 'privatelink.westeurope.azmk8s.io'

@description('Sets the private dns zone id if provided')
var aksPrivateDnsZone = privateClusterDnsMethod == 'privateDnsZone' ? (!empty(privateDnsZone.id) ? privateDnsZone.id : 'system') : privateClusterDnsMethod

var kubeletidentity = !empty(userAssignedManagedIdentityName) ? {
  resourceId: aksUim.id
  clientId: aksUim.properties.clientId
  objectId: aksUim.properties.principalId
} : {}

// ===================================== Existing Resources =====================================
@description('''
Existing user assigned managed identity to use for the AKS Control Plane.
Make sure it already has the required RBAC rights to create the AKS cluster if you are using a custom resourcegroup.
Custom, BYO networking and PrivateApi DNSZones require an AKS User Identity. Make sure it has the necessary RBAC rights.
''')
resource aksUim 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = if (!empty(userAssignedManagedIdentityName)) {
  name: userAssignedManagedIdentityName
  scope: resourceGroup(userAssignedIdentityResourceGroupName)
}

@description('Private DNS Zone for private clusters. When private cluster is used, the resourceId of the existing DNS zone is needed. A system-assigned managed identity is not supported for custom private dns zone.')
resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = if (privateClusterDnsMethod == 'privateDnsZone') {
  name: privateDnsZoneName
  scope: resourceGroup(privateDNSZoneSubscriptionId, privateDnsZoneResourceGroupName)
}

@description('''
The ID of a byo subnet in an existing VNet into which to deploy the cluster. If this is not specified, a VNET and subnet will be generated and used.
If no podSubnetID is specified, this applies to nodes and pods, otherwise it applies to just nodes.
Make sure the vnet can resolve the DNS entry of the Kubernetes API server name when the AKS is deployed in this subnet (especially when a custom DNS is used on the Vnet).
''')
resource aksSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' existing = if (!empty(aksSubnetName)) {
  name: '${aksVirtualNetworkName}/${aksSubnetName}'
  scope: resourceGroup(aksVirtualNetworkResourceGroupName)
}

// ===================================== Resources =====================================
resource aksCluster 'Microsoft.ContainerService/managedClusters@2023-11-01' = {
  name: aksName
  location: location
  tags: tags
  sku: {
    name: 'Base'
    tier: aksClusterSkuTier
  }
  identity: !empty(userAssignedManagedIdentityName) ? {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${aksUim.id}': {}
    }
  } : {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: aksKubernetesVersion
    dnsPrefix: empty(aksFqdnSubdomain) ? dnsPrefix : null
    fqdnSubdomain: apiServerAccessProfileEnablePrivateCluster ? aksFqdnSubdomain : ''
    agentPoolProfiles: [
      {
        name: 'system'
        count: aksNodeCount
        vmSize: aksNodeVmSize
        osDiskSizeGB: aksNodeOsDiskSizeGB //osDiskType using the defaults
        kubeletDiskType: aksNodeKubeletDiskType
        vnetSubnetID: empty(aksSubnetName) ? null : aksSubnet.id
        maxPods: aksNodeMaxPods
        type: aksNodePoolType
        availabilityZones: (aksNodePoolType == 'VirtualMachineScaleSets') ? availabilityZones : null
        enableAutoScaling: aksNodeAutoScaler
        scaleDownMode: aksNodeScaleDownMode
        orchestratorVersion: nodePoolOrchestratorVersion
        enableNodePublicIP: enableNodePublicIP
        nodeLabels: nodeLabels
        nodeTaints: nodeTaints
        mode: 'System'
        enableEncryptionAtHost: enableEncryptionAtHost
        enableUltraSSD: enableUltraSSD
        osType: nodePoolVmOsType
        osSKU: nodePoolVmOsSKU
        upgradeSettings: {
          maxSurge: upgradeSettingsMaxSurge
        }
      }
    ]
    workloadAutoScalerProfile: kedaAddon ? {
      keda: {
        enabled: kedaAddon
      }
    } : null
    #disable-next-line BCP035
    linuxProfile: !empty(vmssPublicKey) ? linuxProfile : null
    addonProfiles: !empty(aks_addons) ? aks_addons : {}
    nodeResourceGroup: nodeResourceGroup
    oidcIssuerProfile: {
      enabled: workloadIdentity ? true : oidcIssuerProfile
    }
    enableRBAC: enableRBAC
    networkProfile: {
      networkPlugin: networkProfileNetworkPlugin
      networkPluginMode: networkProfileNetworkPlugin == 'azure' ? networkPluginMode : ''
      loadBalancerSku: 'Standard'
      networkPolicy: networkPolicy
      loadBalancerProfile: {
        managedOutboundIPs: {
          count: managedOutboundIPsIPv4
          countIPv6: !contains(networkProfileIpFamilies, 'IPv6') ? 0 : managedOutboundIPsIPv6
        }
        allocatedOutboundPorts: loadBalancerProfileAllocatedOutboundPorts
        idleTimeoutInMinutes: networkProfileloadBalancerProfileIdleTimeoutInMinutes
      }
      podCidr: networkProfilePodCidr
      serviceCidr: networkProfileServiceCidr
      dnsServiceIP: networkProfileDnsServiceIP
      outboundType: networkProfileOutboundType
      podCidrs: networkProfilePodCidrs
      serviceCidrs: serviceCidrs
      ipFamilies: networkProfileIpFamilies
    }
    aadProfile: aadProfileManaged ? {
      managed: true
      enableAzureRBAC: aadProfileEnableAzureRBAC
      adminGroupObjectIDs: !empty(aadProfileAdminGroupObjectIDs) ? aadProfileAdminGroupObjectIDs : null
    } : null
    autoUpgradeProfile: { upgradeChannel: upgradeChannel }
    #disable-next-line BCP036
    apiServerAccessProfile: !empty(authorizedIPRanges) ? {
      authorizedIPRanges: authorizedIPRanges
    } : {
      enablePrivateCluster: apiServerAccessProfileEnablePrivateCluster
      privateDNSZone: apiServerAccessProfileEnablePrivateCluster ? aksPrivateDnsZone : ''
      enablePrivateClusterPublicFQDN: aksPrivateDnsZone == 'none' ? true : enablePrivateClusterPublicFQDN
    }
    identityProfile: !empty(kubeletidentity) ? {
      kubeletidentity: kubeletidentity
    } : {}
    disableLocalAccounts: disableLocalAccounts
    securityProfile: {
      defender: defenderForContainers ? {
        logAnalyticsWorkspaceResourceId: !empty(logAnalyticsWorkspaceResourceId) ? logAnalyticsWorkspaceResourceId : null
        securityMonitoring: {
          enabled: defenderForContainers
        }
      } : {}
      workloadIdentity: !workloadIdentity ? null : {
        enabled: workloadIdentity
      }
    }
    storageProfile: {
      blobCSIDriver: blobCSIDriver ? {
        enabled: blobCSIDriver
      } : null
      diskCSIDriver: {
        enabled: diskCSIDriver
      }
      fileCSIDriver: {
        enabled: fileCSIDriver
      }
      snapshotController: {
        enabled: snapshotController
      }
    }
  }
}

resource aksDiags 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceResourceId) && omsagent) {
  name: 'aksDiags'
  scope: aksCluster
  properties: {
    workspaceId: logAnalyticsWorkspaceResourceId
    logs: [for aksDiagCategory in aksDiagCategories: {
      category: aksDiagCategory
      enabled: diagnosticSettingsLogsEnabled
    }]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: diagnosticSettingsMetricsEnabled
      }
    ]
  }
}

resource sysLog 'Microsoft.Insights/dataCollectionRules@2022-06-01' = if (!empty(logAnalyticsWorkspaceResourceId) && omsagent && enableSysLog) {
  name: 'MSCI-${location}-${aksName}'
  location: location
  kind: 'Linux'
  properties: {
    dataFlows: [
      {
        destinations: [
          'ciworkspace'
        ]
        streams: [
          'Microsoft-Syslog'
          'Microsoft-ContainerInsights-Group-Default'
        ]
      }
    ]
    dataSources: {
      extensions: [
        {
          streams: [
            'Microsoft-ContainerInsights-Group-Default'
          ]
          extensionName: 'ContainerInsights'
          extensionSettings: {
            dataCollectionSettings: {
              interval: '1m'
              namespaceFilteringMode: 'Off'
            }
          }
          name: 'ContainerInsightsExtension'
        }
      ]
      syslog: [
        {
          facilityNames: [
            'auth'
            'authpriv'
            'cron'
            'daemon'
            'mark'
            'kern'
            'local0'
            'local1'
            'local2'
            'local3'
            'local4'
            'local5'
            'local6'
            'local7'
            'lpr'
            'mail'
            'news'
            'syslog'
            'user'
            'uucp'
          ]
          logLevels: [
            'Debug'
            'Info'
            'Notice'
            'Warning'
            'Error'
            'Critical'
            'Alert'
            'Emergency'
          ]
          name: 'sysLogsDataSource'

          streams: [ 'Microsoft-Syslog' ]
        }
      ]
    }
    destinations: {
      logAnalytics: [
        {
          name: 'ciworkspace'
          workspaceResourceId: logAnalyticsWorkspaceResourceId
        }
      ]
    }
  }
}

resource association 'Microsoft.Insights/dataCollectionRuleAssociations@2022-06-01' = if (!empty(logAnalyticsWorkspaceResourceId) && omsagent && enableSysLog) {
  name: '${aksName}-${logAnalyticsWorkspaceName}-association'
  scope: aksCluster
  properties: {
    dataCollectionRuleId: sysLog.id
    description: 'Association of data collection rule. Deleting this association will break the data collection for this AKS Cluster.'
  }
}

var policySetBaseline = '/providers/Microsoft.Authorization/policySetDefinitions/a8640138-9b0a-4a28-b8cb-1666c838647d'
var policySetRestrictive = '/providers/Microsoft.Authorization/policySetDefinitions/42b8ef37-b724-4e24-bbc8-7a7708edfe00'

resource aks_policies 'Microsoft.Authorization/policyAssignments@2022-06-01' = if (!empty(azurepolicy)) {
  name: '${aksName}-${azurePolicyInitiative}'
  location: location
  properties: {
    policyDefinitionId: azurePolicyInitiative == 'Baseline' ? policySetBaseline : policySetRestrictive
    parameters: {
      excludedNamespaces: {
        value: [
          'kube-system'
          'gatekeeper-system'
          'azure-arc'
          'cluster-baseline-setting'
        ]
      }
      effect: {
        value: azurepolicy
      }
    }
    metadata: {
      assignedBy: 'Aks Construction'
    }
    displayName: 'Kubernetes cluster pod security ${azurePolicyInitiative} standards for Linux-based workloads'
    description: 'As per: https://github.com/Azure/azure-policy/blob/master/built-in-policies/policySetDefinitions/Kubernetes/'
  }
}

@description('The resource id of the AKS cluster created.')
output aksResourceId string = aksCluster.id
@description('The name of the Aks cluster created.')
output aksClusterName string = aksCluster.name
@description('The objectid of the identity of the AKS cluster created.')
output kubeletObjectId string = any(aksCluster.properties.identityProfile.kubeletidentity).objectId
@description('The resource id of the subnet the pool is deployed in.')
output aksClusterSubnetId string = !empty(aksSubnetName) ? first(filter(aksCluster.properties.agentPoolProfiles, x => x.name == 'system'))!.vnetSubnetID : ''
