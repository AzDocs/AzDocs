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
param logAnalyticsWorkspaceResourceId string

@description('The name of the networkwatcher for this Virtual Network. This should be pre-existing.')
@minLength(1)
@maxLength(80)
param networkWatcherName string

@description('The name of the resourcegroup where the networkwatcher (for the Virtual Network) resides in. This should be pre-existing.')
@minLength(1)
@maxLength(90)
param networkWatcherResourceGroupName string = az.resourceGroup().name

@description('''
The name of the NSG flow log (dianostics).
You can use the following placeholders which will be replaced by their respective values:
  - <networkSecurityGroupName> will be translated in the value you use for the `networkSecurityGroupName` parameter.
''')
@minLength(3)
@maxLength(45)
param nsgFlowLogResourceName string = 'nfl-<networkSecurityGroupName>'

@description('The resourceid for the storage account to log the NSG flow logs to. This should be pre-existing.')
param nsgFlowLogStorageAccountResourceId string

@description('Which log categories to enable; This defaults to `allLogs`. For array/object format, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep#logsettings.')
param diagnosticSettingsLogsCategories array = [
  {
    categoryGroup: 'allLogs'
    enabled: true
  }
]

@description('The interval in minutes which would decide how frequently TA service should do flow analytics.')
param flowLogTrafficAnalyticsInterval int = 10

@description('''
Parameters that define the retention policy for flow log. See the [documentation](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/2021-08-01/networkwatchers/flowlogs?pivots=deployment-language-bicep#retentionpolicyparameters).
days: Number of days to retain flow log records.
enabled:	Flag to enable/disable retention.
''')
param flowLogRetentionPolicy object = {
  days: 0
  enabled: true
}

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

@description('Upsert the NSG Flow logs with the given parameters.')
module nsgFlowLog 'networkWatchers/flowLogs.bicep' = {
  name: take(format('{0}-{1}', networkSecurityGroupName, deployment().name), 64)
  scope: az.resourceGroup(az.subscription().subscriptionId, networkWatcherResourceGroupName)
  params: {
    networkWatcherName: networkWatcherName
    location: location
    tags: tags
    logAnalyticsWorkspaceResourceId: logAnalyticsWorkspaceResourceId
    networkSecurityGroupName: networkSecurityGroupName
    networkSecurityGroupResourceId: nsg.id
    nsgFlowLogStorageAccountResourceId: nsgFlowLogStorageAccountResourceId
    nsgFlowLogResourceName: nsgFlowLogResourceName
    trafficAnalyticsInterval: flowLogTrafficAnalyticsInterval
    retentionPolicy: flowLogRetentionPolicy
  }
}

@description('Output the Network Security Group\'s resource name')
output nsgName string = nsg.name
@description('Output the Network Security Group\'s resource id')
output nsgResourceId string = nsg.id
