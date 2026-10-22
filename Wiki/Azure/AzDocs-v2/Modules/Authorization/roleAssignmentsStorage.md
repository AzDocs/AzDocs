# roleAssignmentsStorage

Target Scope: resourceGroup

## Synopsis
Assign a role on the storage account scope to an identity

## Description
Assign a role on the storage account scope to a identity with the given specs.<br>
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
| storageAccountName | string | <input type="checkbox" checked> | Length between 3-24 | <pre></pre> | The name of the Storage Account to assign the permissions on. This Storage Account should already exist. |
| roleDefinitionId | string? | <input type="checkbox" checked> | Length is 36 | <pre></pre> | Legacy role definition ID input for backward compatibility. Provide a role definition GUID. If roleDefinitionIdOrName is also provided, roleDefinitionIdOrName takes precedence. |
| roleDefinitionIdOrName | string | <input type="checkbox"> | None | <pre>roleDefinitionId ?? ''</pre> | The roledefinition to assign. Supports built-in role name, role definition GUID, or full role definition resource ID. |
| condition | string? | <input type="checkbox" checked> | None | <pre></pre> | Optional. The conditions on the role assignment. This limits the resources it can be assigned to. e.g.: @Resource[Microsoft.Storage/storageAccounts/blobServices/containers:ContainerName] StringEqualsIgnoreCase "foo_storage_container" |
| conditionVersion | string? | <input type="checkbox" checked> | `'2.0'` | <pre></pre> | Optional. Version of the condition. Currently the only accepted value is 2.0. |

## Examples
<pre>
module roleAssignmentsStorage 'br:contosoregistry.azurecr.io/authorization/roleassignmentsstorage:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 51), 'rolesstorage')
  params: {
    principalType: 'User'
    principalId: 'a348f815-0d14-4a85-b2fe-d3b36519e4fd' //object id of the user
    roleDefinitionIdOrName: 'Storage Blob Data Contributor' // can also be GUID or full role definition resource ID
    storageAccountName: workspaceStorage.outputs.storageAccountName
  }
}
</pre>
<p>Assign a role on the storage account scope to an identity</p>

## Links
- [Bicep Microsoft.Authorization/roleAssignments](https://learn.microsoft.com/en-us/azure/templates/microsoft.authorization/roleassignments?pivots=deployment-language-bicep)
