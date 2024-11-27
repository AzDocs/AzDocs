/*
.SYNOPSIS
Create a Synapse Workspace administrators.
.DESCRIPTION
Create a Synapse Workspace administrators and assign an identity (e.g a managed identity) as admin of synapse workspacewith the given specs.
.EXAMPLE
<pre>
module synapseadmins 'br:contosoregistry.azurecr.io/synapse/workspaces/administrators:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 50), 'synapseadmins')
  params: {
    synapseWorkSpaceName: 'synapsews'
    userAssignedManagedIdentityName: replace(resourceGroup().name, 'rg', 'mi') //will be the admin of the synapse workspace and the UIM will be created
  }
}
</pre>
<p>Creates an Synapse Analytics Workspace administrators.</p>
.LINKS
- [Bicep Microsoft.Synapse workspaces administrators](https://learn.microsoft.com/en-us/azure/templates/microsoft.synapse/workspaces/administrators?pivots=deployment-language-bicep)
*/

// ================================================= Parameters =================================================
@description('Required. Name of the existing Synapse Workspace.')
@minLength(5)
@maxLength(50)
param synapseWorkSpaceName string

@description('Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location.')
param location string = resourceGroup().location

@description('The name to assign to this user assigned managed identity.')
param userAssignedManagedIdentityName string = replace(resourceGroup().name, 'rg', 'mi')

@description('Required. Object ID of the workspace active directory administrator. This can be a EntraId Group or User Object ID.')
@secure()
param sidObjectId string = ''

// ================================================= Existing Resources ========================================
@description('Existing Synapse Workspace')
resource synapseWorkspace 'Microsoft.Synapse/workspaces@2021-06-01' existing = {
  name: synapseWorkSpaceName
}

// ================================================= Resources =================================================
@description('Create a managed identity used for the role assignment during the deployment.')
resource synapseManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' = if (empty(sidObjectId)) {
  name: userAssignedManagedIdentityName
  location: location
}

@description('Assign an identity as admin of synapse workspace.')
resource synapseAdminAssignment 'Microsoft.Synapse/workspaces/administrators@2021-06-01' = {
  name: 'activeDirectory'
  parent: synapseWorkspace
  properties: {
    administratorType: 'ActiveDirectory'
    sid: !empty(sidObjectId) ? sidObjectId : synapseManagedIdentity.properties.principalId
    tenantId: subscription().tenantId
  }
}

// Assign the Azure RBAC "Owner" role on the Synapse workspace to the UIM identity if created
var roleDefinitionId = subscriptionResourceId(
  'Microsoft.Authorization/roleDefinitions',
  '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
) // Owner
resource identityRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (empty(sidObjectId)) {
  name: guid(subscription().subscriptionId, synapseManagedIdentity.id, roleDefinitionId)
  scope: synapseWorkspace
  properties: {
    principalId: synapseManagedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: roleDefinitionId
  }
}
