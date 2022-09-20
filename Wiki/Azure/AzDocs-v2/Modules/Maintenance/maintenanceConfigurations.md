# maintenanceConfigurations

Target Scope: resourceGroup

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| maintenanceConfigurationsName | string | <input type="checkbox"> | Length between 1-80 | <pre>'maintenanceConfiguration'</pre> | The name fo the maintenance configuration resource |
| extensionProperties | object | <input type="checkbox"> | None | <pre>{<br>  InGuestPatchMode: 'User'<br>}</pre> | Sets extensionProperties of the maintenanceConfiguration |
| maintenanceScope | string | <input type="checkbox"> | `'Extension'` or  `'Host'` or  `'InGuestPatch'` or  `'OSImage'` or  `'Resource'` or  `'SQLDB'` or  `'SQLManagedInstance'` | <pre>'InGuestPatch'</pre> | Sets the maintenance scope of the maintenance configuration resource |
| maintenanceWindow | object | <input type="checkbox"> | None | <pre>{<br>  startDateTime: '2022-09-16 03:00'<br>  duration: '03:00'<br>  timeZone: 'W. Europe Standard Time'<br>  expirationDateTime: null<br>  recurEvery: '1Day'<br>}</pre> | Timeframe properties when the maintenance activities may take place. See https://docs.microsoft.com/en-us/azure/templates/microsoft.maintenance/maintenanceconfigurations?pivots=deployment-language-bicep<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;startDateTime: '2022-09-16 03:00'<br>&nbsp;&nbsp;&nbsp;duration: '03:00'<br>&nbsp;&nbsp;&nbsp;timeZone: 'W. Europe Standard Time'<br>&nbsp;&nbsp;&nbsp;expirationDateTime: null<br>&nbsp;&nbsp;&nbsp;recurEvery: '1Day'<br>} |
| installPatchesLinuxParameters | object | <input type="checkbox"> | None | <pre>{<br>  classificationsToInclude: [<br>    'Critical'<br>    'Security'<br>  ]<br>  packageNameMasksToExclude: null<br>  packageNameMasksToInclude: null<br>}</pre> | Input parameters specific to patching Linux machines. |
| installPatchesWindowsParameters | object | <input type="checkbox"> | None | <pre>{<br>  classificationsToInclude: [<br>    'Critical'<br>    'Security'<br>  ]<br>  kbNumbersToExclude: null<br>  kbNumbersToInclude: null<br>}</pre> | Input parameters specific to patching a Windows machine. |
| rebootSetting | string | <input type="checkbox"> | `'Always'` or  `'IfRequired'` or  `'Never'` or  `'RebootIfRequired'` | <pre>'IfRequired'</pre> | Possible reboot preference as defined by the user based on which it would be decided to reboot the machine or not after the patch operation is completed. |
| tasks | object | <input type="checkbox"> | None | <pre>{<br>  postTasks: [<br>    {}<br>  ]<br>  preTasks: [<br>    {}<br>  ]<br>}</pre> | Tasks information for the Software update configuration. See https://docs.microsoft.com/en-us/azure/templates/microsoft.maintenance/maintenanceconfigurations?pivots=deployment-language-bicep#softwareupdateconfigurationtasks |
| namespaceMaintenanceConfiguration | string | <input type="checkbox"> | None | <pre>''</pre> | The namespace for the maintenance configuration |
| visibilityMaintenanceConfiguration | string | <input type="checkbox"> | `'Public'` or  `'Custom'` | <pre>'Custom'</pre> | The visibility for the maintenance configuration. Default is Custom, which means only visible to users with permissions.<br>Public means visible to all users. |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| maintenanceConfigurationResourceId | string |  |
| maintenanceConfigurationName | string |  |

