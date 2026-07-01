import { PrincipalType } from '../Common/authorizationTypes.bicep'
/*
.SYNOPSIS
Assign a role on the storage account scope to an identity
.DESCRIPTION
Assign a role on the storage account scope to a identity with the given specs.
Supports role input by GUID (legacy roleDefinitionId), role name, or full role definition resource ID (roleDefinitionIdOrName).

Role definition input behavior:
1) roleDefinitionIdOrName when not empty
2) otherwise roleDefinitionId
3) fail() when both are empty
.EXAMPLE
<pre>
module roleAssignmentsStorage 'br:contosoregistry.azurecr.io/authorization/roleassignmentsstorage:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 51), 'rolesstorage')
  params: {
    principalType: 'User'
    principalId: 'a348f815-0d14-4a85-b2fe-d3b36519e4fd' //object id of the user
    roleDefinitionIdOrName: 'Storage Blob Data Contributor' // can also be GUID or full role definition resource ID
    storageAccountName: workspaceStorage.outputs.storageAccountName
  }
}
</pre>
<p>Assign a role on the storage account scope to an identity</p>
.LINKS
- [Bicep Microsoft.Authorization/roleAssignments](https://learn.microsoft.com/en-us/azure/templates/microsoft.authorization/roleassignments?pivots=deployment-language-bicep)
*/

@description('The AAD Object ID of the pricipal you want to assign the role to.')
@minLength(36)
@maxLength(36)
param principalId string

@description('The type of principal you want to assign the role to.')
param principalType PrincipalType

@description('The name of the Storage Account to assign the permissions on. This Storage Account should already exist.')
@minLength(3)
@maxLength(24)
param storageAccountName string

@description('Legacy role definition ID input for backward compatibility. Provide a role definition GUID. If roleDefinitionIdOrName is also provided, roleDefinitionIdOrName takes precedence.')
@minLength(36)
@maxLength(36)
param roleDefinitionId string?

@description('The roledefinition to assign. Supports built-in role name, role definition GUID, or full role definition resource ID.')
param roleDefinitionIdOrName string = roleDefinitionId ?? ''

@description('Optional. The conditions on the role assignment. This limits the resources it can be assigned to. e.g.: @Resource[Microsoft.Storage/storageAccounts/blobServices/containers:ContainerName] StringEqualsIgnoreCase "foo_storage_container"')
param condition string?

@description('Optional. Version of the condition. Currently the only accepted value is 2.0.')
@allowed([
  '2.0'
])
param conditionVersion string?

@description('Fetch the existing storage account for the role assignment scope in the next step.')
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountName
}

var builtInRoleNames = {
  Contributor: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
  Owner: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '8e3af657-a8ff-443c-a75c-2fe8c4bcb635')
  Reader: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'acdd72a7-3385-48ef-bd42-f606fba81ae7')
  'Reader and Data Access': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'c12c1c16-33a1-487b-954d-41c89c60f349'
  )
  'Role Based Access Control Administrator': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'f58310d9-a9f6-439a-9e8d-f62e7b41a168'
  )
  'Storage Account Backup Contributor': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'e5e2a7ff-d759-4cd2-bb51-3152d37e2eb1'
  )
  'Storage Account Contributor': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '17d1049b-9a84-46fb-8f53-869881c3d3ab'
  )
  'Storage Account Key Operator Service Role': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '81a9662b-bebf-436f-a333-f67b29880f12'
  )
  'Storage Blob Data Contributor': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
  )
  'Storage Blob Data Owner': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'b7e6dc6d-f1e8-4753-8033-0f276bb0955b'
  )
  'Storage Blob Data Reader': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1'
  )
  'Storage Blob Delegator': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'db58b8e5-c6ad-4a2a-8342-4190687cbf4a'
  )
  'Storage File Data Privileged Contributor': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '69566ab7-960f-475b-8e7c-b3118f30c6bd'
  )
  'Storage File Data Privileged Reader': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'b8eda974-7b85-4f76-af95-65846b26df6d'
  )
  'Storage File Data SMB Share Contributor': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '0c867c2a-1d8c-454a-a3db-ab2ea1bdc8bb'
  )
  'Storage File Data SMB Share Elevated Contributor': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'a7264617-510b-434b-a828-9731dc254ea7'
  )
  'Storage File Data SMB Share Reader': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'aba4ae5f-2193-4029-9191-0cb91df5e314'
  )
  'Storage Queue Data Contributor': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '974c5e8b-45b9-4653-ba55-5f855dd0fb88'
  )
  'Storage Queue Data Message Processor': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '8a0f0c08-91a1-4084-bc3d-661d67233fed'
  )
  'Storage Queue Data Message Sender': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'c6a89b2d-59bc-44d0-9896-0f6e12d7b80a'
  )
  'Storage Queue Data Reader': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '19e7f393-937e-4f77-808e-94535e297925'
  )
  'Storage Table Data Contributor': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3'
  )
  'Storage Table Data Reader': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '76199698-9eea-4c19-bc75-cec21354c6b6'
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

@description('Upsert the role with the given parameters')
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccount.id, principalId, resolvedRoleDefinitionId)
  scope: storageAccount
  properties: {
    principalId: principalId
    roleDefinitionId: resolvedRoleDefinitionId
    principalType: principalType
    condition: condition
    conditionVersion: conditionVersion
  }
}
