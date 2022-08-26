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

@description('''
Specifies the name of the loadbalancer. This can be suffixed with the environmentType parameter. Format: <loadBalancerName>-<environmentType>.
Min length: 1
Max length: 76
''')
@minLength(1)
@maxLength(76)
param loadBalancerName string

@description('A list of backend address pools to apply to this loadbalancer. For object formatting & options, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.network/loadbalancers?pivots=deployment-language-bicep#backendaddresspool.')
param backendAddressPools array = []

@description('The public ip for the Load Balancer. This Public IP should be pre-existing.')
@maxLength(80)
param loadBalancerPublicIpAddressName string = ''

@description('Required when using private frontend ip addresses. The name of the virtual network in which you want to onboard this loadbalancer\'s private frontend ip.')
@maxLength(80)
param privateFrontendIpVirtualNetworkName string = ''

@description('Required when using private frontend ip addresses. The name of the subnet in which you want to onboard this loadbalancer\'s private frontend ip.')
@maxLength(80)
param privateFrontendIpSubnetName string = ''

@description('Do you want to expose this loadbalancer on the internet (Public) or on your internal ranges only (Internal).')
@allowed([
  'Internal'
  'Public'
])
param loadBalancerExposureType string = 'Internal'

@description('''
Define the Frontend Ip Configuration you want to use for this Load Balancer. For formatting & options, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.network/loadbalancers?pivots=deployment-language-bicep.
Defaults to a default public or internal frontend ip based on the `loadBalancerExposureType` parameter. If you override this, the `loadBalancerExposureType` parameter gets useless.
''')
param frontendIPConfigurations array = loadBalancerExposureType == 'Public' ? [
  {
    name: '${loadBalancerName}-frontendIP'
    properties: {
      publicIPAddress: {
        id: '${subscription().id}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Network/publicIPAddresses/${loadBalancerPublicIpAddressName}'
      }
    }
  }
] : [
  {
    name: '${loadBalancerName}-frontendIP'
    properties: {
      privateIPAddress: null
      privateIPAddressVersion: 'IPv4'
      privateIPAllocationMethod: 'Dynamic'
      subnet: {
        id: '${subscription().id}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Network/virtualNetworks/${privateFrontendIpVirtualNetworkName}/subnets/${privateFrontendIpSubnetName}'
      }
    }
    zones: [
      2
      3
      1
    ]
  }
]

@description('''
Define the sku you want to use for this Load Balancer. For formatting & options, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.network/loadbalancers?pivots=deployment-language-bicep.
Quick examples:
Among others, options are:
`name`: Type for the Load Balancer.
`tier`: Tier for the Load Balancer.
''')
param loadBalancerSku object = {
  name: 'Standard'
  tier: 'Regional'
}

@description('''
Define the rules you want to use for this Load Balancer. For formatting & options, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.network/loadbalancers?pivots=deployment-language-bicep.

Example:
[
  {
    name: '${loadBalancerName}-udp'
    properties: {
      frontendIPConfiguration: {
        id: '${subscription().id}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Network/loadBalancers/${loadBalancerName}/frontendIPConfigurations/${loadBalancerFrontendIPName}'
      }
      backendAddressPool: {
        id: '${subscription().id}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Network/loadBalancers/${loadBalancerName}/backendAddressPools/${loadBalancerBackendPoolName}'
      }
      protocol: 'Udp'
      frontendPort: 53
      backendPort: 53
      enableFloatingIP: false
      idleTimeoutInMinutes: 5
      probe: {
        id: '${subscription().id}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Network/loadBalancers/${loadBalancerName}/probes/${loadBalancerName}-probe'
      }
    }
  }
  {
    name: '${loadBalancerName}-tcp'
    properties: {
      frontendIPConfiguration: {
        id: '${subscription().id}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Network/loadBalancers/${loadBalancerName}/frontendIPConfigurations/${loadBalancerFrontendIPName}'
      }
      backendAddressPool: {
        id: '${subscription().id}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Network/loadBalancers/${loadBalancerName}/backendAddressPools/${loadBalancerBackendPoolName}'
      }
      protocol: 'Tcp'
      frontendPort: 53
      backendPort: 53
      enableFloatingIP: false
      idleTimeoutInMinutes: 5
      probe: {
        id: '${subscription().id}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Network/loadBalancers/${loadBalancerName}/probes/${loadBalancerName}-probe'
      }
    }
  }
]
''')
param loadBalancingRules array = []

@description('''
Define the health probes you want to use for the rules of this Load Balancer. For formatting & options, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.network/loadbalancers?pivots=deployment-language-bicep.

[
  {
    name: '${loadBalancerName}-probe'
    properties: {
      protocol: 'Tcp'
      port: 53
      intervalInSeconds: 5
      numberOfProbes: 2
    }
  }
]
''')
param loadBalancingProbes array = []

@description('''
Define the inbound nat rules you want to use for this Load Balancer. For formatting & options, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.network/loadbalancers?pivots=deployment-language-bicep.
''')
param inboundNatRules array = []

@description('''
Define the outbound rules you want to use for this Load Balancer. For formatting & options, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.network/loadbalancers?pivots=deployment-language-bicep.
''')
param outboundNatRules array = []

@description('The name of the diagnostics. This defaults to `AzurePlatformCentralizedLogging`.')
@minLength(1)
@maxLength(260)
param diagnosticsName string = 'AzurePlatformCentralizedLogging'

@description('The azure resource id of the log analytics workspace to log the diagnostics to. If you set this to an empty string, logging & diagnostics will be disabled.')
@minLength(0)
param logAnalyticsWorkspaceResourceId string

@description('Which log categories to enable; This defaults to `allLogs`. For array/object format, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep#logsettings.')
param diagnosticSettingsLogsCategories array = [
  {
    categoryGroup: 'allLogs'
    enabled: true
  }
]

@description('Which Metrics categories to enable; This defaults to `AllMetrics`. For array/object format, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep&pivots=deployment-language-bicep#metricsettings')
param diagnosticSettingsMetricsCategories array = [
  {
    categoryGroup: 'AllMetrics'
    enabled: true
  }
]

@description('Fetch the Public IP used for the Load Balancer, if desired.')
resource loadBalancerPublicIpAddress 'Microsoft.Network/publicIPAddresses@2022-01-01' existing = if (!empty(loadBalancerPublicIpAddressName)) {
  name: loadBalancerPublicIpAddressName
}

@description('Upsert the diagnostics for this loadbalancer.')
resource loadBalancerDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceResourceId)) {
  name: diagnosticsName
  scope: loadBalancer
  properties: {
    workspaceId: logAnalyticsWorkspaceResourceId
    logs: diagnosticSettingsLogsCategories
    metrics: diagnosticSettingsMetricsCategories
  }
}

@description('Upsert the Load Balancer with the given parameters.')
resource loadBalancer 'Microsoft.Network/loadBalancers@2022-01-01' = {
  name: loadBalancerName
  location: location
  sku: loadBalancerSku
  tags: tags
  properties: {
    frontendIPConfigurations: !empty(loadBalancerPublicIpAddressName) ? frontendIPConfigurations : []
    backendAddressPools: backendAddressPools
    loadBalancingRules: loadBalancingRules
    probes: loadBalancingProbes
    inboundNatRules: inboundNatRules
    outboundRules: outboundNatRules
  }
  dependsOn: !empty(loadBalancerPublicIpAddress) ? [
    loadBalancerPublicIpAddress
  ] : []
}

@description('Outputs the resource name of the upserted Load Balancer.')
output loadBalancerName string = loadBalancer.name
@description('Outputs the Resource ID of the upserted Load Balancer.')
output loadBalancerResourceId string = loadBalancer.id
@description('Outputs a list of upserted backend address pools.')
output loadBalancerBackendAddressPools array = loadBalancer.properties.backendAddressPools
