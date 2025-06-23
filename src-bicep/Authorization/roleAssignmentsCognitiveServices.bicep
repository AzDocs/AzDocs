/*
.SYNOPSIS
Configuring role assignment for Cognitive Services
.DESCRIPTION
This module is used for creating role assignments for existing Azure Cognitive Services accounts.
.EXAMPLE
<pre>
module roleCognitiveServices 'br:contosoregistry.azurecr.io/authorization/roleassignmentscognitiveservices:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 45), 'rolecognitiveservices')
  params: {
    principalType: 'ServicePrincipal'
    principalId: 'a348f815-0d14-4a85-b2fe-d3b36519e4fd' //object id of the service principal
    roleDefinitionId: '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd' //Cognitive Services OpenAI User
    cognitiveServicesAccountName: cognitiveServicesAccount.outputs.accountName
  }
}
</pre>
<p>Assign a role on the Cognitive Services account scope to an identity</p>
.LINKS
- [Bicep Microsoft.Authorization/roleAssignments](https://learn.microsoft.com/en-us/azure/templates/microsoft.authorization/roleassignments?pivots=deployment-language-bicep)
- [Azure Cognitive Services built-in roles](https://learn.microsoft.com/en-us/azure/ai-services/authentication#assign-a-role-to-a-user)
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

@description('The name of the Cognitive Services account to assign the permissions on. This Cognitive Services account should already exist.')
@minLength(2)
@maxLength(64)
param cognitiveServicesAccountName string

// ================================================= Resources =================================================
@description('Fetch the role based on the given roleDefinitionId. See https://docs.microsoft.com/azure/role-based-access-control/built-in-roles')
resource roleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: resourceGroup()
  name: roleDefinitionId
}

@description('Fetch the existing Cognitive Services account for the role assignment scope in the next step.')
resource cognitiveServicesAccount 'Microsoft.CognitiveServices/accounts@2024-10-01' existing = {
  scope: resourceGroup()
  name: cognitiveServicesAccountName
}

@description('Upsert the role with the given parameters')
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(cognitiveServicesAccount.id, principalId, roleDefinitionId)
  scope: cognitiveServicesAccount
  properties: {
    principalId: principalId
    roleDefinitionId: roleDefinition.id
    principalType: principalType
  }
}
