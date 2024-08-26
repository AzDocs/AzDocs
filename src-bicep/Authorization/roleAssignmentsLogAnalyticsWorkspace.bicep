/*
.SYNOPSIS
Configuring role assignment for the Log Analytics Workspace
.DESCRIPTION
This module is used for creating role assignments for existing Azure Log Analytics Workspace.
.EXAMPLE
<pre>
module rolelogAnalyticsWorkspace 'br:contosoregistry.azurecr.io/authorization/roleassignments:latest' = {
  name: guid(logAnalyticsWorkspace.id, principalId, roleDefinitionId)
  scope: logAnalyticsWorkspace
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

@description('The name of the Log Analytics Workspace to assign the permissions on. This Log Analytics Workspace should already exist.')
@minLength(4)
@maxLength(63)
param logAnalyticsWorkspaceName string

@description('Fetch the role based on the given roleDefinitionId. See https://docs.microsoft.com/azure/role-based-access-control/built-in-roles')
resource roleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: resourceGroup()
  name: roleDefinitionId
}

@description('Fetch the existing Log Analytics Workspace for the role assignment scope in the next step.')
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = {
  scope: resourceGroup()
  name: logAnalyticsWorkspaceName
}

@description('Upsert the role with the given parameters')
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(logAnalyticsWorkspace.id, principalId, roleDefinitionId)
  scope: logAnalyticsWorkspace
  properties: {
    principalId: principalId
    roleDefinitionId: roleDefinition.id
    principalType: principalType
  }
}
