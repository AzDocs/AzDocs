import { PrincipalType } from '../Common/authorizationTypes.bicep'
/*
.SYNOPSIS
Configuring role assignment for the App Configuration
.DESCRIPTION
This module is used for creating role assignments for existing Azure App Configuration stores.
Supports role input by GUID (legacy roleDefinitionId), role name, or full role definition resource ID (roleDefinitionIdOrName).

Role definition input behavior:
1) roleDefinitionIdOrName when not empty
2) otherwise roleDefinitionId
3) fail() when both are empty
.EXAMPLE
<pre>
module roleAppConfiguration 'br:contosoregistry.azurecr.io/authorization/roleAssignmentsAppConfiguration:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 45), 'rolesappconfig')
  params: {
    principalType: 'User'
    principalId: 'a348f815-0d14-4a85-b2fe-d3b36519e4fd' // object id of the user
    roleDefinitionIdOrName: 'App Configuration Data Reader' // can also be GUID or full role definition resource ID
    configurationStoreName: appConfiguration.outputs.configurationStoreName
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
param principalType PrincipalType

@description('The name of the App Configuration store to assign the permissions on. This App Configuration store should already exist.')
@minLength(5)
@maxLength(50)
param configurationStoreName string

@description('Legacy role definition ID input for backward compatibility. Provide a role definition GUID. If roleDefinitionIdOrName is also provided, roleDefinitionIdOrName takes precedence.')
@minLength(36)
@maxLength(36)
param roleDefinitionId string?

@description('The roledefinition to assign. Supports built-in role name, role definition GUID, or full role definition resource ID.')
param roleDefinitionIdOrName string = roleDefinitionId ?? ''

var builtInRoleNames = {
  'App Compliance Automation Administrator': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '0f37683f-2463-46b6-9ce7-9b788b988ba2'
  )
  'App Compliance Automation Reader': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'ffc6bbe0-e443-4c3b-bf54-26581bb2f78e'
  )
  'App Configuration Data Owner': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '5ae67dd6-50cb-40e7-96ff-dc2bfa4b606b'
  )
  'App Configuration Data Reader': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '516239f1-63e1-4d78-a4de-a74fb236a071'
  )
  'App Configuration Reader': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '175b81b9-6e0d-490a-85e4-0d422273c10c'
  )
  'App Configuration Contributor': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'fe86443c-f201-4fc4-9d2a-ac61149fbda0'
  )
  Contributor: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
  Owner: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '8e3af657-a8ff-443c-a75c-2fe8c4bcb635')
  Reader: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'acdd72a7-3385-48ef-bd42-f606fba81ae7')
  'Role Based Access Control Administrator': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'f58310d9-a9f6-439a-9e8d-f62e7b41a168'
  )
  'User Access Administrator': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '18d7d88d-d35e-4fb5-a5c3-7773c20a72d9'
  )
}

var effectiveRoleDefinitionInput = !empty(roleDefinitionIdOrName)
  ? roleDefinitionIdOrName
  : (roleDefinitionId ?? '')

var validatedRoleDefinitionInput = empty(effectiveRoleDefinitionInput)
  ? fail('Either roleDefinitionId or roleDefinitionIdOrName must be provided.')
  : effectiveRoleDefinitionInput

var resolvedRoleDefinitionId = builtInRoleNames[?validatedRoleDefinitionInput] ?? (contains(validatedRoleDefinitionInput, '/providers/Microsoft.Authorization/roleDefinitions/') ? validatedRoleDefinitionInput : subscriptionResourceId('Microsoft.Authorization/roleDefinitions', validatedRoleDefinitionInput))

@description('Fetch the existing App Configuration store for the role assignment scope in the next step.')
resource configurationStore 'Microsoft.AppConfiguration/configurationStores@2023-09-01-preview' existing = {
  name: configurationStoreName
}

@description('Upsert the role with the given parameters')
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(configurationStore.id, principalId, resolvedRoleDefinitionId)
  scope: configurationStore
  properties: {
    principalId: principalId
    roleDefinitionId: resolvedRoleDefinitionId
    principalType: principalType
  }
}
