/*
.SYNOPSIS
Configuring role assignment for API Management Service.
.DESCRIPTION
This module is used for creating role assignments for existing API Management Service.
.EXAMPLE
<pre>
module roleApiManagment 'br:contosoregistry.azurecr.io/authorization/roleassignments:latest' = {
  name: guid(apiManagmentService.id, principalId, roleDefinitionId)
  scope: apiManagementService
  properties: {
    principalId: principalId
    roleDefinitionId: roleDefinition.id
    principalType: principalType
  }
}
</pre>
.LINKS
- [Bicep Microsoft.authorization roleassignments](https://learn.microsoft.com/en-us/azure/templates/microsoft.authorization/roleassignments?pivots=deployment-language-bicep)
- [Bicep community example](https://github.com/your-azure-coach/ftw-ventures/blob/main/infra/modules/role-assignment-api-management.bicep)
*/

// ================================================= Parameters =================================================
@description('The roledefinition ID you want to assign.')
@minLength(36)
@maxLength(36)
param roleDefinitionId string

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
param principalType string

@description('''
Character limit: 1-50

Valid characters:
Alphanumerics and hyphens.

Start with letter and end with alphanumeric.

Resource name must be unique across Azure.
''')
@minLength(1)
@maxLength(50)
param apiManagementServiceName string

@description('Fetch the role based on the given roleDefinitionId. See https://docs.microsoft.com/azure/role-based-access-control/built-in-roles')
resource roleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: resourceGroup()
  name: roleDefinitionId
}

resource apiManagementService 'Microsoft.ApiManagement/service@2023-03-01-preview' existing = {
  name: apiManagementServiceName
}

@description('Upsert the role with the given parameters')
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(apiManagementService.id, principalId, roleDefinitionId)
  scope: apiManagementService
  properties: {
    principalId: principalId
    roleDefinitionId: roleDefinition.id
    principalType: principalType
  }
}
