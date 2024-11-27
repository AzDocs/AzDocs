/*
.SYNOPSIS
Assigns a role on subscription level.
.DESCRIPTION
Assigns a RBAC role on subscription level to a principal.
.EXAMPLE
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
@allowed([
  'Device'
  'ForeignGroup'
  'Group'
  'ServicePrincipal'
  'User'
])
param principalType string = 'ServicePrincipal'

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

@description('The roledefinition ID you want to assign. See the [documentation](https://docs.microsoft.com/azure/role-based-access-control/built-in-roles) for the build-in roles')
@minLength(36)
@maxLength(36)
param roleDefinitionId string

@description('Fetch the role based on the given roleDefinitionId. See [documentation](https://docs.microsoft.com/azure/role-based-access-control/built-in-roles)')
resource roleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: subscription()
  name: roleDefinitionId
}

@description('Upsert the role to the chosen principal.')
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, principalId, roleDefinition.id)
  properties: {
    roleDefinitionId: roleDefinition.id
    principalId: principalId
    principalType: principalType
    condition: empty(roleAssignmentCondition) ? null : roleAssignmentCondition
    conditionVersion: empty(roleAssignmentCondition) ? null : roleAssignmentConditionVersion
    delegatedManagedIdentityResourceId: delegatedManagedIdentityResourceId
    description: roleAssignmentDescription
  }
}
