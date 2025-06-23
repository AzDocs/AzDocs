/*
.SYNOPSIS
Configuring role assignment for Azure Search Service
.DESCRIPTION
This module is used for creating role assignments for existing Azure Search Service (Cognitive Search).
.EXAMPLE
<pre>
module roleSearch 'br:contosoregistry.azurecr.io/authorization/roleassignmentssearch:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 55), 'rolesearch')
  params: {
    principalType: 'ServicePrincipal'
    principalId: 'a348f815-0d14-4a85-b2fe-d3b36519e4fd' //object id of the service principal
    roleDefinitionId: '7ca78c08-252a-4471-8644-bb5ff32d4ba0' //Search Service Contributor
    searchServiceName: searchService.outputs.searchServiceName
  }
}
</pre>
<p>Assign a role on the Azure Search Service scope to an identity</p>
.LINKS
- [Bicep Microsoft.Authorization/roleAssignments](https://learn.microsoft.com/en-us/azure/templates/microsoft.authorization/roleassignments?pivots=deployment-language-bicep)
- [Azure Search Service built-in roles](https://learn.microsoft.com/en-us/azure/search/search-security-rbac)
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

@description('The name of the Azure Search Service to assign the permissions on. This Search Service should already exist.')
@minLength(2)
@maxLength(60)
param searchServiceName string

// ================================================= Resources =================================================
@description('Fetch the role based on the given roleDefinitionId. See https://docs.microsoft.com/azure/role-based-access-control/built-in-roles')
resource roleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: resourceGroup()
  name: roleDefinitionId
}

@description('Fetch the existing Azure Search Service for the role assignment scope in the next step.')
resource searchService 'Microsoft.Search/searchServices@2025-02-01-Preview' existing = {
  scope: resourceGroup()
  name: searchServiceName
}

@description('Upsert the role with the given parameters')
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(searchService.id, principalId, roleDefinitionId)
  scope: searchService
  properties: {
    principalId: principalId
    roleDefinitionId: roleDefinition.id
    principalType: principalType
  }
}
