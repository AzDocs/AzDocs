/*
.SYNOPSIS
Maintenance Configuration.
.DESCRIPTION
Creates a Maintenance Configuration. With Maintenance Configurations, you can take more control over when to apply updates to various Azure resources.
.EXAMPLE
<pre>
module maintenanceConfiguration '../modules/Maintenance/maintenanceConfigurations.bicep' = {
  name: format('{0}-{1}', take('${deployment().name}', 48), 'maintconf')
  params: {
    location: location
    maintenanceConfigurationsName: maintenanceConfigurationsName
    maintenanceWindow: {
      startDateTime: '2022-09-16 03:00'
      duration: '03:00'
      timeZone: 'W. Europe Standard Time'
      expirationDateTime: null
      recurEvery: '1Day' //'Month Fourth Monday'
    }
    rebootSetting: 'IfRequired'
    installPatchesLinuxParameters: {
      classificationsToInclude: [
        'Critical'
        'Security'
      ]
      packageNameMasksToExclude: null
      packageNameMasksToInclude: null
    }
  }
}
</pre>
<p>Creates a maintenance configuration resource for Linux Virtual Machines.</p>
.LINKS
- [Maintenance Configuration](https://learn.microsoft.com/en-us/azure/templates/microsoft.maintenance/maintenanceconfigurations?pivots=deployment-language-bicep)
- [Maintenance Configuration using the Portal](https://learn.microsoft.com/en-ca/azure/virtual-machines/maintenance-configurations-portal)
- [Rest Api](https://learn.microsoft.com/en-us/rest/api/maintenance/maintenance-configurations/list?tabs=HTTP)
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

@description('The name fo the maintenance configuration resource')
@minLength(1)
@maxLength(80)
param maintenanceConfigurationsName string = 'maintenanceConfiguration'

@description('''
Sets extensionProperties of the maintenanceConfiguration.
Extension properties must contain Patch mode. e.g. InGuestPatchMode = User or InGuestPatchMode = Platform.''')
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

@description('''
Input parameters specific to patching Linux machines. See https://learn.microsoft.com/en-us/azure/templates/microsoft.maintenance/maintenanceconfigurations?pivots=deployment-language-bicep for all options.
''')
param installPatchesLinuxParameters object = {
  classificationsToInclude: [
    'Critical'
    'Security'
  ]
  packageNameMasksToExclude: null
  packageNameMasksToInclude: null
}

@description('''
Input parameters specific to patching a Windows machine. https://learn.microsoft.com/en-us/azure/templates/microsoft.maintenance/maintenanceconfigurations?pivots=deployment-language-bicep
''')
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

@description('The namespace for the maintenance configuration. Default this is "Microsoft.Maintenance".')
param namespaceMaintenanceConfiguration string = 'Microsoft.Maintenance'

@description('''
The visibility for the maintenance configuration. Default is Custom, which means only visible to users with permissions.
Public means visible to all users.
''')
@allowed([
  'Public'
  'Custom'
])
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
