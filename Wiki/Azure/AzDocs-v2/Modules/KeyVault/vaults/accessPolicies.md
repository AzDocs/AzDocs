# accessPolicies

Target Scope: resourceGroup

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| keyVaultName | string | <input type="checkbox" checked> | Length between 3-24 | <pre></pre> | The name of the KeyVault to upsert<br>Keyvault name restrictions:<br>- Keyvault names must be between 3 and 24 alphanumeric characters in length. The name must begin with a letter, end with a letter or digit, and not contain consecutive hyphens<br>- Your keyVaultName must be unique within Azure. |
| principalId | string | <input type="checkbox" checked> | Length is 36 | <pre></pre> | The AAD Object ID of the pricipal you want to assign the role to. |
| keyVaultPermissions | object | <input type="checkbox" checked> | None | <pre></pre> | Assigned permissions for Principal ID. Please refer to this documentation for the object structure: https://docs.microsoft.com/en-us/azure/templates/microsoft.keyvault/vaults/accesspolicies?tabs=bicep#permissions |
| policyAction | string | <input type="checkbox"> | `'add'` or `'remove'` or `'replace'` | <pre>'add'</pre> | The action we choose for keyvault accessPolicies. |
