# products

Target Scope: resourceGroup

## Synopsis
Creating a product resource in an existing Api Management Service.

## Description
Creating a product resource in an existing Api Management Service.<br>
<pre><br>
module products 'br:contosoregistry.azurecr.io/service/products.bicep' = {<br>
  name: format('{0}-{1}', take('${deployment().name}', 46), 'products')<br>
  params: {<br>
    apiManagementServiceName: apiManagementServiceName<br>
    approvalRequired: approvalRequired<br>
    productDescription: productDescription<br>
    productDisplayName: productDisplayName<br>
    name: productName<br>
    state: state<br>
    subscriptionRequired: subscriptionRequired<br>
    subscriptionLimit: subscriptionLimit<br>
    terms: terms<br>
  }<br>
}<br>
</pre><br>
<p>Creates a product resource with the specified parameters.</p>

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| apiManagementServiceName | string | <input type="checkbox" checked> | Length between 1-50 | <pre></pre> | The name of the existing API Management service instance. |
| approvalRequired | bool | <input type="checkbox" checked> | None | <pre></pre> | Whether subscription approval is required or not. |
| productDescription | string | <input type="checkbox" checked> | None | <pre></pre> | Product description. May include HTML formatting tags. |
| productDisplayName | string | <input type="checkbox" checked> | None | <pre></pre> | Product display name. |
| name | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | The resource name |
| state | string | <input type="checkbox"> | `'notPublished'` or `'published'` | <pre>'notPublished'</pre> | whether product is published or not. Published products are discoverable by users of developer portal. Non published products are visible only to administrators. Default state of Product is notPublished. |
| subscriptionRequired | bool | <input type="checkbox" checked> | None | <pre></pre> | Whether subscription is required or not. |
| subscriptionLimit | int | <input type="checkbox" checked> | None | <pre></pre> | Whether the number of subscriptions a user can have to this product at the same time. Set to null or omit to allow unlimited per user subscriptions. Can be present only if subscriptionRequired property is present and has a value of false. |
| terms | string | <input type="checkbox" checked> | None | <pre></pre> | Product terms of use. Developers trying to subscribe to the product will be presented and required to accept these terms before they can complete the subscription process. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| productName | string | The name of the product. |
| productId | string | The id of the product. |

## Links
- [Bicep Microsoft.ApiManagement products](https://learn.microsoft.com/en-us/azure/templates/microsoft.apimanagement/service/products?pivots=deployment-language-bicep)
