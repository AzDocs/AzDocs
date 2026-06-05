# roleAssignmentsServiceBusQueue

Target Scope: resourceGroup

## User Defined Types
| Name | Type | Discriminator | Description
| -- |  -- | -- | -- |
| <a id="principalTypes">principalTypes</a>  | <pre></pre> |  | The type of principal you want to assign the role to. | 

## Synopsis
Assign a role on the servicebus queue scope to a identity

## Description
Assign a role on the servicebus queue scope to a identity with the given specs.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| principalId | string | <input type="checkbox" checked> | Length is 36 | <pre></pre> | The AAD Object ID of the pricipal you want to assign the role to. |
| principalType | PrincipalType | <input type="checkbox" checked> | None | <pre></pre> | The type of principal you want to assign the role to. |
| serviceBusNamespaceName | string | <input type="checkbox" checked> | Length between 6-50 | <pre></pre> | The name of the Service bus namespace to assign the permissions on. This Service bus namespace should already exist. |
| queueName | string | <input type="checkbox" checked> | Length between 1-260 | <pre></pre> | The name of the queue to assign the permissions on. This queue should already exist. |
| roleDefinitionId | string | <input type="checkbox" checked> | Length is 36 | <pre></pre> | The roledefinition ID you want to assign. |

## Examples
<pre>
module roleAssignmentsServiceBusQueue 'resource.roleAssignmentsServiceBusQueue.bicep' = {
  name: '${take(deployment().name, 41)}-roleAssignmentsQueue'
  params: {
    principalId: principalId
    roleDefinitionId: roleDefinitionId
    serviceBusNamespaceName: serviceBusNamespaceName
    queueName: queueName
    principalType: principalType
  }
}
</pre>
<p>Assign a role on the servicebus queue scope to a identity</p>

## Links
- [Bicep Microsoft.Authorization/roleAssignments](https://learn.microsoft.com/en-us/azure/templates/microsoft.authorization/roleassignments?pivots=deployment-language-bicep)
