/*
.SYNOPSIS
Creating a Vnet
.DESCRIPTION
Creating a virtual network with the proper settings
.SECURITY_DEFAULTS
- applied nsg
.EXAMPLE
<p>Creates a virtual network</p>
<pre>
module vnet '../../AzDocs/src-bicep/Network/virtualNetworks.bicep' = {
  name: 'Creating_vnet_MyFirstVnet'
  scope: resourceGroup
  params: {
    vnetName: 'MyFirstVnet'
    logAnalyticsWorkspaceResourceId: logAnalyticsWorkspaceResourceId
  }
}
</pre>

---

<p>Creates a virtual network and add it to the ddos protection plan.</p>
<pre>
var subscriptionID = '9c6d33c9-00dc-484f-be85-707aa44e908f' 
var resourceGroupName = 'Hub-ddos'
resource ddos 'Microsoft.Network/ddosProtectionPlans@2022-01-01' existing = {
  name: 'ddos-protection'
  scope: resourceGroup(subscriptionID, resourceGroupName)
}

module vnet '../../AzDocs/src-bicep/Network/virtualNetworks.bicep' = {
  name: 'Creating_vnet_MyFirstVnet'
  scope: resourceGroup
  params: {
    vnetName: 'MyFirstVnet'
    logAnalyticsWorkspaceResourceId: logAnalyticsWorkspaceResourceId
    ddosProtectionPlanId: ddos.id
  }
}
</pre>
.LINKS
- [Bicep Vnet documentation](https://docs.microsoft.com/en-us/azure/templates/microsoft.network/2022-01-01/virtualnetworks?pivots=deployment-language-bicep)
*/

@description('The name for the Virtual Network to upsert.')
@minLength(2)
@maxLength(64)
param virtualNetworkName string

@description('''
A list of address prefixes for the VNet (CIDR notation). This can be IPv4 and IPv6 mixed.
For example:
[
  '10.0.0.0/16'
  'fdfd:fdfd::/110'
]
''')
@minLength(1)
param virtualNetworkAddressPrefixes array = ['10.0.0.0/16']

@description('Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location.')
param location string = resourceGroup().location

@description('The subnets to upsert in this VNet. NOTE: Subnets which are present in your existing VNet and are not in this list, will be removed. For array/object format please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.network/virtualnetworks?tabs=bicep#subnet.')
param subnets array = []

@description('DNS Servers to apply to this virtual network. Format is an array/list of IP\'s')
param dnsServers array = []

@description('The azure resource id of the log analytics workspace to log the diagnostics to. If you set this to an empty string, logging & diagnostics will be disabled.')
@minLength(0)
param logAnalyticsWorkspaceResourceId string

@description('The name of the diagnostics. This defaults to `AzurePlatformCentralizedLogging`.')
@minLength(1)
@maxLength(260)
param diagnosticsName string = 'AzurePlatformCentralizedLogging'

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

@description('If defined, the vlan will be added to the DDos Protection Plan')
param ddosProtectionPlanId string = ''

@description('''
The tags to apply to this resource. This is an object with key/value pairs.
Example:
{
  FirstTag: myvalue
  SecondTag: another value
}
''')
param tags object = {}

@description('Setting up the properties and add ddosprotectionplan if it is enabled')
var properties = union(
  {
    addressSpace: {
      addressPrefixes: virtualNetworkAddressPrefixes
    }
    subnets: subnets
    dhcpOptions: {
      dnsServers: dnsServers
    }
    enableDdosProtection: !empty(ddosProtectionPlanId)
  },
  empty(ddosProtectionPlanId)
    ? {}
    : {
        //Adding ddos protectionplan object
        ddosProtectionPlan: {
          id: ddosProtectionPlanId
        }
      }
)

@description('Upsert the virtual network with the given parameters.')
#disable-next-line BCP081
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-08-01' = {
  name: virtualNetworkName
  location: location
  tags: tags
  properties: properties
}

@description('Upsert the diagnostics for this virtual network with the given parameters.')
resource virtualNetworkDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceResourceId)) {
  name: diagnosticsName
  scope: virtualNetwork
  properties: {
    workspaceId: logAnalyticsWorkspaceResourceId
    logs: diagnosticSettingsLogsCategories
    metrics: diagnosticSettingsMetricsCategories
  }
}

@description('Outputs the Virtual Network resourcename.')
output virtualNetworkName string = virtualNetwork.name
