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

@description('The name fo the maintenance configuration resource')
@minLength(1)
@maxLength(80)
param maintenanceConfigurationsName string = 'maintenanceConfiguration'

@description('Gets or sets extensionProperties of the maintenanceConfiguration')
param extensionProperties object = {
  InGuestPatchMode: 'User'
}

@description('Sets the maintenance scope of the maintenance configuration resource')
@allowed([
  'Extension'
  'Host'
  'InGuestPatch'
  'OSImage'
  'Resource'
  'SQLDB'
  'SQLManagedInstance'
])
param maintenanceScope string = 'InGuestPatch'

@description('''
Timeframe properties when the maintenance activities may take place. See https://docs.microsoft.com/en-us/azure/templates/microsoft.maintenance/maintenanceconfigurations?pivots=deployment-language-bicep
Example:
{
  startDateTime: '2022-09-16 03:00'
  duration: '03:00'
  timeZone: 'W. Europe Standard Time'
  expirationDateTime: null
  recurEvery: '1Day'
}
''')
param maintenanceWindow object = {
  startDateTime: '2022-09-16 03:00'
  duration: '03:00'
  timeZone: 'W. Europe Standard Time'
  expirationDateTime: null
  recurEvery: '1Day'
}

@description('Input parameters specific to patching Linux machines. For Windows machines, do not pass this property.')
param installPatchesLinuxParameters object = {
  classificationsToInclude: [
    'Critical'
    'Security'
  ]
  packageNameMasksToExclude: null
  packageNameMasksToInclude: null
}

@description('Input parameters specific to patching a Windows machine. For Linux machines, do not pass this property.')
param installPatchesWindowsParameters object = {
  classificationsToInclude: [
    'Critical'
    'Security'
  ]
  kbNumbersToExclude: null
  kbNumbersToInclude: null
}

@description('Possible reboot preference as defined by the user based on which it would be decided to reboot the machine or not after the patch operation is completed.')
@allowed([
  'Always'
  'IfRequired'
  'Never'
  'RebootIfRequired'
])
param rebootSetting string = 'IfRequired'

@description('Tasks information for the Software update configuration. See https://docs.microsoft.com/en-us/azure/templates/microsoft.maintenance/maintenanceconfigurations?pivots=deployment-language-bicep#softwareupdateconfigurationtasks')
param tasks object = {
  postTasks: [
    {}
  ]
  preTasks: [
    {}
  ]
}

@description('The namespace for the maintenance configuration')
param namespaceMaintenanceConfiguration string = ''

@description('The visibility for the maintenance configuration.')
param visibilityMaintenanceConfiguration string = 'Custom'


resource maintenanceConfiguration 'Microsoft.Maintenance/maintenanceConfigurations@2021-09-01-preview' = {
  name: maintenanceConfigurationsName
  location: location
  tags: tags
  properties: {
    maintenanceScope: maintenanceScope
    installPatches: {
      linuxParameters: installPatchesLinuxParameters
      windowsParameters: installPatchesWindowsParameters
      rebootSetting: rebootSetting
      tasks: tasks
    }
    extensionProperties: extensionProperties
    maintenanceWindow: maintenanceWindow
    namespace: namespaceMaintenanceConfiguration
    visibility: visibilityMaintenanceConfiguration
  }
}

output maintenanceConfigurationResourceId string = maintenanceConfiguration.id
output maintenanceConfigurationName string = maintenanceConfiguration.name
