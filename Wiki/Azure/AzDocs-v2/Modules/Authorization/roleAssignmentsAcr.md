# roleAssignmentsAcr

Target Scope: resourceGroup

## Synopsis
Configuring role assignment for the Acr

## Description
This module is used for creating role assignments for existing Acr.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| roleName | string | <input type="checkbox" checked> | `'AcrDelete'` or `'AcrImageSigner'` or `'AcrPull'` or `'AcrPush'` or `'AcrQuarantineReader'` or `'AcrQuarantineWriter'` | <pre></pre> | The roledefinition name you want to assign. |
| containerRegistryName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the existing azure container registry. |
| principalId | string | <input type="checkbox" checked> | Length is 36 | <pre></pre> | The AAD Object ID of the principal you want to assign the role to. |
| principalType | string | <input type="checkbox" checked> | `'Device'` or `'ForeignGroup'` or `'Group'` or `'ServicePrincipal'` or `'User'` | <pre></pre> |  |

## Examples
<pre>
module roleAcr 'br:contosoregistry.azurecr.io/authorization/roleassignments:latest' = {
  name: guid(acr.id, principalId, roleDefinitionId)
  scope: acr
  properties: {
    principalId: principalId
    roleDefinitionId: roleDefinition.id
    principalType: principalType
  }
}
</pre>

## Links
- [Bicep Microsoft.authorization roleassignments](https://learn.microsoft.com/en-us/azure/templates/microsoft.authorization/roleassignments?pivots=deployment-language-bicep)<br>
- [Bicep community example](https://github.com/your-azure-coach/ftw-ventures/blob/main/infra/modules/role-assignment-container-registry.bicep)
