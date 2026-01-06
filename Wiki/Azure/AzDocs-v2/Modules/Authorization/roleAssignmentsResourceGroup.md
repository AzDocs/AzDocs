# roleAssignmentsResourceGroup

Target Scope: resourceGroup

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| principalId | string | <input type="checkbox" checked> | Length is 36 | <pre></pre> | The AAD Object ID of the pricipal you want to assign the role to. |
| principalType | PrincipalType | <input type="checkbox" checked> | None | <pre></pre> | The type of principal you want to assign the role to. |
| roleDefinitionId | string | <input type="checkbox"> | Length is 36 | <pre>'acdd72a7-3385-48ef-bd42-f606fba81ae7'</pre> | The roledefinition ID you want to assign. This defaults to the built-in Reader Role. |
| roleAssignmentCondition | string | <input type="checkbox"> | None | <pre>''</pre> | The conditions on the role assignment. This limits the resources it can be assigned to.<br>It is an additional check that you can optionally add to your role assignment to provide more fine-grained access control.<br>For example, you can add a condition that requires an object to have a specific tag to read the object.<br>Example:<br>'((!(ActionMatches{\'Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read\'}))',<br>'(@Resource[Microsoft.Storage/storageAccounts/blobServices/containers:name] StringEquals \'blobs-example-container\'))' |
| roleAssignmentConditionVersion | string | <input type="checkbox"> | `'2.0'` | <pre>'2.0'</pre> | Version of the condition. Currently the only accepted value is 2.0 |
