# roleAssignmentsDocumentDb

Target Scope: resourceGroup

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| principalId | string | <input type="checkbox" checked> | Length is 36 | <pre></pre> | The AAD Object ID of the pricipal you want to assign the role to. |
| principalType | string | <input type="checkbox"> | `'User'` or `'Group'` or `'ServicePrincipal'` or `'Unknown'` or `'DirectoryRoleTemplate'` or `'ForeignGroup'` or `'Application'` or `'MSI'` or `'DirectoryObjectOrGroup'` or `'Everyone'` | <pre>'ServicePrincipal'</pre> | The type of principal you want to assign the role to. |
| documentDbInstanceName | string | <input type="checkbox" checked> | Length between 3-24 | <pre></pre> | The name of the DocumentDB instance to assign the permissions on. This DocumentDB instance should already exist. |
| roleDefinitionId | string | <input type="checkbox" checked> | Length is 36 | <pre></pre> | The roledefinition ID you want to assign. |
