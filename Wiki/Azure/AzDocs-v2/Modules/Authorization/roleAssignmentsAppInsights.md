# roleAssignmentsAppInsights

Target Scope: resourceGroup

## Synopsis
Configuring role assignment for AppInsights.

## Description
This module is used for creating role assignments for existing Application Insights.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| roleDefinitionId | string | <input type="checkbox" checked> | Length is 36 | <pre></pre> | The roledefinition ID you want to assign. |
| principalId | string | <input type="checkbox" checked> | Length is 36 | <pre></pre> | The AAD Object ID of the pricipal you want to assign the role to. |
| principalType | string | <input type="checkbox" checked> | `'Device'` or `'ForeignGroup'` or `'Group'` or `'ServicePrincipal'` or `'User'` | <pre></pre> | The type of principal you want to assign the role to. |
| appInsightsName | string | <input type="checkbox" checked> | Length between 1-50 | <pre></pre> | The name of the Application Insights instance. |

## Examples
<pre>
module roleApiManagment 'br:contosoregistry.azurecr.io/authorization/roleassignments:latest' = {
  name: guid(appInsights.id, principalId, roleDefinitionId)
  scope: appInsights
  properties: {
    principalId: principalId
    roleDefinitionId: roleDefinition.id
    principalType: principalType
  }
}
</pre>

## Links
- [Bicep Microsoft.authorization roleassignments](https://learn.microsoft.com/en-us/azure/templates/microsoft.authorization/roleassignments?pivots=deployment-language-bicep)
