/*
.SYNOPSIS
Configuring role assignment for the Acr
.DESCRIPTION
This module is used for creating role assignments for existing Acr.
.EXAMPLE
<pre>
module roleAcr 'br:contosoregistry.azurecr.io/authorization/roleassignments:latest' = {
  name: guid(acr.id, principalId, roleDefinitionId)
  scope: acr
  properties: {
    principalId: principalId
    roleDefinitionId: roleDefinition.id
    principalType: principalType
  }
}
</pre>
.LINKS
- [Bicep Microsoft.authorization roleassignments](https://learn.microsoft.com/en-us/azure/templates/microsoft.authorization/roleassignments?pivots=deployment-language-bicep)
- [Bicep community example](https://github.com/your-azure-coach/ftw-ventures/blob/main/infra/modules/role-assignment-container-registry.bicep)
*/

// ================================================= Parameters =================================================
@description('The roledefinition name you want to assign.')
@allowed([
  'AcrDelete'
  'AcrImageSigner'
  'AcrPull'
  'AcrPush'
  'AcrQuarantineReader'
  'AcrQuarantineWriter'
])
param roleName string

@description('The name of the existing azure container registry.')
param containerRegistryName string

@description('The AAD Object ID of the principal you want to assign the role to.')
@minLength(36)
@maxLength(36)
param principalId string

@allowed([
  'Device'
  'ForeignGroup'
  'Group'
  'ServicePrincipal'
  'User'
])
param principalType string

// variables
var roleIds = {
  AcrDelete: resourceId('Microsoft.Authorization/roleAssignments', 'c2f4ef07-c644-48eb-af81-4b1b4947fb11')
  AcrImageSigner: resourceId('Microsoft.Authorization/roleAssignments', '6cef56e8-d556-48e5-a04f-b8e64114680f')
  AcrPull: resourceId('Microsoft.Authorization/roleAssignments', '7f951dda-4ed3-4680-a7ca-43fe172d538d')
  AcrPush: resourceId('Microsoft.Authorization/roleAssignments', '8311e382-0749-4cb8-b61a-304f252e45ec')
  AcrQuarantineReader: resourceId('Microsoft.Authorization/roleAssignments', 'cdda3590-29a3-44f6-95f2-9f980659eb04')
  AcrQuarantineWriter: resourceId('Microsoft.Authorization/roleAssignments', 'c8d4ff99-41c3-41a8-9f60-21dfdad59608')
}

resource containerRegistry  'Microsoft.ContainerRegistry/registries@2022-02-01-preview' existing = {
  name: containerRegistryName
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: guid(containerRegistry.id, principalId, roleIds[roleName])
  scope: containerRegistry
  properties: {
    roleDefinitionId: roleIds[roleName]
    principalId: principalId
    principalType: principalType
  }
}
