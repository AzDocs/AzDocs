import { PrincipalType } from '../Common/authorizationTypes.bicep'
/*
.SYNOPSIS
Configuring role assignment for a Kusto cluster.
.DESCRIPTION
This module is used for creating role assignments for an existing Azure Data Explorer (Kusto) cluster.
Supports role input by GUID (legacy roleDefinitionId), role name, or full role definition resource ID (roleDefinitionIdOrName).

Role definition input behavior:
1) roleDefinitionIdOrName when not empty
2) otherwise roleDefinitionId
3) fail() when both are empty
.EXAMPLE
<pre>
module roleKustoCluster 'br:contosoregistry.azurecr.io/authorization/roleassignmentskustocluster:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 47), 'roleskusto')
  params: {
    principalType: 'ServicePrincipal'
    principalId: 'a348f815-0d14-4a85-b2fe-d3b36519e4fd' //object id of the service principal
    roleDefinitionIdOrName: '4d97b98b-1d4f-4787-a291-c67834d212e7' // can also be built-in name or full role definition resource ID
    kustoClusterName: myKustoCluster.outputs.clusterName
  }
}
</pre>
<p>Assign a role on the Kusto cluster scope to an identity.</p>
.LINKS
- [Bicep Microsoft.Authorization/roleAssignments](https://learn.microsoft.com/en-us/azure/templates/microsoft.authorization/roleassignments?pivots=deployment-language-bicep)
- [Bicep Microsoft.Kusto/clusters](https://learn.microsoft.com/en-us/azure/templates/microsoft.kusto/clusters?pivots=deployment-language-bicep)
*/

// ================================================= Parameters =================================================
@description('Legacy role definition ID input for backward compatibility. Provide a role definition GUID. If roleDefinitionIdOrName is also provided, roleDefinitionIdOrName takes precedence.')
@minLength(36)
@maxLength(36)
param roleDefinitionId string?

@description('The roledefinition to assign. Supports built-in role name, role definition GUID, or full role definition resource ID.')
param roleDefinitionIdOrName string = roleDefinitionId ?? ''

@description('The AAD Object ID of the principal you want to assign the role to.')
@minLength(36)
@maxLength(36)
param principalId string

@description('The type of principal you want to assign the role to.')
param principalType PrincipalType

@description('The name of the Kusto cluster to assign the permissions on. This Kusto cluster should already exist.')
@minLength(4)
@maxLength(22)
param kustoClusterName string

var builtInRoleNames = {
  Contributor: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
  Owner: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '8e3af657-a8ff-443c-a75c-2fe8c4bcb635')
  Reader: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'acdd72a7-3385-48ef-bd42-f606fba81ae7')
}

var effectiveRoleDefinitionInput = !empty(roleDefinitionIdOrName)
  ? roleDefinitionIdOrName
  : (roleDefinitionId ?? '')

var validatedRoleDefinitionInput = empty(effectiveRoleDefinitionInput)
  ? fail('Either roleDefinitionId or roleDefinitionIdOrName must be provided.')
  : effectiveRoleDefinitionInput

var resolvedRoleDefinitionId = builtInRoleNames[?validatedRoleDefinitionInput] ?? (contains(validatedRoleDefinitionInput, '/providers/Microsoft.Authorization/roleDefinitions/') ? validatedRoleDefinitionInput : subscriptionResourceId('Microsoft.Authorization/roleDefinitions', validatedRoleDefinitionInput))

@description('Fetch the existing Kusto cluster for the role assignment scope in the next step.')
resource kustoCluster 'Microsoft.Kusto/clusters@2024-04-13' existing = {
  name: kustoClusterName
}

@description('Upsert the role with the given parameters.')
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(kustoCluster.id, principalId, resolvedRoleDefinitionId)
  scope: kustoCluster
  properties: {
    principalId: principalId
    roleDefinitionId: resolvedRoleDefinitionId
    principalType: principalType
  }
}
