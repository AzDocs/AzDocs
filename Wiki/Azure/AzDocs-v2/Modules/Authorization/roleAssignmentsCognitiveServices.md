# roleAssignmentsCognitiveServices

Target Scope: resourceGroup

## Synopsis
Configuring role assignment for Cognitive Services

## Description
This module is used for creating role assignments for existing Azure Cognitive Services accounts.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| roleDefinitionId | string | <input type="checkbox" checked> | Length is 36 | <pre></pre> | The roledefinition ID you want to assign. |
| principalId | string | <input type="checkbox" checked> | Length is 36 | <pre></pre> | The AAD Object ID of the pricipal you want to assign the role to. |
| principalType | string | <input type="checkbox"> | `'User'` or `'Group'` or `'ServicePrincipal'` or `'Unknown'` or `'DirectoryRoleTemplate'` or `'ForeignGroup'` or `'Application'` or `'MSI'` or `'DirectoryObjectOrGroup'` or `'Everyone'` | <pre>'ServicePrincipal'</pre> | The type of principal you want to assign the role to. |
| cognitiveServicesAccountName | string | <input type="checkbox" checked> | Length between 2-64 | <pre></pre> | The name of the Cognitive Services account to assign the permissions on. This Cognitive Services account should already exist. |

## Examples
<pre>
module roleCognitiveServices 'br:contosoregistry.azurecr.io/authorization/roleassignmentscognitiveservices:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 45), 'rolecognitiveservices')
  params: {
    principalType: 'ServicePrincipal'
    principalId: 'a348f815-0d14-4a85-b2fe-d3b36519e4fd' //object id of the service principal
    roleDefinitionId: '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd' //Cognitive Services OpenAI User
    cognitiveServicesAccountName: cognitiveServicesAccount.outputs.accountName
  }
}
</pre>
<p>Assign a role on the Cognitive Services account scope to an identity</p>

## Links
- [Bicep Microsoft.Authorization/roleAssignments](https://learn.microsoft.com/en-us/azure/templates/microsoft.authorization/roleassignments?pivots=deployment-language-bicep)<br>
- [Azure Cognitive Services built-in roles](https://learn.microsoft.com/en-us/azure/ai-services/authentication#assign-a-role-to-a-user)
