# roleAssignmentsAppConfiguration

Target Scope: resourceGroup

## Synopsis
Configuring role assignment for the App Configuration

## Description
This module is used for creating role assignments for existing Azure App Configuration stores.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| principalId | string | <input type="checkbox" checked> | Length is 36 | <pre></pre> | The AAD Object ID of the pricipal you want to assign the role to. |
| principalType | string | <input type="checkbox"> | `'User'` or `'Group'` or `'ServicePrincipal'` or `'Unknown'` or `'DirectoryRoleTemplate'` or `'ForeignGroup'` or `'Application'` or `'MSI'` or `'DirectoryObjectOrGroup'` or `'Everyone'` | <pre>'ServicePrincipal'</pre> | The type of principal you want to assign the role to. |
| configurationStoreName | string | <input type="checkbox" checked> | Length between 5-50 | <pre></pre> | The name of the App Configuration store to assign the permissions on. This App Configuration store should already exist. |
| roleDefinitionId | string | <input type="checkbox" checked> | Length is 36 | <pre></pre> | The role definition ID you want to assign. |

## Examples
<pre>
module roleAppConfiguration 'br:contosoregistry.azurecr.io/authorization/roleAssignmentsAppConfiguration:latest' = {
  name: guid(configurationStore.id, principalId, roleDefinitionId)
  scope: configurationStore
  properties: {
    principalId: principalId
    roleDefinitionId: roleDefinition.id
    principalType: principalType
  }
}
</pre>

## Links
- [Bicep Microsoft.authorization roleassignments](https://learn.microsoft.com/en-us/azure/templates/microsoft.authorization/roleassignments?pivots=deployment-language-bicep)
