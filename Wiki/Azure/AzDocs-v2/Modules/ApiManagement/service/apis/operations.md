# operations

Target Scope: resourceGroup

## Synopsis
Creating an api operation in an existing Api Management Service.

## Description
Creating an api opreation in an existing Api Management Service.
<pre>
module apiOperation 'resource.operation.bicep' = {
  name: '${take(deployment().name, 19)}-apioperation-${take(apiName, 20)}-${take(operationName, 10)}'
  params: {
    apiManagementServiceName: apiManagementServiceName
    apiName: apiName
    operationName: operationName
    operationDisplayName: operationDisplayName
    operationMethod: operationMethod
    operationRequestDescription: operationRequestDescription
    operationRequestQueryParameters: operationRequestQueryParameters
    operationResponses: operationResponses
    operationUrlTemplate: operationUrlTemplate
  }
}
</pre><br>
<p>Creates an api operation on an existing api with the name operationName.</p>

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| apiManagementServiceName | string | <input type="checkbox" checked> | Length between 1-50 | <pre></pre> | The name of the API Management service instance. |
| apiName | string | <input type="checkbox" checked> | Length between 1-50 | <pre></pre> | The api name. |
| operationName | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | The name of the deployment. |
| operationMethod | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | The HTTP method of the operation. |
| operationDisplayName | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | The display name of the operation. |
| operationRequestQueryParameters | array | <input type="checkbox" checked> | None | <pre></pre> | The query parameters of the operation. |
| operationRequestDescription | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | The request description of the operation. |
| operationResponses | array | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | The responses of the operation. |
| operationUrlTemplate | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | The URL template of the operation. |
| templateParameters | array | <input type="checkbox" checked> | None | <pre></pre> | The template parameters of the operation. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| operationName | string | The name of the API Management service instance. |
| operationDisplayName | string | The display name of the operation. |
| operationId | string | The id of the operation. |

## Links
- [Bicep Microsoft.ApiManagement api opreations](https://learn.microsoft.com/en-us/azure/templates/microsoft.apimanagement/service/apis/operations?pivots=deployment-language-bicep)
