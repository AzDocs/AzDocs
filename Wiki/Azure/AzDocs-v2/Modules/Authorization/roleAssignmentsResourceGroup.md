# roleAssignmentsResourceGroup

Target Scope: resourceGroup

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| principalId | string | <input type="checkbox" checked> | Length is 36 | <pre></pre> | The AAD Object ID of the pricipal you want to assign the role to. |
| principalType | string | <input type="checkbox"> | `'User'` or  `'Group'` or  `'ServicePrincipal'` or  `'Unknown'` or  `'DirectoryRoleTemplate'` or  `'ForeignGroup'` or  `'Application'` or  `'MSI'` or  `'DirectoryObjectOrGroup'` or  `'Everyone'` | <pre>'ServicePrincipal'</pre> | The type of principal you want to assign the role to. |
| roleDefinitionId | string | <input type="checkbox"> | Length is 36 | <pre>'acdd72a7-3385-48ef-bd42-f606fba81ae7'</pre> | The roledefinition ID you want to assign. This defaults to the built-in Reader Role. |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |

