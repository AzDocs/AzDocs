/*
.SYNOPSIS
Configuring role assignment for AppInsights.
.DESCRIPTION
This module is used for creating role assignments for existing Application Insights.
.EXAMPLE
<pre>
module roleApiManagment 'br:contosoregistry.azurecr.io/authorization/roleassignments:latest' = {
  name: guid(appInsights.id, principalId, roleDefinitionId)
  scope: appInsights
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

@description('The name of the Application Insights instance.')
@minLength(1)
@maxLength(50)
param appInsightsName string

@description('Fetch the role based on the given roleDefinitionId. See https://docs.microsoft.com/azure/role-based-access-control/built-in-roles')
resource roleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: resourceGroup()
  name: roleDefinitionId
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: appInsightsName
}

@description('Upsert the role with the given parameters')
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(appInsights.id, principalId, roleDefinitionId)
  scope: appInsights
  properties: {
    principalId: principalId
    roleDefinitionId: roleDefinition.id
    principalType: principalType
  }
}
