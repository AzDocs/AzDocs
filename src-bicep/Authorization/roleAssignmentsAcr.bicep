import { PrincipalType } from '../Common/authorizationTypes.bicep'
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
  'Container Registry Cache Rule Administrator'
  'Container Registry Cache Rule Reader'
  'Container Registry Configuration Reader and Data Access Configuration Reader'
  'Container Registry Contributor and Data Access Configuration Administrator'
  'Container Registry Credential Set Administrator'
  'Container Registry Credential Set Reader'
  'Container Registry Data Importer and Data Reader'
  'Container Registry Repository Catalog Lister'
  'Container Registry Repository Contributor'
  'Container Registry Repository Reader'
  'Container Registry Repository Writer'
  'Container Registry Transfer Pipeline Contributor'
  'Reader'
  'Contributor'
])
param roleName string

@description('The name of the existing azure container registry.')
param containerRegistryName string

@description('The AAD Object ID of the principal you want to assign the role to.')
@minLength(36)
@maxLength(36)
param principalId string

@description('The type of principal you want to assign the role to.')
param principalType PrincipalType

// variables
var roleIds = {
  AcrDelete: resourceId('Microsoft.Authorization/roleDefinitions', 'c2f4ef07-c644-48eb-af81-4b1b4947fb11')
  AcrImageSigner: resourceId('Microsoft.Authorization/roleDefinitions', '6cef56e8-d556-48e5-a04f-b8e64114680f')
  AcrPull: resourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')
  AcrPush: resourceId('Microsoft.Authorization/roleDefinitions', '8311e382-0749-4cb8-b61a-304f252e45ec')
  AcrQuarantineReader: resourceId('Microsoft.Authorization/roleDefinitions', 'cdda3590-29a3-44f6-95f2-9f980659eb04')
  AcrQuarantineWriter: resourceId('Microsoft.Authorization/roleDefinitions', 'c8d4ff99-41c3-41a8-9f60-21dfdad59608')
  'Container Registry Cache Rule Administrator': resourceId('Microsoft.Authorization/roleDefinitions', '35dda2b7-4b46-4db2-8f08-e3e4fcd41fa9')
  'Container Registry Cache Rule Reader': resourceId('Microsoft.Authorization/roleDefinitions', '6c9db76c-ddcd-4b05-99a0-51cf11b5cdbb')
  'Container Registry Configuration Reader and Data Access Configuration Reader': resourceId('Microsoft.Authorization/roleDefinitions', '8cb1e6d1-fc17-4dae-a190-b282f4ae1486')
  'Container Registry Contributor and Data Access Configuration Administrator': resourceId('Microsoft.Authorization/roleDefinitions', '417f8645-95cb-4355-a2ba-64199e5e6ddb')
  'Container Registry Credential Set Administrator': resourceId('Microsoft.Authorization/roleDefinitions', '243d4f37-6dc6-40ec-85fb-ca09f588e01c')
  'Container Registry Credential Set Reader': resourceId('Microsoft.Authorization/roleDefinitions', 'cf8bba34-4d27-4e00-bc6d-7dae04f24f56')
  'Container Registry Data Importer and Data Reader': resourceId('Microsoft.Authorization/roleDefinitions', '03eab621-e04d-47d1-bbc7-4220a43a2be0')
  'Container Registry Repository Catalog Lister': resourceId('Microsoft.Authorization/roleDefinitions', 'ca0e8167-73ea-4da0-a53c-fab202a4a38e')
  'Container Registry Repository Contributor': resourceId('Microsoft.Authorization/roleDefinitions', '3ef6f26b-2c4f-4f96-b861-42e1a90c7b3f')
  'Container Registry Repository Reader': resourceId('Microsoft.Authorization/roleDefinitions', 'fb3a3e61-5255-4e39-851f-8e14aae8d56f')
  'Container Registry Repository Writer': resourceId('Microsoft.Authorization/roleDefinitions', '1a11be78-af35-4b0f-b8f7-2e90ad1e33e2')
  'Container Registry Transfer Pipeline Contributor': resourceId('Microsoft.Authorization/roleDefinitions', 'f38fe75c-1a48-4b40-87be-3acf6a05c3ae')
  Reader: resourceId('Microsoft.Authorization/roleDefinitions', 'acdd72a7-3385-48ef-bd42-f606fba81ae7')
  Contributor: resourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2022-02-01-preview' existing = {
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
