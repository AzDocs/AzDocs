# policies

Target Scope: resourceGroup

## Synopsis
Provision an operation policy in an existing Api Management Service.

## Description
Provision an operation policy on an existing API in an existing Api Management Service.<br>
<pre><br>
module apiOperationPolicy 'policies/resource.policies.bicep' = {<br>
  name: '${take(deployment().name, 12)}-apioperation-${take(apiName, 20)}-${take(operationName, 10)}-policy'<br>
  params: {<br>
    apiManagementServiceName: apiManagementServiceName<br>
    apiName: apiName<br>
    contentFormat: contentFormat<br>
    operationName: operationName<br>
    operationValue: operationValue<br>
  }<br>
}<br>
</pre><br>
<p>Provision an operation policy on an existing API in an existing Api Management Service.</p>

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| apiManagementServiceName | string | <input type="checkbox" checked> | Length between 1-50 | <pre></pre> | The name of the API Management service instance. |
| apiName | string | <input type="checkbox" checked> | Length between 1-50 | <pre></pre> | The api name. |
| contentFormat | string | <input type="checkbox"> | `'rawxml'` or `'rawxml-link'` or `'xml'` or `'xml-link'` | <pre>'rawxml'</pre> | Format of the Content in which the API is getting imported. |
| operationName | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | The name of the deployment. |
| operationValue | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | The operation policy value. |

## Links
- [Bicep Microsoft.ApiManagement api policies](https://learn.microsoft.com/en-us/azure/templates/microsoft.apimanagement/service/apis/operations/policies?pivots=deployment-language-bicep)
