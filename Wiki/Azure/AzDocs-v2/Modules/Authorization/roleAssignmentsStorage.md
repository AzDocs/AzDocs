# roleAssignmentsStorage

Target Scope: resourceGroup

## Synopsis
Assign a role on the storage account scope to an identity

## Description
Assign a role on the storage account scope to a identity with the given specs.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| principalId | string | <input type="checkbox" checked> | Length is 36 | <pre></pre> | The AAD Object ID of the pricipal you want to assign the role to. |
| principalType | string | <input type="checkbox"> | `'User'` or `'Group'` or `'ServicePrincipal'` or `'Unknown'` or `'DirectoryRoleTemplate'` or `'ForeignGroup'` or `'Application'` or `'MSI'` or `'DirectoryObjectOrGroup'` or `'Everyone'` | <pre>'ServicePrincipal'</pre> | The type of principal you want to assign the role to. |
| storageAccountName | string | <input type="checkbox" checked> | Length between 3-24 | <pre></pre> | The name of the Storage Account to assign the permissions on. This Storage Account should already exist. |
| roleDefinitionId | string | <input type="checkbox" checked> | Length is 36 | <pre></pre> | The roledefinition ID you want to assign. |

## Examples
<pre>
module roleAssignmentsStorage 'br:contosoregistry.azurecr.io/authorization/roleassignmentsstorage:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 51), 'rolesstorage')
  params: {
    principalType: 'User'
    principalId: 'a348f815-0d14-4a85-b2fe-d3b36519e4fd' //object id of the user
    roleDefinitionId: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe' //Storage Blob Data Contributor
    storageAccountName: workspaceStorage.outputs.storageAccountName
  }
}
</pre>
<p>Assign a role on the storage account scope to an identity</p>

## Links
- [Bicep Microsoft.Authorization/roleAssignments](https://learn.microsoft.com/en-us/azure/templates/microsoft.authorization/roleassignments?pivots=deployment-language-bicep)
