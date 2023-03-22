/*
.SYNOPSIS
Assign a role on the servicebus namespace scope to a identity
.DESCRIPTION
Assign a role on the servicebus namespace scope to a identity with the given specs.
.EXAMPLE
<pre>
resource roleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: resourceGroup()
  name: roleDefinitionId
}

module roleAssignment 'br:contosoregistry.azurecr.io/authorization/roleAssignmentsServiceBusNamespace:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 50), 'roleassign')
  scope: az.resourceGroup(serviceBusNamespaceSubscriptionId, serviceBusNamespaceResourceGroupName)
  params: {
    principalId: systemTopic.outputs.identityPrincipalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: roleDefinition.id
    serviceBusNamespaceName: serviceBusNamespace.name
  }
}
</pre>
<p>Assign a role on the servicebus namespace scope to a identity</p>
.LINKS
- [Bicep Microsoft.Authorization/roleAssignments](https://learn.microsoft.com/en-us/azure/templates/microsoft.authorization/roleassignments?pivots=deployment-language-bicep)
*/

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

@description('The name of the Storage Account to assign the permissions on. This Storage Account should already exist.')
@minLength(3)
@maxLength(24)
param serviceBusNamespaceName string

@description('The roledefinition ID you want to assign.')
@minLength(36)
@maxLength(36)
param roleDefinitionId string

@description('Fetch the existing storage account for the role assignment scope in the next step.')
resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' existing = {
  name: serviceBusNamespaceName
}

@description('Fetch the role based on the given roleDefinitionId. See https://docs.microsoft.com/azure/role-based-access-control/built-in-roles')
resource roleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: resourceGroup()
  name: roleDefinitionId
}

@description('Upsert the role with the given parameters')
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(serviceBusNamespace.id, principalId, roleDefinitionId)
  scope: serviceBusNamespace
  properties: {
    principalId: principalId
    roleDefinitionId: roleDefinition.id
    principalType: principalType
  }
}
