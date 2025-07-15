# accessPolicyAssignments

Target Scope: resourceGroup

## Synopsis
Configuring access policy assignment for Azure Cache for Redis

## Description
This module is used to create access policy assignments for existing Azure Cache for Redis instances.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| redisCacheName | string | <input type="checkbox" checked> | Length between 2-60 | <pre></pre> | The name of the Azure Cache for Redis Instance. |
| accessPolicyName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the access policy that is being assigned. Built-in are: Data Reader, Data Contributor or Data Owner |
| principalId | string | <input type="checkbox" checked> | Length is 36 | <pre></pre> | Object Id to assign access policy to. |
| principalIdAlias | string | <input type="checkbox" checked> | None | <pre></pre> | User friendly name for object id. Also represents username for token based authentication. |

## Examples
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

## Links
- [Bicep Microsoft.Cache redis/accessPolicyAssignments](https://learn.microsoft.com/en-us/azure/templates/microsoft.cache/redis/accesspolicyassignments?pivots=deployment-language-bicep)
