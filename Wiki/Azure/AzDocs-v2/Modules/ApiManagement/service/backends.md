# backends

Target Scope: resourceGroup

## Synopsis
Creating a backend instance in an existing Api Management Service.

## Description
Creating a backend instance in an existing Api Management Service.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| apiManagementServiceName | string | <input type="checkbox" checked> | Length between 1-50 | <pre></pre> | The name of the existing API Management service instance. |
| name | string | <input type="checkbox" checked> | Length between 1-50 | <pre></pre> | The name of the backend. |
| title | string | <input type="checkbox"> | None | <pre>''</pre> | Backend Title |
| doValidateCertificateChain | bool | <input type="checkbox"> | None | <pre>true</pre> | Flag indicating whether SSL certificate chain validation should be done when using self-signed certificates for this backend host. Default is true. |
| doValidateCertificateName | bool | <input type="checkbox"> | None | <pre>true</pre> | Flag indicating whether SSL certificate name validation should be done when using self-signed certificates for this backend host. Default is true. |
| pool | resourceInput<'Microsoft.ApiManagement/service/backends@2023-05-01-preview'>.properties.pool? | <input type="checkbox" checked> | None | <pre></pre> | Conditional. Backend pool configuration for load balancing. Required if type is Pool and not supported if type is Single. |
| type | resourceInput<'Microsoft.ApiManagement/service/backends@2023-05-01-preview'>.properties.type | <input type="checkbox"> | None | <pre>'Single'</pre> | Optional. Type of the backend. A backend can be either Single or Pool. |
| url | string? | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | Conditional. Runtime Url of the Backend. Required if type is Single and not supported if type is Pool. |
| protocol | string | <input type="checkbox"> | `'http'` or `'soap'` | <pre>'http'</pre> | Backend communication protocol. You need to define one type. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| backendName | string | The name of the created backend instance. |
| backendId | string | The resource id of the created backend instance. |

## Examples
<pre>
module backend 'br:contosoregistry.azurecr.io/service/backends.bicep' = {
  name: format('{0}-{1}', take('${deployment().name}', 46), 'backends')
  params: {
    apiManagementServiceName: apiManagementServiceName
    name: backendName
    title: backendTitle
    url: backendUrl
    doValidateCertificateChain: doValidatingCertificateChain
    doValidateCertificateName: doValidatingCertificateName
  }
}
</pre>
<p>Creates a backend instance with the name backendName.</p>
<pre>
module backend 'br:contosoregistry.azurecr.io/service/backends.bicep' = {
  name: format('{0}-{1}', take('${deployment().name}', 46), 'backends')
  params: {
    apiManagementServiceName: apiManagementServiceName
    name: backendNamePool
    title: backendTitlePool
    type: 'Pool'
    pool: {
      services: [
        {
          id: 'backendInstance1.outputs.backendId'
        }
        {
          id: 'backendInstance2.outputs.backendId'
        }
      ]
    }
  }
}
</pre>
<p>Creates a backend pool with the name backendNamePool and with multiple backend instances for load balancing.</

## Links
- [Bicep Microsoft.ApiManagement backends](https://learn.microsoft.com/en-us/azure/templates/microsoft.apimanagement/service/backends?pivots=deployment-language-bicep)
