# policies

Target Scope: resourceGroup

## Synopsis
Creating an api policy in an existing Api Management Service.

## Description
Creating an api policy in an existing Api Management Service.<br>
<pre><br>
module apipolicies 'br:contosoregistry.azurecr.io/service/apis/policies.bicep:latest' = {<br>
  name: format('{0}-{1}', take('${deployment().name}', 46), 'apipolicies')<br>
  dependsOn: [<br>
    apimServices<br>
  ]<br>
  params: {<br>
    serviceApiName: serviceApiName<br>
    name: apiPolicyName<br>
    contentValue: contentValue<br>
    contentFormat: contentFormat<br>
  }<br>
</pre><br>
<p>Creates an api policy with the name apiPolicyName.</p>

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| serviceApiName | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | The name of the existing service API instance. |
| contentFormat | string | <input type="checkbox"> | `'rawxml'` or `'rawxml-link'` or `'xml'` or `'xml-link'` | <pre>'rawxml'</pre> | Format of the Content in which the API is getting imported. |
| contentValue | string | <input type="checkbox" checked> | None | <pre></pre> | Contents of the Policy as defined by the format.<br>Example:<br>loadTextContent('./policysample.xml') |
| apiManagementServiceName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the existing API Management service. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| apiPolicyName | string | The name of the created API policy instance. |
| apiPolicyId | string | The resource id of the created API policy instance. |

## Links
- [Bicep Microsoft.ApiManagement api policies](https://learn.microsoft.com/en-us/azure/templates/microsoft.apimanagement/service/apis/policies?pivots=deployment-language-bicep)
