/*
.SYNOPSIS
Creating a backend instance in an existing Api Management Service.
.DESCRIPTION
Creating a backend instance in an existing Api Management Service.
.EXAMPLE
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
.EXAMPLE
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
.LINKS
- [Bicep Microsoft.ApiManagement backends](https://learn.microsoft.com/en-us/azure/templates/microsoft.apimanagement/service/backends?pivots=deployment-language-bicep)
*/
// ===================================== Parameters =====================================
@description('The name of the existing API Management service instance.')
@minLength(1)
@maxLength(50)
param apiManagementServiceName string

@description('The name of the backend.')
@minLength(1)
@maxLength(50)
param name string

@description('Backend Title')
param title string = ''

@description('Flag indicating whether SSL certificate chain validation should be done when using self-signed certificates for this backend host. Default is true.')
param doValidateCertificateChain bool = true

@description('Flag indicating whether SSL certificate name validation should be done when using self-signed certificates for this backend host. Default is true.')
param doValidateCertificateName bool = true

@description('Conditional. Backend pool configuration for load balancing. Required if type is Pool and not supported if type is Single.')
param pool resourceInput<'Microsoft.ApiManagement/service/backends@2023-05-01-preview'>.properties.pool?

@description('Optional. Type of the backend. A backend can be either Single or Pool.')
@allowed(['Single', 'Pool'])
param type string = 'Single'

@description('Conditional. Runtime Url of the Backend. Required if type is Single and not supported if type is Pool.')
@minLength(1)
param url string?

@description('Backend communication protocol. You need to define one type.')
@allowed([
  'http'
  'soap'
])
param protocol string = 'http'

resource apimService 'Microsoft.ApiManagement/service@2023-05-01-preview' existing = {
  name: apiManagementServiceName
}

resource backend 'Microsoft.ApiManagement/service/backends@2023-05-01-preview' = {
  name: name
  parent: apimService
  properties: {
    title: title
    type: type
    ...(type == 'Single'
      ? {
          tls: {
            validateCertificateChain: doValidateCertificateChain
            validateCertificateName: doValidateCertificateName
          }
          url: url
          protocol: protocol
        }
      : {
          pool: pool
        })
  }
}

@description('The name of the created backend instance.')
output backendName string = backend.name
@description('The resource id of the created backend instance.')
output backendId string = backend.id
