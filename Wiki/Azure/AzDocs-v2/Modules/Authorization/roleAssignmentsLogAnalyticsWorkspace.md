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
module rolelogAnalyticsWorkspace 'br:contosoregistry.azurecr.io/authorization/roleassignmentsloganalyticsworkspace:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 56), 'lawauth')
  params: {
    logAnalyticsWorkspaceName: logAnalyticsWorkspace.outputs.logAnalyticsWorkspaceResourceName
    principalId: '47c4d212-8012-4821-ae34-ff16bf356ee2'
    roleDefinitionId: 'acc9fe40-3a05-45cc-b23c-72f68cc7476f'
    principalType: 'Group'
  }
}
</pre>

## Links
- [Bicep Microsoft.authorization roleassignments](https://learn.microsoft.com/en-us/azure/templates/microsoft.authorization/roleassignments?pivots=deployment-language-bicep)
