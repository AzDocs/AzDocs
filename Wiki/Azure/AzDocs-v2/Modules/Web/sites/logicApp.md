# logicApp

Target Scope: resourceGroup

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| logicAppName | string | <input type="checkbox" checked> | Length between 2-60 | <pre></pre> | The name of the Logic app. |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location. |
| appServicePlanName | string | <input type="checkbox" checked> | Length between 1-40 | <pre></pre> | The resource name of the appserviceplan to use for this logic app. |
| appServicePlanResourceGroupName | string | <input type="checkbox" checked> | Length between 1-90 | <pre></pre> | The name of the resourcegroup where the appserviceplan resides in to use for this logic app. |
| storageAccountName | string | <input type="checkbox" checked> | Length between 3-24 | <pre></pre> | The name of the storageaccount to use as the underlying storage provider for this logic app. |
| storageAccountResourceGroupName | string | <input type="checkbox"> | Length between 1-90 | <pre>az.resourceGroup().name</pre> | The name of the resourcegroup where the storageaccount resides in to use as the underlying storage provider for this logic app. Defaults to the current resourcegroup. |
| identity | object | <input type="checkbox"> | None | <pre>{<br>  type: 'SystemAssigned'<br>}</pre> | Managed service identity to use for this logic app. Defaults to a system assigned managed identity. For object format, refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.web/sites?tabs=bicep#managedserviceidentity. |
| ipSecurityRestrictions | array | <input type="checkbox"> | None | <pre>[<br>  {<br>    ipAddress: '0.0.0.0/0'<br>    action: 'Deny'<br>    tag: 'Default'<br>    priority: 10<br>    name: 'DefaultDeny'<br>    description: 'Default deny to make sure that something isnt publicly exposed on accident.'<br>  }<br>]</pre> | IP security restrictions for the main entrypoint. Defaults to closing down the appservice for all connections (you need to manually define this). For object format, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.web/sites?tabs=bicep#ipsecurityrestriction. |
| appSettings | array | <input type="checkbox"> | None | <pre>[]</pre> | Application settings. For array/object format, refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.web/sites?tabs=bicep#namevaluepair. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| logicAppName | string | Output the logic app\'s resource name. |
| logicAppPrincipalId | string | Output the logic app\'s identity principal object id. |

