/*
.SYNOPSIS
Creating a Bastion Host.
.DESCRIPTION
Creating a Bastion Host with the given specs.
.EXAMPLE
<pre>
module bastion 'br:contosoregistry.azurecr.io/network/bastionHosts:latest' = {
  name: '${deployment().name}-bastion'
  params: {
    bastionHostName: bastionHostName
    location: location
    vnetName: vnetExisting.name
    bastionHostEnableFileCopy: true
    bastionHostEnableTunneling: true
  }
}
</pre>
<p>Creates a Bastion Host with the name bastionHostName that has native client support and allows copy and paste.</p>
.LINKS
- [Bicep Microsoft.Network bastionHosts](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/bastionhosts?pivots=deployment-language-bicep)
- [Bastion and NSGs](https://learn.microsoft.com/en-gb/azure/bastion/bastion-nsg)
*/
@description('Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location.')
param location string = resourceGroup().location

@description('Specifies the name of the Azure Bastion resource.')
@minLength(1)
@maxLength(80)
param bastionHostName string

@description('Enable/Disable Copy/Paste feature of the Bastion Host resource.')
param bastionHostDisableCopyPaste bool = false

@description('Enable/Disable File Copy (between Host & Client) feature of the Bastion Host resource.')
param bastionHostEnableFileCopy bool = false

@description('Enable/Disable IP Connect feature of the Bastion Host resource. This will allow you to connect to VM\'s (either azure or non-azure) using the VM\'s private IP address through Bastion.')
param bastionHostEnableIpConnect bool = false

@description('Enable/Disable Shareable Link of the Bastion Host resource which is a URL to the bastion remote to the VM.')
param bastionHostEnableShareableLink bool = false

@description('''
Enable/Disable Tunneling feature of the Bastion Host resource.
SSH tunneling is a method of transporting arbitrary networking data over an encrypted SSH connection. It can be used to add encryption to legacy applications. It can also be used to implement VPNs (Virtual Private Networks) and access intranet services across firewalls.
''')
param bastionHostEnableTunneling bool = false

@description('''
The tags to apply to this resource. This is an object with key/value pairs.
Example:
{
  FirstTag: myvalue
  SecondTag: another value
}
''')
param tags object = {}

@description('Name of the Azure Bastion subnet. This is probably going to have to be `AzureBastionSubnet` due to Azure restrictions.')
@minLength(1)
@maxLength(80)
param bastionSubnetName string = 'AzureBastionSubnet'

@description('The resource name of the Public IP for this Azure Bastion host.')
@minLength(1)
@maxLength(80)
param bastionPublicIpAddressName string = bastionHostName

@description('The VNet name to onboard this Azure Bastion Host into.')
@minLength(2)
@maxLength(64)
param vnetName string

@description('The sku for the Bastion host.')
@allowed([
  'Basic'
  'Standard'
])
param bastionHostSku string = 'Standard'

@description('The resource group of the virtual network the bastion subnet is in.')
param bastionVirtualNetworkResourceGroupName string

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

@description('Fetch existing virtual network.')
resource vnetExisting 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: vnetName
  scope: az.resourceGroup(bastionVirtualNetworkResourceGroupName)
}

@description('Upsert the public ip needed for the Azure Bastion host.')
module bastionPublicIpAddress 'publicIPAddresses.bicep' = {
  name: format('{0}-{1}', take('${deployment().name}', 51), 'bastionPubIp')
  scope: az.resourceGroup()
  params: {
    publicIPAddressName: bastionPublicIpAddressName
    location: location
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    publicIPIdleTimeoutInMinutes: 10
    tags: tags
    sku: {
      name: 'Standard'
    }
  }
}

@description('Upsert the bastion host with the given parameters.')
resource bastionHost 'Microsoft.Network/bastionHosts@2021-08-01' = {
  name: bastionHostName
  location: location
  sku: {
    name: bastionHostSku
  }
  tags: tags
  properties: {
    disableCopyPaste: bastionHostDisableCopyPaste
    enableFileCopy: bastionHostEnableFileCopy
    enableIpConnect: bastionHostEnableIpConnect
    enableShareableLink: bastionHostEnableShareableLink
    enableTunneling: bastionHostEnableTunneling
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          subnet: {
            id: '${vnetExisting.id}/subnets/${bastionSubnetName}'
          }
          publicIPAddress: {
            id: bastionPublicIpAddress.outputs.publicIpResourceId
          }
        }
      }
    ]
  }
}

@description('Upsert the diagnostics for this bastion host.')
resource bastionDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceResourceId)) {
  name: diagnosticsName
  scope: bastionHost
  properties: {
    workspaceId: logAnalyticsWorkspaceResourceId
    logs: diagnosticSettingsLogsCategories
    metrics: diagnosticSettingsMetricsCategories
  }
}

@description('Outputs the name of the created Bastion Host.')
output bastionHostName string = bastionHost.name
