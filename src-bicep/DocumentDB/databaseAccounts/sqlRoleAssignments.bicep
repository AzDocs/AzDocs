@description('The AAD Object ID of the pricipal you want to assign the role to.')
@minLength(36)
@maxLength(36)
param principalId string

@description('The name of the DocumentDB instance to assign the permissions on. This DocumentDB instance should already exist.')
@minLength(3)
@maxLength(24)
param documentDbInstanceName string

@description('The type of role you want to assign.')
@allowed([
  'Reader'
  'Contributor'
])
param roleDefinitionType string

@description('Currently only supports 2 roles (Cosmos DB Built-in Data Reader & Cosmos DB Built-in Data Contributor) as per https://learn.microsoft.com/en-us/azure/cosmos-db/how-to-setup-rbac.')
var roleDefinitionId = roleDefinitionType == 'Contributor' ? '00000000-0000-0000-0000-000000000002' : '00000000-0000-0000-0000-000000000001'
var roleAssignmentId = guid(roleDefinitionId, principalId, documentDb.id)

@description('Fetch the existing storage account for the role assignment scope in the next step.')
resource documentDb 'Microsoft.DocumentDB/databaseAccounts@2023-04-15' existing = {
  name: documentDbInstanceName
}

resource sqlRoleDefinition 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2021-04-15' existing = {
  name: roleDefinitionId
  parent: documentDb
}

@description('Upsert the role with the given parameters')
resource roleAssignment 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2023-04-15' = {
  name: roleAssignmentId
  parent: documentDb
  properties: {
    principalId: principalId
    roleDefinitionId: sqlRoleDefinition.id
    scope: documentDb.id
  }
}
