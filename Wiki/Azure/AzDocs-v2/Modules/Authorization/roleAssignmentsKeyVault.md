# roleAssignmentsKeyVault

Target Scope: resourceGroup

## Synopsis
Configuring role assignment for the Key Vault

## Description
This module is used for creating role assignments for existing Azure Key Vault.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| roleDefinitionId | string | <input type="checkbox" checked> | Length is 36 | <pre></pre> | The roledefinition ID you want to assign. |
| principalId | string | <input type="checkbox" checked> | Length is 36 | <pre></pre> | The AAD Object ID of the pricipal you want to assign the role to. |
| principalType | string | <input type="checkbox" checked> | `'Device'` or `'ForeignGroup'` or `'Group'` or `'ServicePrincipal'` or `'User'` | <pre></pre> | The type of principal you want to assign the role to. |
| keyVaultName | string | <input type="checkbox" checked> | Length between 3-24 | <pre></pre> | The name of the Storage Account to assign the permissions on. This Storage Account should already exist. |

## Examples
<pre>
module roleKeyVault 'br:contosoregistry.azurecr.io/authorization/roleassignments:latest' = {
  name: guid(keyVault.id, principalId, roleDefinitionId)
  scope: keyVault
  properties: {
    principalId: principalId
    roleDefinitionId: roleDefinition.id
    principalType: principalType
  }
}
</pre>

## Links
- [Bicep Microsoft.authorization roleassignments](https://learn.microsoft.com/en-us/azure/templates/microsoft.authorization/roleassignments?pivots=deployment-language-bicep)<br>
- [Bicep community example](https://github.com/your-azure-coach/ftw-ventures/blob/main/infra/modules/role-assignment-key-vault.bicep)
