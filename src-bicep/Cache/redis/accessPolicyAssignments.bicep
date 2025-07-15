/*
.SYNOPSIS
Configuring access policy assignment for Azure Cache for Redis
.DESCRIPTION
This module is used to create access policy assignments for existing Azure Cache for Redis instances.
.EXAMPLE
<pre>
module roleKeyVault 'br:contosoregistry.azurecr.io/cache/redisaccesspolicyassignments:latest' = {
  name: guid(redisCacheName, principalId, accessPolicyName)
  properties: {
    redisCacheName: redisCacheName
    accessPolicyName: accessPolicyName
    principalId: principalId
    principalIdAlias: principalIdAlias
  }
}
</pre>
.LINKS
- [Bicep Microsoft.Cache redis/accessPolicyAssignments](https://learn.microsoft.com/en-us/azure/templates/microsoft.cache/redis/accesspolicyassignments?pivots=deployment-language-bicep)
*/

// ================================================= Parameters =================================================
@description('The name of the Azure Cache for Redis Instance.')
@minLength(2)
@maxLength(60)
param redisCacheName string

@description('The name of the access policy that is being assigned. Built-in are: Data Reader, Data Contributor or Data Owner')
param accessPolicyName string

@description('Object Id to assign access policy to.')
@minLength(36)
@maxLength(36)
param principalId string

@description('User friendly name for object id. Also represents username for token based authentication.')
param principalIdAlias string

@description('Fetch the existing key vault for the role assignment scope in the next step.')
resource redisCache 'Microsoft.Cache/redis@2024-11-01' existing = {
  scope: resourceGroup()
  name: redisCacheName
}

@description('Upsert the policy assignment with the given parameters')
resource policyAssignment 'Microsoft.Cache/Redis/accessPolicyAssignments@2024-11-01' = {
  name: guid(redisCache.id, principalId, accessPolicyName)
  parent: redisCache
  properties: {
    accessPolicyName: accessPolicyName
    objectId: principalId
    objectIdAlias: principalIdAlias
  }
}
