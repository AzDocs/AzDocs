# routeTables

Target Scope: resourceGroup

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| routeTableName | string | <input type="checkbox" checked> | Length between 1-80 | <pre></pre> | The resourcename of the routetable. Preferably the same as the VNet |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location. |
| routes | array | <input type="checkbox" checked> | None | <pre></pre> | Array containing routes. For array/object format refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.network/routetables?tabs=bicep#route |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| routeTableName | string | Output the resourcename of this routetable. |
| routeTableResourceId | string | Output the resource id of this routetable. |

