import { PrincipalType } from '../Common/authorizationTypes.bicep'

@description('The AAD Object ID of the pricipal you want to assign the role to.')
@minLength(36)
@maxLength(36)
param principalId string

@description('The type of principal you want to assign the role to.')
param principalType PrincipalType

@description('The roledefinition ID you want to assign. This defaults to the built-in Reader Role.')
@minLength(36)
@maxLength(36)
param roleDefinitionId string = 'acdd72a7-3385-48ef-bd42-f606fba81ae7'

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

@description('Fetch the role based on the given roleDefinitionId. See https://docs.microsoft.com/azure/role-based-access-control/built-in-roles')
resource roleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: resourceGroup()
  name: roleDefinitionId
}

@description('Upsert the role to the chosen principal.')
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(resourceGroup().id, principalId, roleDefinition.id)
  properties: {
    roleDefinitionId: roleDefinition.id
    principalId: principalId
    principalType: principalType
    condition: empty(roleAssignmentCondition) ? null : roleAssignmentCondition
    conditionVersion: empty(roleAssignmentCondition) ? null : roleAssignmentConditionVersion
  }
}
