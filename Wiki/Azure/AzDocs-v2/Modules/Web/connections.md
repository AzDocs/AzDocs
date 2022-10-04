# connections

Target Scope: resourceGroup

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location. |
| connectionName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the connection to upsert. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| clientId | string | <input type="checkbox" checked> | None | <pre></pre> |  |
| clientSecret | string | <input type="checkbox" checked> | None | <pre></pre> |  |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| connectionResourceId | string | Output the connection\'s resource id. |
| connectionApiVersion | string | Output the connection\'s resource API Version. |
| connectionRuntimeUrl | string | Output the connection\'s runtime URL. |

