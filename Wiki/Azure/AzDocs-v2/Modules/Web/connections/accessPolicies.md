# accessPolicies

Target Scope: resourceGroup

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location. |
| connectionsAccessPolicyName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the access policy to approve within the API connection. |
| azureActiveDirectoryPrincipalObjectId | string | <input type="checkbox" checked> | Length is 36 | <pre></pre> | The Object ID of the AAD principal to allow access to this API connection. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
