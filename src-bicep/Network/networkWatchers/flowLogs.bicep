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

@description('The azure resource id of the log analytics workspace to log the diagnostics to. If you set this to an empty string, logging & diagnostics will be disabled.')
@minLength(0)
param logAnalyticsWorkspaceResourceId string

@description('The resourceid for the storage account to log the NSG flow logs to. This should be pre-existing.')
param nsgFlowLogStorageAccountResourceId string

@description('Upsert the NSG Flow logs with the given parameters.')
resource nsgFlowLog 'Microsoft.Network/networkWatchers/flowLogs@2021-08-01' = if (!empty(logAnalyticsWorkspaceResourceId)) {
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
        enabled: true
        workspaceResourceId: logAnalyticsWorkspaceResourceId
        trafficAnalyticsInterval: 10
      }
    }
    format: {
      type: 'JSON'
      version: 2
    }
  }
}
