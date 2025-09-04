# roleAssignmentsSearch

Target Scope: resourceGroup

## Synopsis
Configuring role assignment for Azure Search Service

## Description
This module is used for creating role assignments for existing Azure Search Service (Cognitive Search).

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| roleDefinitionId | string | <input type="checkbox" checked> | Length is 36 | <pre></pre> | The roledefinition ID you want to assign. |
| principalId | string | <input type="checkbox" checked> | Length is 36 | <pre></pre> | The AAD Object ID of the pricipal you want to assign the role to. |
| principalType | PrincipalType | <input type="checkbox" checked> | None | <pre></pre> | The type of principal you want to assign the role to. |
| searchServiceName | string | <input type="checkbox" checked> | Length between 2-60 | <pre></pre> | The name of the Azure Search Service to assign the permissions on. This Search Service should already exist. |

## Examples
<pre>
module roleSearch 'br:contosoregistry.azurecr.io/authorization/roleassignmentssearch:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 55), 'rolesearch')
  params: {
    principalType: 'ServicePrincipal'
    principalId: 'a348f815-0d14-4a85-b2fe-d3b36519e4fd' //object id of the service principal
    roleDefinitionId: '7ca78c08-252a-4471-8644-bb5ff32d4ba0' //Search Service Contributor
    searchServiceName: searchService.outputs.searchServiceName
  }
}
</pre>
<p>Assign a role on the Azure Search Service scope to an identity</p>

## Links
- [Bicep Microsoft.Authorization/roleAssignments](https://learn.microsoft.com/en-us/azure/templates/microsoft.authorization/roleassignments?pivots=deployment-language-bicep)<br>
- [Azure Search Service built-in roles](https://learn.microsoft.com/en-us/azure/search/search-security-rbac)
