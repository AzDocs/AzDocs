# roleAssignmentsServiceBusTopic

Target Scope: resourceGroup

## User Defined Types
| Name | Type | Discriminator | Description
| -- |  -- | -- | -- |
| <a id="principalTypes">principalTypes</a>  | <pre>'User'</pre> |  | The type of principal you want to assign the role to. | 

## Synopsis
Assign a role on the servicebus topic scope to a identity

## Description
Assign a role on the servicebus topic scope to a identity with the given specs.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| principalId | string | <input type="checkbox" checked> | Length is 36 | <pre></pre> | The AAD Object ID of the pricipal you want to assign the role to. |
| principalType | [principalTypes](#principalTypes) | <input type="checkbox"> | None | <pre>'ServicePrincipal'</pre> | The type of principal you want to assign the role to. |
| serviceBusNamespaceName | string | <input type="checkbox" checked> | Length between 6-50 | <pre></pre> | The name of the Service bus namespace to assign the permissions on. This Service bus namespace should already exist. |
| topicName | string | <input type="checkbox" checked> | Length between 1-260 | <pre></pre> | The name of the topic to assign the permissions on. This topic should already exist. |
| roleDefinitionId | string | <input type="checkbox" checked> | Length is 36 | <pre></pre> | The roledefinition ID you want to assign. |

## Examples
<pre>
module roleAssignmentsServiceBusTopic 'resource.roleAssignmentsServiceBusTopic.bicep' = {
  name: '${take(deployment().name, 41)}-roleAssignmentsTopic'
  params: {
    principalId: principalId
    roleDefinitionId: roleDefinitionId
    serviceBusNamespaceName: serviceBusNamespaceName
    topicName: topicName
    principalType: principalType
  }
}
</pre>
<p>Assign a role on the servicebus topic scope to a identity</p>

## Links
- [Bicep Microsoft.Authorization/roleAssignments](https://learn.microsoft.com/en-us/azure/templates/microsoft.authorization/roleassignments?pivots=deployment-language-bicep)
