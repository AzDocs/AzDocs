# roleAssignmentsSubscription

Target Scope: subscription

## Synopsis
Assigns a role on subscription level.

## Description
Assign a role on the subscription scope to an identity with the given specs.<br>
Supports role input by GUID (legacy roleDefinitionId), role name, or full role definition resource ID (roleDefinitionIdOrName).<br>
<br>
Role definition input behavior:<br>
1) roleDefinitionIdOrName when not empty<br>
2) otherwise roleDefinitionId<br>
3) fail() when both are empty

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| principalId | string | <input type="checkbox" checked> | Length is 36 | <pre></pre> | The AAD Object ID of the pricipal you want to assign the role to. |
| principalType | PrincipalType | <input type="checkbox" checked> | None | <pre></pre> | The type of principal you want to assign the role to. |
| roleAssignmentCondition | string | <input type="checkbox"> | None | <pre>''</pre> | The conditions on the role assignment. This limits the resources it can be assigned to.<br>It is an additional check that you can optionally add to your role assignment to provide more fine-grained access control.<br>For example, you can add a condition that requires an object to have a specific tag to read the object.<br>Example:<br>'((!(ActionMatches{\'Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read\'}))',<br>'(@Resource[Microsoft.Storage/storageAccounts/blobServices/containers:name] StringEquals \'blobs-example-container\'))' |
| roleAssignmentConditionVersion | string | <input type="checkbox"> | `'2.0'` | <pre>'2.0'</pre> | Version of the condition. Currently the only accepted value is 2.0 |
| delegatedManagedIdentityResourceId | string | <input type="checkbox"> | None | <pre>''</pre> | Id of the delegated managed identity resource. These kind of identities can be useful in a cross tenant scenario.<br>This property allows you to include a managed identity that resides in the customer tenant (in a subscription or resource group that has been onboarded to Azure Lighthouse). |
| roleAssignmentDescription | string | <input type="checkbox"> | None | <pre>''</pre> | Description of role assignment. |
| roleDefinitionId | string? | <input type="checkbox" checked> | Length is 36 | <pre></pre> | Legacy role definition ID input for backward compatibility. Provide a role definition GUID. If roleDefinitionIdOrName is also provided, roleDefinitionIdOrName takes precedence. See [documentation](https://docs.microsoft.com/azure/role-based-access-control/built-in-roles). |
| roleDefinitionIdOrName | string | <input type="checkbox"> | None | <pre>roleDefinitionId ?? ''</pre> | The roledefinition to assign. Supports built-in role name, role definition GUID, or full role definition resource ID. |

## Examples
<pre>
module roleAssignmentsSubscription 'br:contosoregistry.azurecr.io/authorization/roleassignmentssubscription:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 46), 'rolessub')
  scope: subscription()
  params: {
    principalType: 'User'
    principalId: 'a348f815-0d14-4a85-b2fe-d3b36519e4fd' // object id of the user
    roleDefinitionIdOrName: 'Reader' // can also be a GUID or full role definition resource ID
  }
}
</pre>
<p>Assign a role on the subscription scope to an identity</p>

## Links
- [Bicep Microsoft.Authorization roleAssignments](https://learn.microsoft.com/en-us/azure/templates/microsoft.authorization/roleassignments?pivots=deployment-language-bicep)
