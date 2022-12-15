# roleAssignmentsSubscription

Target Scope: subscription

## Synopsis
Assigns a role on subscription level.

## Description
Assigns a RBAC role on subscription level to a principal.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| principalId | string | <input type="checkbox" checked> | Length is 36 | <pre></pre> | The AAD Object ID of the pricipal you want to assign the role to. |
| principalType | string | <input type="checkbox"> | `'Device'` or  `'ForeignGroup'` or  `'Group'` or  `'ServicePrincipal'` or  `'User'` | <pre>'ServicePrincipal'</pre> | The type of principal you want to assign the role to. |
| roleAssignmentCondition | string | <input type="checkbox"> | None | <pre>''</pre> | The conditions on the role assignment. This limits the resources it can be assigned to.<br>It is an additional check that you can optionally add to your role assignment to provide more fine-grained access control.<br>For example, you can add a condition that requires an object to have a specific tag to read the object.<br>Example:<br>'((!(ActionMatches{\'Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read\'}))',<br>'(@Resource[Microsoft.Storage/storageAccounts/blobServices/containers:name] StringEquals \'blobs-example-container\'))' |
| roleAssignmentConditionVersion | string | <input type="checkbox"> | `'2.0'` | <pre>'2.0'</pre> | Version of the condition. Currently the only accepted value is 2.0 |
| delegatedManagedIdentityResourceId | string | <input type="checkbox"> | None | <pre>''</pre> | Id of the delegated managed identity resource. These kind of identities can be useful in a cross tenant scenario.<br>This property allows you to include a managed identity that resides in the customer tenant (in a subscription or resource group that has been onboarded to Azure Lighthouse). |
| roleAssignmentDescription | string | <input type="checkbox"> | None | <pre>''</pre> | Description of role assignment. |
| roleDefinitionId | string | <input type="checkbox" checked> | Length is 36 | <pre></pre> | The roledefinition ID you want to assign. See the [documentation](https://docs.microsoft.com/azure/role-based-access-control/built-in-roles) for the build-in roles |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |
## Examples
<pre>
module azureKubernetesServiceContributorRoleToDfcPolicyAssignmentUserAssignedManagedIdentity '../AzDocs/src-bicep/Authorization/roleAssignmentsSubscription.bicep' = {
  name: format('{0}-{1}', take('${deployment().name}', 46), 'akscontrole')
  scope: subscription()
  params: {
    principalId: dfcPolicyAssignmentUserAssignedManagedIdentity.outputs.userManagedIdentityPrincipalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: 'ed7f3fbd-7b88-4dd4-9017-9adb7ce333f8'
  }
}
</pre>
<p>Assigns the role Azure Kubernetes Service Contributor Role to the Principal on subscription level.</p>

## Links
- [Bicep Microsoft.Authorization roleAssignments](https://learn.microsoft.com/en-us/azure/templates/microsoft.authorization/roleassignments?pivots=deployment-language-bicep)


