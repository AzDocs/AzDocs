@description('The name of the networkwatcher for this Virtual Network. This should be pre-existing.')
@minLength(1)
@maxLength(80)
param networkWatcherName string

@description('The name of the network security group. Preferably identical or similar/retracable to the subnet name where it gets applied to.')
@minLength(1)
@maxLength(80)
param networkSecurityGroupName string

@description('The Resource ID of the Network Security Group where you want to apply this NSG Flow Log on. This should be pre-existing.')
param networkSecurityGroupResourceId string

@description('Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location.')
param location string = resourceGroup().location

@description('''
The name of the NSG flow log (dianostics).
You can use the following placeholders which will be replaced by their respective values:
  - <networkSecurityGroupName> will be translated in the value you use for the `networkSecurityGroupName` parameter.
''')
@minLength(3)
@maxLength(45)
param nsgFlowLogResourceName string = 'nfl-<networkSecurityGroupName>'

@description('''
The tags to apply to this resource. This is an object with key/value pairs.
Example:
{
  FirstTag: myvalue
  SecondTag: another value
}
''')
param tags object = {}

@description('Upsert the network watcher with the given parameters.')
resource networkWatcher 'Microsoft.Network/networkWatchers@2021-08-01' existing = {
  name: networkWatcherName
}

@description('The azure resource id of the log analytics workspace to log the flowlogs to.')
@minLength(0)
param trafficAnalyticsLogAnalyticsWorkspaceResourceId string

@description('The resourceid for the storage account to log the NSG flow logs to. This should be pre-existing.')
param nsgFlowLogStorageAccountResourceId string

@description('The interval in minutes which would decide how frequently TA service should do flow analytics.')
param trafficAnalyticsInterval int  = 10

@description('If set to true, the network watcher flow analytics configuration will be enabled.')
param networkWatcherFlowAnalyticsConfiguration bool = true

@description('''
Parameters that define the retention policy for flow log. See the [documentation](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/2021-08-01/networkwatchers/flowlogs?pivots=deployment-language-bicep#retentionpolicyparameters).
days: Number of days to retain flow log records.
enabled:	Flag to enable/disable retention.
'''')
param retentionPolicy object = {
  days: 0
  enabled: true
}


@description('Upsert the NSG Flow logs with the given parameters.')
resource nsgFlowLog 'Microsoft.Network/networkWatchers/flowLogs@2021-08-01' = if (!empty(trafficAnalyticsLogAnalyticsWorkspaceResourceId)) {
  parent: networkWatcher
  name: replace(nsgFlowLogResourceName, '<networkSecurityGroupName>', networkSecurityGroupName)
  tags: tags
  location: location
  properties: {
    targetResourceId: networkSecurityGroupResourceId
    storageId: nsgFlowLogStorageAccountResourceId
    enabled: true
    flowAnalyticsConfiguration: {
      networkWatcherFlowAnalyticsConfiguration: {
        enabled: networkWatcherFlowAnalyticsConfiguration
        workspaceResourceId: trafficAnalyticsLogAnalyticsWorkspaceResourceId
        trafficAnalyticsInterval: trafficAnalyticsInterval
      }
    }
    format: {
      type: 'JSON'
      version: 2
    }
    retentionPolicy: retentionPolicy
  }
}
