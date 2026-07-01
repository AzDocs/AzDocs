# roleAssignmentsAppConfiguration

Target Scope: resourceGroup

## Synopsis
Configuring role assignment for the App Configuration

## Description
This module is used for creating role assignments for existing Azure App Configuration stores.<br>
Supports role input by GUID (legacy roleDefinitionId), role name, or full role definition resource ID (roleDefinitionIdOrName).<br>
<br>
Role definition input behavior:<br>
1) roleDefinitionIdOrName when not empty<br>
2) otherwise roleDefinitionId<br>
3) fail() when both are empty

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| principalId | string | <input type="checkbox" checked> | Length is 36 | <pre></pre> | The AAD Object ID of the pricipal you want to assign the role to. |
| principalType | PrincipalType | <input type="checkbox" checked> | None | <pre></pre> | The type of principal you want to assign the role to. |
| configurationStoreName | string | <input type="checkbox" checked> | Length between 5-50 | <pre></pre> | The name of the App Configuration store to assign the permissions on. This App Configuration store should already exist. |
| roleDefinitionId | string? | <input type="checkbox" checked> | Length is 36 | <pre></pre> | Legacy role definition ID input for backward compatibility. Provide a role definition GUID. If roleDefinitionIdOrName is also provided, roleDefinitionIdOrName takes precedence. |
| roleDefinitionIdOrName | string | <input type="checkbox"> | None | <pre>roleDefinitionId ?? ''</pre> | The roledefinition to assign. Supports built-in role name, role definition GUID, or full role definition resource ID. |

## Examples
<pre>
module roleAppConfiguration 'br:contosoregistry.azurecr.io/authorization/roleAssignmentsAppConfiguration:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 45), 'rolesappconfig')
  params: {
    principalType: 'User'
    principalId: 'a348f815-0d14-4a85-b2fe-d3b36519e4fd' // object id of the user
    roleDefinitionIdOrName: 'App Configuration Data Reader' // can also be GUID or full role definition resource ID
    configurationStoreName: appConfiguration.outputs.configurationStoreName
  }
}
</pre>

## Links
- [Bicep Microsoft.authorization roleassignments](https://learn.microsoft.com/en-us/azure/templates/microsoft.authorization/roleassignments?pivots=deployment-language-bicep)
