# subscriptions

Target Scope: resourceGroup

## Synopsis
Creating an subscription in an existing Api Management Service.

## Description
Creating an subscription in an existing Api Management Service.<br>
<pre><br>
module apis 'br:contosoregistry.azurecr.io/service/subscriptions:latest' = {<br>
  name: format('{0}-{1}', take('${deployment().name}', 37), 'subscriptions')<br>
  params: {<br>
    allowTracing: allowTracing<br>
    apiManagementServiceName: apiManagementServiceName<br>
    displayName: displayName<br>
    subscriptionName: apiName<br>
    scope: scope<br>
  }<br>
}<br>
</pre><br>
<p>Creates an subscription with the name displayName.</p>

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| allowTracing | bool | <input type="checkbox"> | None | <pre>false</pre> | Specifies whether tracing is allowed for the subscription. |
| apiManagementServiceName | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | The name of the API Management service. |
| displayName | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | The display name of the subscription. |
| subscriptionName | string | <input type="checkbox" checked> | Length between 1-80 | <pre></pre> | The resource name of the subscription. |
| state | string | <input type="checkbox" checked> | `'active'` or `'cancelled'` or `'expired'` or `'rejected'` or `'submitted'` or `'suspended'` | <pre></pre> | The state of the subscription. |
| scope | string | <input type="checkbox" checked> | None | <pre></pre> | The scope of entities this subscription is valid for. This can be a product, an API, or a product API.<br><br>Scope like /products/{productId} or /apis/{apiId}<br><br>When provided '/apis' is used as default scope (all APIs and Products) |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| subscriptionName | string | The name of the created subscription. |
| subscriptionId | string | The resource id of the created subscription. |

## Links
- [Bicep Microsoft.ApiManagement subscriptions](https://learn.microsoft.com/en-us/azure/templates/microsoft.apimanagement/2023-05-01-preview/service/subscriptions?pivots=deployment-language-bicep)
