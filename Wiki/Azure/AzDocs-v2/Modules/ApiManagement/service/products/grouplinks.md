# grouplinks

Target Scope: resourceGroup

## Synopsis
Add a grouplink to a product in Api Management Service.

## Description
Add a grouplink to a product Access Control List (ACL) in Api Management Service.
<pre>
module diagnostics 'br:contosoregistry.azurecr.io/service/groups.bicep' = {
  name: format('{0}-{1}', take('${deployment().name}', 58), 'groups')
  params: {
    apiManagementServiceName: apiManagementServiceName
    groupId: groupId
    groupLinkName: groupLinkName
    productName: productName
  }
}
</pre><br>
<p>Add a grouplink to a product Access Control List (ACL) in Api Management Service.</p>

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| apiManagementServiceName | string | <input type="checkbox" checked> | Length between 1-50 | <pre></pre> | The name of the API Management service. |
| groupId | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | The ID of the group. |
| groupLinkName | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | The name of the group link. |
| productName | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | The name of the product. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| groupIdOutput | string | The resource ID of the group link. |
| groupLinkNameOutput | string | The name of the group link. |
| productNameOutput | string | The name of the product. |

## Links
- [Bicep Microsoft.ApiManagement diagnostics](https://learn.microsoft.com/en-us/azure/templates/microsoft.apimanagement/service/products/grouplinks?pivots=deployment-language-bicep)
