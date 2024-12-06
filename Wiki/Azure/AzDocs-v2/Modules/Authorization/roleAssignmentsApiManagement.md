# roleAssignmentsApiManagement

Target Scope: resourceGroup

## Synopsis
Configuring role assignment for API Management Service.

## Description
This module is used for creating role assignments for existing API Management Service.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| roleDefinitionId | string | <input type="checkbox" checked> | Length is 36 | <pre></pre> | The roledefinition ID you want to assign. |
| principalId | string | <input type="checkbox" checked> | Length is 36 | <pre></pre> | The AAD Object ID of the pricipal you want to assign the role to. |
| principalType | string | <input type="checkbox" checked> | `'Device'` or `'ForeignGroup'` or `'Group'` or `'ServicePrincipal'` or `'User'` | <pre></pre> | The type of principal you want to assign the role to. |
| apiManagementServiceName | string | <input type="checkbox" checked> | Length between 1-50 | <pre></pre> | Character limit: 1-50<br><br>Valid characters:<br>Alphanumerics and hyphens.<br><br>Start with letter and end with alphanumeric.<br><br>Resource name must be unique across Azure. |

## Examples
<pre>
module roleApiManagment 'br:contosoregistry.azurecr.io/authorization/roleassignments:latest' = {
  name: guid(apiManagmentService.id, principalId, roleDefinitionId)
  scope: apiManagementService
  properties: {
    principalId: principalId
    roleDefinitionId: roleDefinition.id
    principalType: principalType
  }
}
</pre>

## Links
- [Bicep Microsoft.authorization roleassignments](https://learn.microsoft.com/en-us/azure/templates/microsoft.authorization/roleassignments?pivots=deployment-language-bicep)<br>
- [Bicep community example](https://github.com/your-azure-coach/ftw-ventures/blob/main/infra/modules/role-assignment-api-management.bicep)
