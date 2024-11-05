/*
.SYNOPSIS
Assign a role on the storage account scope to an identity
.DESCRIPTION
Assign a role on the storage account scope to a identity with the given specs.
.EXAMPLE
<pre>
module roleAssignmentsStorage 'br:contosoregistry.azurecr.io/authorization/roleassignmentsstorage:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 51), 'rolesstorage')
  params: {
    principalType: 'User'
    principalId: 'a348f815-0d14-4a85-b2fe-d3b36519e4fd' //object id of the user
    roleDefinitionId: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe' //Storage Blob Data Contributor
    storageAccountName: workspaceStorage.outputs.storageAccountName
  }
}
</pre>
<p>Assign a role on the storage account scope to an identity</p>
.LINKS
- [Bicep Microsoft.Authorization/roleAssignments](https://learn.microsoft.com/en-us/azure/templates/microsoft.authorization/roleassignments?pivots=deployment-language-bicep)
*/

@description('The AAD Object ID of the pricipal you want to assign the role to.')
@minLength(36)
@maxLength(36)
param principalId string

@description('The type of principal you want to assign the role to.')
@allowed([
  'User'
  'Group'
  'ServicePrincipal'
  'Unknown'
  'DirectoryRoleTemplate'
  'ForeignGroup'
  'Application'
  'MSI'
  'DirectoryObjectOrGroup'
  'Everyone'
])
param principalType string = 'ServicePrincipal'

@description('The name of the Storage Account to assign the permissions on. This Storage Account should already exist.')
@minLength(3)
@maxLength(24)
param storageAccountName string

@description('The roledefinition ID you want to assign.')
@minLength(36)
@maxLength(36)
param roleDefinitionId string

@description('Fetch the existing storage account for the role assignment scope in the next step.')
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountName
}

@description('Fetch the role based on the given roleDefinitionId. See [Link](https://docs.microsoft.com/azure/role-based-access-control/built-in-roles)')
resource roleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: resourceGroup()
  name: roleDefinitionId
}

@description('Upsert the role with the given parameters')
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' =  {
  name: guid(storageAccount.id, principalId, roleDefinitionId)
  scope: storageAccount
  properties: {
    principalId: principalId
    roleDefinitionId: roleDefinition.id
    principalType: principalType
  }
}
