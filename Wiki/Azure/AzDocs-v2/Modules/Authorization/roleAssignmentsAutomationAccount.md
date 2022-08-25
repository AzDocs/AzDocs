# roleAssignmentsAutomationAccount

Target Scope: resourceGroup

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| principalId | string | <input type="checkbox" checked> | Length is 36 | <pre></pre> | The AAD Object ID of the pricipal you want to assign the role to. |
| principalType | string | <input type="checkbox"> | `'User'` or  `'Group'` or  `'ServicePrincipal'` or  `'Unknown'` or  `'DirectoryRoleTemplate'` or  `'ForeignGroup'` or  `'Application'` or  `'MSI'` or  `'DirectoryObjectOrGroup'` or  `'Everyone'` | <pre>'ServicePrincipal'</pre> | The type of principal you want to assign the role to. |
| automationAccountName | string | <input type="checkbox" checked> | Length between 6-50 | <pre></pre> | The name of the Azure Automation Account to assign the permissions on. This Automation Account should already exist. |
| roleDefinitionId | string | <input type="checkbox"> | Length is 36 | <pre>'d3881f73-407a-4167-8283-e981cbba0404'</pre> | The roledefinition ID you want to assign. This defaults to the Automation Account Operator Role. |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |

