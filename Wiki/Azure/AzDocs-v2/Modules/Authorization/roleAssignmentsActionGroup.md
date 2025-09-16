# roleAssignmentsActionGroup

Target Scope: resourceGroup

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| principalId | string | <input type="checkbox" checked> | Length is 36 | <pre></pre> | The AAD Object ID of the pricipal you want to assign the role to. |
| principalType | PrincipalType | <input type="checkbox" checked> | None | <pre></pre> | The type of principal you want to assign the role to. |
| actionGroupName | string | <input type="checkbox" checked> | Length between 6-50 | <pre></pre> | The name of the Azure Action Group to assign the permissions on. This Action Group should already be existing. |
| roleDefinitionId | string | <input type="checkbox"> | Length is 36 | <pre>'d3881f73-407a-4167-8283-e981cbba0404'</pre> | The roledefinition ID you want to assign. This defaults to the Automation Account Operator Role. |
