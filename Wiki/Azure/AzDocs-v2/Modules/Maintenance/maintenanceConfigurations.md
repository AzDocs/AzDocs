# maintenanceConfigurations

Target Scope: resourceGroup

## Synopsis
Maintenance Configuration.

## Description
Creates a Maintenance Configuration. With Maintenance Configurations, you can take more control over when to apply updates to various Azure resources.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| maintenanceConfigurationsName | string | <input type="checkbox"> | Length between 1-80 | <pre>'maintenanceConfiguration'</pre> | The name fo the maintenance configuration resource |
| extensionProperties | object | <input type="checkbox"> | None | <pre>{<br>  InGuestPatchMode: 'User'<br>}</pre> | Sets extensionProperties of the maintenanceConfiguration.<br>Extension properties must contain Patch mode. e.g. InGuestPatchMode = User or InGuestPatchMode = Platform. |
| maintenanceScope | string | <input type="checkbox"> | `'Extension'` or  `'Host'` or  `'InGuestPatch'` or  `'OSImage'` or  `'Resource'` or  `'SQLDB'` or  `'SQLManagedInstance'` | <pre>'InGuestPatch'</pre> | Sets the maintenance scope of the maintenance configuration resource |
| maintenanceWindow | object | <input type="checkbox"> | None | <pre>{<br>  startDateTime: '2022-09-16 03:00'<br>  duration: '03:00'<br>  timeZone: 'W. Europe Standard Time'<br>  expirationDateTime: null<br>  recurEvery: '1Day'<br>}</pre> | Timeframe properties when the maintenance activities may take place. See https://docs.microsoft.com/en-us/azure/templates/microsoft.maintenance/maintenanceconfigurations?pivots=deployment-language-bicep<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;startDateTime: '2022-09-16 03:00'<br>&nbsp;&nbsp;&nbsp;duration: '03:00'<br>&nbsp;&nbsp;&nbsp;timeZone: 'W. Europe Standard Time'<br>&nbsp;&nbsp;&nbsp;expirationDateTime: null<br>&nbsp;&nbsp;&nbsp;recurEvery: '1Day'<br>} |
| installPatchesLinuxParameters | object | <input type="checkbox"> | None | <pre>{<br>  classificationsToInclude: [<br>    'Critical'<br>    'Security'<br>  ]<br>  packageNameMasksToExclude: null<br>  packageNameMasksToInclude: null<br>}</pre> | Input parameters specific to patching Linux machines. See https://learn.microsoft.com/en-us/azure/templates/microsoft.maintenance/maintenanceconfigurations?pivots=deployment-language-bicep for all options. |
| installPatchesWindowsParameters | object | <input type="checkbox"> | None | <pre>{<br>  classificationsToInclude: [<br>    'Critical'<br>    'Security'<br>  ]<br>  kbNumbersToExclude: null<br>  kbNumbersToInclude: null<br>}</pre> | Input parameters specific to patching a Windows machine. https://learn.microsoft.com/en-us/azure/templates/microsoft.maintenance/maintenanceconfigurations?pivots=deployment-language-bicep |
| rebootSetting | string | <input type="checkbox"> | `'Always'` or  `'IfRequired'` or  `'Never'` or  `'RebootIfRequired'` | <pre>'IfRequired'</pre> | Possible reboot preference as defined by the user based on which it would be decided to reboot the machine or not after the patch operation is completed. |
| tasks | object | <input type="checkbox"> | None | <pre>{<br>  postTasks: [<br>    {}<br>  ]<br>  preTasks: [<br>    {}<br>  ]<br>}</pre> | Tasks information for the Software update configuration. See https://docs.microsoft.com/en-us/azure/templates/microsoft.maintenance/maintenanceconfigurations?pivots=deployment-language-bicep#softwareupdateconfigurationtasks |
| namespaceMaintenanceConfiguration | string | <input type="checkbox"> | None | <pre>'Microsoft.Maintenance'</pre> | The namespace for the maintenance configuration. Default this is "Microsoft.Maintenance". |
| visibilityMaintenanceConfiguration | string | <input type="checkbox"> | `'Public'` or  `'Custom'` | <pre>'Custom'</pre> | The visibility for the maintenance configuration. Default is Custom, which means only visible to users with permissions.<br>Public means visible to all users. |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| maintenanceConfigurationResourceId | string |  |
| maintenanceConfigurationName | string |  |
## Examples
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

## Links
- [Maintenance Configuration](https://learn.microsoft.com/en-us/azure/templates/microsoft.maintenance/maintenanceconfigurations?pivots=deployment-language-bicep)<br>
- [Maintenance Configuration using the Portal](https://learn.microsoft.com/en-ca/azure/virtual-machines/maintenance-configurations-portal)<br>
- [Rest Api](https://learn.microsoft.com/en-us/rest/api/maintenance/maintenance-configurations/list?tabs=HTTP)


