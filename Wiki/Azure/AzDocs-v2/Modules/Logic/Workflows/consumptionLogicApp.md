# consumptionLogicApp

Target Scope: resourceGroup

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | The location of this logic app to reside in. This defaults to the resourcegroup location. |
| logicAppName | string | <input type="checkbox" checked> | Length between 1-43 | <pre></pre> | The resource name of the logic app |
| logicAppIdentity | object | <input type="checkbox"> | None | <pre>{<br>  type: 'SystemAssigned'<br>}</pre> | The identity object for this logic app. This defaults to a System Assigned Managed Identity. For formatting, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.logic/workflows?pivots=deployment-language-bicep#managedserviceidentity. |
| definition | object | <input type="checkbox"> | None | <pre>{}</pre> | The definition for this logic app. For options & formatting, please refer to https://docs.microsoft.com/en-us/azure/logic-apps/logic-apps-workflow-definition-language.<br>Example:<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'&#36;schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;actions: []<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;contentVersion: '1.0.0.0'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;outputs: []<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;parameters: []<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;triggers: []<br>&nbsp;&nbsp;&nbsp;} |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| principalId | string | Output the principal ID for the identity running this logic app. |
| logicAppName | string | Output the logic app\'s resource name. |

