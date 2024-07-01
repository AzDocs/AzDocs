# apilinks

Target Scope: resourceGroup

## Synopsis
Creating a apiLink resource on an existing Product to an existing API.

## Description
Creating a apiLink resource on an existing Product to an existing API.<br>
<pre><br>
module apiLink 'br:contosoregistry.azurecr.io/service/products/apilinks.bicep' = {<br>
  name: format('{0}-{1}', take('${deployment().name}', 57), 'apilink')<br>
  params: {<br>
    apiLinkName: apiLinkName<br>
    apiId: apiId<br>
    productName: productName<br>
  }<br>
}<br>
</pre><br>
<p>Creates an apiLink resource with the specified parameters.</p>

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| apiLinkName | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | The name of the apiLink. |
| apiId | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | Full resource Id of an existing API. |
| productName | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | The name of an existing product in the following format: <apimServiceName>/<productName>. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| apilinkId | string | The id of the apiLink. |
| apilinkName | string | The name of the apiLink. |

## Links
- [Bicep Microsoft.ApiManagement products](https://learn.microsoft.com/en-us/azure/templates/microsoft.apimanagement/2023-05-01-preview/service/products/apilinks?pivots=deployment-language-bicep)
