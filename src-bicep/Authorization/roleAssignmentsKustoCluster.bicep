import { PrincipalType } from '../Common/authorizationTypes.bicep'
/*
.SYNOPSIS
Configuring role assignment for a Kusto cluster.
.DESCRIPTION
This module is used for creating role assignments for an existing Azure Data Explorer (Kusto) cluster.
.EXAMPLE
<pre>
module roleKustoCluster 'br:contosoregistry.azurecr.io/authorization/roleassignmentskustocluster:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 47), 'roleskusto')
  params: {
    principalType: 'ServicePrincipal'
    principalId: 'a348f815-0d14-4a85-b2fe-d3b36519e4fd' //object id of the service principal
    roleDefinitionId: '4d97b98b-1d4f-4787-a291-c67834d212e7' //Azure Data Explorer Contributor
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
@description('The roledefinition ID you want to assign.')
@minLength(36)
@maxLength(36)
param roleDefinitionId string

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

@description('Fetch the role based on the given roleDefinitionId. See https://docs.microsoft.com/azure/role-based-access-control/built-in-roles')
resource roleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: resourceGroup()
  name: roleDefinitionId
}

@description('Fetch the existing Kusto cluster for the role assignment scope in the next step.')
resource kustoCluster 'Microsoft.Kusto/clusters@2024-04-13' existing = {
  name: kustoClusterName
}

@description('Upsert the role with the given parameters.')
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(kustoCluster.id, principalId, roleDefinitionId)
  scope: kustoCluster
  properties: {
    principalId: principalId
    roleDefinitionId: roleDefinition.id
    principalType: principalType
  }
}
