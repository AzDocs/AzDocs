# backends

Target Scope: resourceGroup

## Synopsis
Creating a backend instance in an existing Api Management Service.

## Description
Creating a backend instance in an existing Api Management Service.<br>
<pre><br>
module backend 'br:contosoregistry.azurecr.io/service/backends.bicep' = {<br>
  name: format('{0}-{1}', take('${deployment().name}', 46), 'backends')<br>
  params: {<br>
    apiManagementServiceName: apiManagementServiceName<br>
    name: backendName<br>
    title: backendTitle<br>
    url: backendUrl<br>
    doValidateCertificateChain: doValidatingCertificateChain<br>
    doValidateCertificateName: doValidatingCertificateName<br>
  }<br>
}<br>
</pre><br>
<p>Creates a backend instance with the name backendName.</p>

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| apiManagementServiceName | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | The name of the existing API Management service instance. |
| name | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | The name of the backend. |
| title | string | <input type="checkbox"> | None | <pre>''</pre> | Backend Title |
| doValidateCertificateChain | bool | <input type="checkbox"> | None | <pre>true</pre> | Flag indicating whether SSL certificate chain validation should be done when using self-signed certificates for this backend host. Default is true. |
| doValidateCertificateName | bool | <input type="checkbox"> | None | <pre>true</pre> | Flag indicating whether SSL certificate name validation should be done when using self-signed certificates for this backend host. Default is true. |
| url | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | Runtime Url of the Backend. |
| protocol | string | <input type="checkbox"> | `'http'` or `'soap'` | <pre>'http'</pre> | Backend communication protocol. You need to define one type. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| backendName | string | The name of the created backend instance. |
| backendId | string | The resource id of the created backend instance. |

## Links
- [Bicep Microsoft.ApiManagement backends](https://learn.microsoft.com/en-us/azure/templates/microsoft.apimanagement/service/backends?pivots=deployment-language-bicep)
