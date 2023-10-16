# roleAssignmentsGallery

Target Scope: resourceGroup

## Synopsis
Configuring role assignment for the Gallery

## Description
This module is used for creating role assignments for an existing gallery.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| principalIds | array | <input type="checkbox" checked> | None | <pre></pre> | Required. The IDs of the principals to assign the role to. |
| roleDefinitionIdOrName | string | <input type="checkbox" checked> | None | <pre></pre> | Required. The name of the role to assign. If it cannot be found you can specify the role definition ID instead. |
| resourceId | string | <input type="checkbox" checked> | None | <pre></pre> | Required. The resource ID of the resource to apply the role assignment to. |
| principalType | string | <input type="checkbox"> | `'ServicePrincipal'` or `'Group'` or `'User'` or `'ForeignGroup'` or `'Device'` or `''` | <pre>''</pre> | Optional. The principal type of the assigned principal ID. |
| roleAssignmentDescription | string | <input type="checkbox"> | None | <pre>''</pre> | Optional. The description of the role assignment. |
| condition | string | <input type="checkbox"> | None | <pre>''</pre> | Optional. The conditions on the role assignment. This limits the resources it can be assigned to. e.g.: @Resource[Microsoft.Storage/storageAccounts/blobServices/containers:ContainerName] StringEqualsIgnoreCase "foo_storage_container". |
| conditionVersion | string | <input type="checkbox"> | `'2.0'` | <pre>'2.0'</pre> | Optional. Version of the condition. |
| delegatedManagedIdentityResourceId | string | <input type="checkbox"> | None | <pre>''</pre> | Optional. Id of the delegated managed identity resource. |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |
## Examples
<pre>
module roleAcr 'br:contosoregistry.azurecr.io/authorization/roleassignmentsGallery:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 49), 'galroleassread')
  params: {
    principalIds: ['1234567ab-8910-4ac5-8f6d-ca229942d80c','aa123b4dd-012a-4ac6-87f9-72b82c699b3e']
    resourceId: gallery.outputs.galleryId
    roleDefinitionIdOrName: 'Reader'
  }
  dependsOn: [ gallery ]
}
</pre>

## Links
- [Bicep Microsoft.authorization roleassignments](https://learn.microsoft.com/en-us/azure/templates/microsoft.authorization/roleassignments?pivots=deployment-language-bicep)


