@description('The name of the NetworkWatcher resource')
@minLength(1)
@maxLength(80)
param networkWatcherName string

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

@description('Upsert the network watcher with the given parameters.')
resource networkWatcher 'Microsoft.Network/networkWatchers@2021-08-01' = {
  name: networkWatcherName
  location: location
  tags: tags
}

@description('Outputs the network watcher\'s resource name.')
output networkWatcherName string = networkWatcher.name

@description('Outputs the network watcher\'s resource id.')
output networkWatcherResourceId string = networkWatcher.id
