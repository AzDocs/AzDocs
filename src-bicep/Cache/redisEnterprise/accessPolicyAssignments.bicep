/*
.SYNOPSIS
Configuring a data-plane access policy assignment for Azure Managed Redis
.DESCRIPTION
This module is used to create access policy assignments on the database of an existing Azure Managed Redis
(Redis Enterprise) cluster. Azure Managed Redis has a single built-in access policy, named `default`, which
grants full access to all keys and all commands; it has no reader or contributor equivalent. Entra group
membership is not resolved, so assign individual principals rather than a group.
.EXAMPLE
<pre>
module redisEnterpriseAccess 'br:contosoregistry.azurecr.io/cache/redisenterprise/accesspolicyassignments:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 46), 'redisaccess')
  params: {
    redisEnterpriseName: redisEnterpriseName
    accessPolicyAssignmentName: 'myapp-dev'
    principalId: principalId
  }
}
</pre>
<p>Grants the given principal full data-plane access to the default database of the given cluster</p>
.LINKS
- [Bicep Microsoft.Cache redisEnterprise/databases/accessPolicyAssignments](https://learn.microsoft.com/en-us/azure/templates/microsoft.cache/redisenterprise/databases/accesspolicyassignments?pivots=deployment-language-bicep)
- [Use Microsoft Entra for cache authentication with Azure Managed Redis](https://learn.microsoft.com/en-us/azure/redis/entra-for-authentication)
*/

// ================================================= Parameters =================================================
@description('The name of the existing Azure Managed Redis cluster to assign access on.')
@minLength(1)
@maxLength(60)
param redisEnterpriseName string

@description('The name of the database on the cluster. Azure Managed Redis supports exactly one database and it must be named `default`.')
@minLength(1)
@maxLength(60)
param redisEnterpriseDatabaseName string = 'default'

@description('The name of the assignment resource. Letters, numbers and dashes only; it cannot start or end with a dash. Defaults to the principalId.')
@minLength(1)
@maxLength(60)
param accessPolicyAssignmentName string = principalId

@description('Object Id of the user or service principal to grant data-plane access to. Entra groups are not resolved by Azure Managed Redis, so assign individual principals.')
@minLength(36)
@maxLength(36)
param principalId string

// ================================================= Resources =================================================
@description('Fetch the existing cluster and its database for the assignment scope in the next step.')
resource redisEnterprise 'Microsoft.Cache/redisEnterprise@2025-07-01' existing = {
  name: redisEnterpriseName

  resource database 'databases' existing = {
    name: redisEnterpriseDatabaseName
  }
}

@description('Upsert the access policy assignment with the given parameters.')
resource accessPolicyAssignment 'Microsoft.Cache/redisEnterprise/databases/accessPolicyAssignments@2025-07-01' = {
  parent: redisEnterprise::database
  name: accessPolicyAssignmentName
  properties: {
    accessPolicyName: 'default'
    user: {
      objectId: principalId
    }
  }
}

// ================================================= Outputs =================================================
@description('Output the resource name of this access policy assignment.')
output accessPolicyAssignmentName string = accessPolicyAssignment.name

@description('Output the resource id of this access policy assignment.')
output accessPolicyAssignmentResourceId string = accessPolicyAssignment.id
