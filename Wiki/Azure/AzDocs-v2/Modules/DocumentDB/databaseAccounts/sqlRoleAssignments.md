# sqlRoleAssignments

Target Scope: resourceGroup

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| principalId | string | <input type="checkbox" checked> | Length is 36 | <pre></pre> | The AAD Object ID of the pricipal you want to assign the role to. |
| documentDbInstanceName | string | <input type="checkbox" checked> | Length between 3-24 | <pre></pre> | The name of the DocumentDB instance to assign the permissions on. This DocumentDB instance should already exist. |
| roleDefinitionType | string | <input type="checkbox" checked> | `'Reader'` or `'Contributor'` | <pre></pre> | The type of role you want to assign. |
