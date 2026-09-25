# apis

Target Scope: resourceGroup

## Synopsis
Creating an api instance in an existing Api Management Service.

## Description
Creating an api instance in an existing Api Management Service.
<pre>
module apis 'br:contosoregistry.azurecr.io/service/apis.bicep' = {
  name: format('{0}-{1}', take('${deployment().name}', 46), 'apis')
dependsOn: [
    apimPolicyFragments
    apimGlobalPolicy
    apimBackends
  ]
  params: {
    apiManagementServiceName: apiManagementServiceName
    apiName: apiName
    displayName: displayName
    apiType: 'http'
    isCurrent: isCurrent
    isSubscriptionRequred: isSubscriptionRequired
    apiDescription: apidescription
    apiPath: apiPath
    contentValue: contentValue
    contentFormat: contentFormat
    apiPolicy: apiPolicy
  }
}
</pre><br>
<p>Creates an api instance with the name displayName.</p>

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| apiManagementServiceName | string | <input type="checkbox" checked> | Length between 1-50 | <pre></pre> | The name of the existing API Management service instance. |
| name | string | <input type="checkbox" checked> | Length between 1-80 | <pre></pre> | The resource name of the api. |
| apiDescription | string | <input type="checkbox"> | None | <pre>''</pre> | Description of the API. May include HTML formatting tags. |
| displayName | string | <input type="checkbox"> | Length between 0-300 | <pre>''</pre> | API name. |
| apiType | string | <input type="checkbox"> | `'graphql'` or `'http'` or `'odata'` or `'soap'` or `'websocket'` | <pre>'http'</pre> | Type of API to create. You need to define one type. |
| isCurrent | bool | <input type="checkbox"> | None | <pre>true</pre> | Indicates if API revision is current api revision. Default is true. |
| isSubscriptionRequired | bool | <input type="checkbox"> | None | <pre>true</pre> | Specifies whether an API or Product subscription is required for accessing the API. Default is true. |
| apiPath | string | <input type="checkbox"> | None | <pre>''</pre> | Relative URL uniquely identifying this API and all of its resource paths within the API Management service instance. It is appended to the API endpoint base URL specified during the service instance creation to form a public URL for this API. |
| contentFormat | string? | <input type="checkbox" checked> | `'graphql-link'` or `'odata'` or `'odata-link'` or `'openapi'` or `'openapi+json'` or `'openapi+json-link'` or `'openapi-link'` or `'swagger-json'` or `'swagger-link-json'` or `'wadl-link-json'` or `'wadl-xml'` or `'wsdl'` or `'wsdl-link'` | <pre></pre> | Format of the Content in which the API is getting imported. |
| contentValue | string? | <input type="checkbox" checked> | None | <pre></pre> | Content value when Importing an API. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| apiName | string | The name of the created API instance. |
| apiId | string | The resource id of the created API instance. |

## Links
- [Bicep Microsoft.ApiManagement apis](https://learn.microsoft.com/en-us/azure/templates/microsoft.apimanagement/service/apis?pivots=deployment-language-bicep)
