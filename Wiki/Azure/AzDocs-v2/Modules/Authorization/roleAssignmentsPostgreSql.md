# roleAssignmentsPostgreSql

Target Scope: resourceGroup

## Synopsis
Configuring role assignment for Azure Database for PostgreSQL.

## Description
This module is used for creating role assignments for existing Azure Databases for PostgreSQL.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| roleDefinitionId | string | <input type="checkbox" checked> | Length is 36 | <pre></pre> | The roledefinition ID you want to assign. |
| principalId | string | <input type="checkbox" checked> | Length is 36 | <pre></pre> | The AAD Object ID of the pricipal you want to assign the role to. |
| principalType | PrincipalType | <input type="checkbox" checked> | None | <pre></pre> | The type of principal you want to assign the role to. |
| postgresServerName | string | <input type="checkbox" checked> | Length between 3-63 | <pre></pre> | Character limit: 3-63<br><br>Valid characters:<br>Alphanumerics and hyphens.<br><br>Start with letter and end with alphanumeric.<br><br>Resource name must be unique across Azure. |

## Examples
<pre>
module rolePostgreSql 'br:contosoregistry.azurecr.io/authorization/roleassignments:latest' = {
  name: guid(postgresServerName, principalId, roleDefinitionId)
  properties: {
    principalId: principalId
    roleDefinitionId: roleDefinition.id
    principalType: principalType
  }
}
</pre>

## Links
- [Bicep Microsoft.authorization roleassignments](https://learn.microsoft.com/en-us/azure/templates/microsoft.authorization/roleassignments?pivots=deployment-language-bicep)
