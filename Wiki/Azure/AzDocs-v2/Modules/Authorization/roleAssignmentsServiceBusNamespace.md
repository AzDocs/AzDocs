# roleAssignmentsServiceBusNamespace

Target Scope: resourceGroup

## Synopsis
Assign a role on the servicebus namespace scope to a identity

## Description
Assign a role on the servicebus namespace scope to a identity with the given specs.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| principalId | string | <input type="checkbox" checked> | Length is 36 | <pre></pre> | The AAD Object ID of the pricipal you want to assign the role to. |
| principalType | string | <input type="checkbox"> | `'User'` or  `'Group'` or  `'ServicePrincipal'` or  `'Unknown'` or  `'DirectoryRoleTemplate'` or  `'ForeignGroup'` or  `'Application'` or  `'MSI'` or  `'DirectoryObjectOrGroup'` or  `'Everyone'` | <pre>'ServicePrincipal'</pre> | The type of principal you want to assign the role to. |
| serviceBusNamespaceName | string | <input type="checkbox" checked> | Length between 3-24 | <pre></pre> | The name of the Storage Account to assign the permissions on. This Storage Account should already exist. |
| roleDefinitionId | string | <input type="checkbox" checked> | Length is 36 | <pre></pre> | The roledefinition ID you want to assign. |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |
## Examples
<pre>
resource roleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: resourceGroup()
  name: roleDefinitionId
}

module roleAssignment 'br:contosoregistry.azurecr.io/authorization/roleAssignmentsServiceBusNamespace:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 50), 'roleassign')
  scope: az.resourceGroup(serviceBusNamespaceSubscriptionId, serviceBusNamespaceResourceGroupName)
  params: {
    principalId: systemTopic.outputs.identityPrincipalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: roleDefinition.id
    serviceBusNamespaceName: serviceBusNamespace.name
  }
}
</pre>
<p>Assign a role on the servicebus namespace scope to a identity</p>

## Links
- [Bicep Microsoft.Authorization/roleAssignments](https://learn.microsoft.com/en-us/azure/templates/microsoft.authorization/roleassignments?pivots=deployment-language-bicep)


