import { PrincipalType } from '../Common/authorizationTypes.bicep'
/*
.SYNOPSIS
Assigns a role on subscription level.
.DESCRIPTION
Assign a role on the subscription scope to an identity with the given specs.
Supports role input by GUID (legacy roleDefinitionId), role name, or full role definition resource ID (roleDefinitionIdOrName).

Role definition input behavior:
1) roleDefinitionIdOrName when not empty
2) otherwise roleDefinitionId
3) fail() when both are empty
.EXAMPLE
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
.LINKS
- [Bicep Microsoft.Authorization roleAssignments](https://learn.microsoft.com/en-us/azure/templates/microsoft.authorization/roleassignments?pivots=deployment-language-bicep)
*/

// ================================================= Parameters =================================================
targetScope = 'subscription'

@description('The AAD Object ID of the pricipal you want to assign the role to.')
@minLength(36)
@maxLength(36)
param principalId string

@description('The type of principal you want to assign the role to.')
param principalType PrincipalType

@description('''
The conditions on the role assignment. This limits the resources it can be assigned to.
It is an additional check that you can optionally add to your role assignment to provide more fine-grained access control.
For example, you can add a condition that requires an object to have a specific tag to read the object.
Example:
'((!(ActionMatches{\'Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read\'}))',
'(@Resource[Microsoft.Storage/storageAccounts/blobServices/containers:name] StringEquals \'blobs-example-container\'))'
''')
param roleAssignmentCondition string = ''

@description('Version of the condition. Currently the only accepted value is 2.0')
@allowed([
  '2.0'
])
param roleAssignmentConditionVersion string = '2.0'

@description('''
Id of the delegated managed identity resource. These kind of identities can be useful in a cross tenant scenario.
This property allows you to include a managed identity that resides in the customer tenant (in a subscription or resource group that has been onboarded to Azure Lighthouse).
''')
param delegatedManagedIdentityResourceId string = ''

@description('Description of role assignment.')
param roleAssignmentDescription string = ''

@description('Legacy role definition ID input for backward compatibility. Provide a role definition GUID. If roleDefinitionIdOrName is also provided, roleDefinitionIdOrName takes precedence. See [documentation](https://docs.microsoft.com/azure/role-based-access-control/built-in-roles).')
@minLength(36)
@maxLength(36)
param roleDefinitionId string?

@description('The roledefinition to assign. Supports built-in role name, role definition GUID, or full role definition resource ID.')
param roleDefinitionIdOrName string = roleDefinitionId ?? ''

var builtInRoleNames = {
  Contributor: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
  Owner: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '8e3af657-a8ff-443c-a75c-2fe8c4bcb635')
  Reader: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'acdd72a7-3385-48ef-bd42-f606fba81ae7')
}

var effectiveRoleDefinitionInput = !empty(roleDefinitionIdOrName)
  ? roleDefinitionIdOrName
  : (roleDefinitionId ?? '')

var validatedRoleDefinitionInput = empty(effectiveRoleDefinitionInput)
  ? fail('Either roleDefinitionId or roleDefinitionIdOrName must be provided.')
  : effectiveRoleDefinitionInput

var resolvedRoleDefinitionId = builtInRoleNames[?validatedRoleDefinitionInput] ?? (contains(validatedRoleDefinitionInput, '/providers/Microsoft.Authorization/roleDefinitions/') ? validatedRoleDefinitionInput : subscriptionResourceId('Microsoft.Authorization/roleDefinitions', validatedRoleDefinitionInput))


@description('Upsert the role to the chosen principal.')
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, principalId, resolvedRoleDefinitionId)
  properties: {
    roleDefinitionId: resolvedRoleDefinitionId
    principalId: principalId
    principalType: principalType
    condition: empty(roleAssignmentCondition) ? null : roleAssignmentCondition
    conditionVersion: empty(roleAssignmentCondition) ? null : roleAssignmentConditionVersion
    delegatedManagedIdentityResourceId: !empty(delegatedManagedIdentityResourceId)
        ? delegatedManagedIdentityResourceId
        : null
    description: roleAssignmentDescription
  }
}
