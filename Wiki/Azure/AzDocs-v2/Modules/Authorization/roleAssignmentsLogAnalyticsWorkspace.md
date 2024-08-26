# roleAssignmentsLogAnalyticsWorkspace

Target Scope: resourceGroup

## Synopsis
Configuring role assignment for the Log Analytics Workspace

## Description
This module is used for creating role assignments for existing Azure Log Analytics Workspace.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| roleDefinitionId | string | <input type="checkbox" checked> | Length is 36 | <pre></pre> | The roledefinition ID you want to assign. |
| principalId | string | <input type="checkbox" checked> | Length is 36 | <pre></pre> | The AAD Object ID of the pricipal you want to assign the role to. |
| principalType | string | <input type="checkbox" checked> | `'Device'` or `'ForeignGroup'` or `'Group'` or `'ServicePrincipal'` or `'User'` | <pre></pre> | The type of principal you want to assign the role to. |
| logAnalyticsWorkspaceName | string | <input type="checkbox" checked> | Length between 4-63 | <pre></pre> | The name of the Log Analytics Workspace to assign the permissions on. This Log Analytics Workspace should already exist. |

## Examples
<pre>
module rolelogAnalyticsWorkspace 'br:contosoregistry.azurecr.io/authorization/roleassignments:latest' = {
  name: guid(logAnalyticsWorkspace.id, principalId, roleDefinitionId)
  scope: logAnalyticsWorkspace
  properties: {
    principalId: principalId
    roleDefinitionId: roleDefinition.id
    principalType: principalType
  }
}
</pre>

## Links
- [Bicep Microsoft.authorization roleassignments](https://learn.microsoft.com/en-us/azure/templates/microsoft.authorization/roleassignments?pivots=deployment-language-bicep)
