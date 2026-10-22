# accessPolicyAssignments

Target Scope: resourceGroup

## Synopsis
Configuring a data-plane access policy assignment for Azure Managed Redis

## Description
This module is used to create access policy assignments on the database of an existing Azure Managed Redis<br>
(Redis Enterprise) cluster. Azure Managed Redis has a single built-in access policy, named `default`, which<br>
grants full access to all keys and all commands; it has no reader or contributor equivalent. Entra group<br>
membership is not resolved, so assign individual principals rather than a group.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| redisEnterpriseName | string | <input type="checkbox" checked> | Length between 1-60 | <pre></pre> | The name of the existing Azure Managed Redis cluster to assign access on. |
| redisEnterpriseDatabaseName | string | <input type="checkbox"> | Length between 1-60 | <pre>'default'</pre> | The name of the database on the cluster. Azure Managed Redis supports exactly one database and it must be named `default`. |
| accessPolicyAssignmentName | string | <input type="checkbox"> | Length between 1-60 | <pre>principalId</pre> | The name of the assignment resource. Letters, numbers and dashes only; it cannot start or end with a dash. Defaults to the principalId. |
| principalId | string | <input type="checkbox" checked> | Length is 36 | <pre></pre> | Object Id of the user or service principal to grant data-plane access to. Entra groups are not resolved by Azure Managed Redis, so assign individual principals. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| accessPolicyAssignmentName | string | Output the resource name of this access policy assignment. |
| accessPolicyAssignmentResourceId | string | Output the resource id of this access policy assignment. |

## Examples
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

## Links
- [Bicep Microsoft.Cache redisEnterprise/databases/accessPolicyAssignments](https://learn.microsoft.com/en-us/azure/templates/microsoft.cache/redisenterprise/databases/accesspolicyassignments?pivots=deployment-language-bicep)<br>
- [Use Microsoft Entra for cache authentication with Azure Managed Redis](https://learn.microsoft.com/en-us/azure/redis/entra-for-authentication)
