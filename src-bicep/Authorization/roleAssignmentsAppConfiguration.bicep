/*
.SYNOPSIS
Configuring role assignment for the App Configuration
.DESCRIPTION
This module is used for creating role assignments for existing Azure App Configuration stores.
.EXAMPLE
<pre>
module roleAppConfiguration 'br:contosoregistry.azurecr.io/authorization/roleAssignmentsAppConfiguration:latest' = {
  name: guid(configurationStore.id, principalId, roleDefinitionId)
  scope: configurationStore
  properties: {
    principalId: principalId
    roleDefinitionId: roleDefinition.id
    principalType: principalType
  }
}
</pre>
.LINKS
- [Bicep Microsoft.authorization roleassignments](https://learn.microsoft.com/en-us/azure/templates/microsoft.authorization/roleassignments?pivots=deployment-language-bicep)
*/

// ================================================= Parameters =================================================
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

@description('The name of the App Configuration store to assign the permissions on. This App Configuration store should already exist.')
@minLength(5)
@maxLength(50)
param configurationStoreName string

@description('The role definition ID you want to assign.')
@minLength(36)
@maxLength(36)
param roleDefinitionId string

@description('Fetch the existing App Configuration store for the role assignment scope in the next step.')
resource configurationStore 'Microsoft.AppConfiguration/configurationStores@2023-09-01-preview' existing = {
  name: configurationStoreName
}

@description('Fetch the role based on the given roleDefinitionId. See https://docs.microsoft.com/azure/role-based-access-control/built-in-roles')
resource roleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: resourceGroup()
  name: roleDefinitionId
}

@description('Upsert the role with the given parameters')
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' =  {
  name: guid(configurationStore.id, principalId, roleDefinitionId)
  scope: configurationStore
  properties: {
    principalId: principalId
    roleDefinitionId: roleDefinition.id
    principalType: principalType
  }
}
