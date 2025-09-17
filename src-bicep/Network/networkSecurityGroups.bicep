@description('The name of the network security group. Preferably identical or similar/retracable to the subnet name where it gets applied to.')
@minLength(1)
@maxLength(80)
param networkSecurityGroupName string

@description('Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location.')
param location string = resourceGroup().location

@description('A collection of security rules of the network security group. For array/object structure, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.network/networksecuritygroups?tabs=bicep#securityrule.')
param securityRules array

@description('The name of the diagnostics. This defaults to `AzurePlatformCentralizedLogging`.')
@minLength(1)
@maxLength(260)
param diagnosticsName string = 'AzurePlatformCentralizedLogging'

@description('The azure resource id of the log analytics workspace to log the diagnostics to. If you set this to an empty string, logging & diagnostics will be disabled.')
@minLength(0)
param logAnalyticsWorkspaceResourceId string = ''

@description('Which log categories to enable; This defaults to `allLogs`. For array/object format, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep#logsettings.')
param diagnosticSettingsLogsCategories array = [
  {
    categoryGroup: 'allLogs'
    enabled: true
  }
]

@description('''
The tags to apply to this resource. This is an object with key/value pairs.
Example:
{
  FirstTag: myvalue
  SecondTag: another value
}
''')
param tags object = {}


@description('Upsert the NSG with the given parameters.')
resource nsg 'Microsoft.Network/networkSecurityGroups@2021-03-01' = {
  name: networkSecurityGroupName
  location: location
  tags: tags
  properties: {
    securityRules: securityRules
  }
}

@description('Upsert the diagnostics for this NSG with the given parameters.')
resource nsgDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceResourceId)) {
  name: diagnosticsName
  scope: nsg
  properties: {
    workspaceId: logAnalyticsWorkspaceResourceId
    logs: diagnosticSettingsLogsCategories
  }
}

@description('Output the Network Security Group\'s resource name')
output nsgName string = nsg.name
@description('Output the Network Security Group\'s resource id')
output nsgResourceId string = nsg.id
