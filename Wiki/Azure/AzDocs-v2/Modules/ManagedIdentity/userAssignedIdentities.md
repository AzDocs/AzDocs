# userAssignedIdentities

Target Scope: resourceGroup

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | The location of this logic app to reside in. This defaults to the resourcegroup location. |
| userAssignedManagedIdentityName | string | <input type="checkbox" checked> | Length between 3-128 | <pre></pre> | The name to assign to this user assigned managed identity. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| userManagedIdentityId | string | The User Assigned Managed Identities Resource ID. |
| userManagedIdentityPrincipalId | string | The User Assigned Managed Identities Principal ID. |
| userManagedIdentityClientId | string | The User Assigned Managed Identities Client ID. |
| userManagedIdentityName | string | The User Assigned Managed Identities Resource name. |
| userManagedIdentityObjectId | string | The User Assigned Managed Identities Object (principal) ID. |

