/*
.SYNOPSIS
Creating certificates in an existing Api Management Service.
.DESCRIPTION
Creating certificates in an existing Api Management Service.
<pre>
module certs 'br:contosoregistry.azurecr.io/service/certificates.bicep' = {
  name: format('{0}-{1}', take('${deployment().name}', 59), 'certs')
  params: {
    apiManagementServiceName: apiManagementServiceName
    apimCertificateData: loadFileAsBase64('./domain_company_so_org.pfx')
    apimCertificatePassword: 'myCertPassword'
  }
}
</pre>
<p>Creates a certificate by loading the pfx as base64 encoded and providing the password.</p>
<pre>
module certs2 'br:contosoregistry.azurecr.io/service/certificates.bicep' = {
  name: format('{0}-{1}', take('${deployment().name}', 58), 'certs2')
  params: {
    apiManagementServiceName: apiManagementServiceName
    secretIdentifier: 'https://keyvaultname${environment().suffixes.keyvaultDns}/secrets/certname-org'
  }
}
</pre>
<p>Creates a certificate in the existing Apim service by using the system assigned identity of the Apim service to access the keyvault for the certificate.</p>
.LINKS
- [Bicep Microsoft.ApiManagement certificates](https://learn.microsoft.com/en-us/azure/templates/microsoft.apimanagement/service/certificates?pivots=deployment-language-bicep)
- [APIM and Identities](https://learn.microsoft.com/en-us/azure/api-management/api-management-howto-use-managed-service-identity)
*/
// ===================================== Parameters =====================================
@description('The name of the existing API Management service instance.')
param apiManagementServiceName string

@description('The id/name of the certificate to create.')
@maxLength(80)
@minLength(1)
param apimCertificateName string = 'apimCertificate'

@secure()
@description('The password for the certificate.')
param apimCertificatePassword string = ''

@description('The client id of the identity to use to access the keyvault. If left empty the system assigned identity will be used.')
param identityClientId string = ''

@secure()
@description('The secret identifier of the certificate in the keyvault.')
param secretIdentifier string = ''

@description('''
Base 64 encoded certificate using the application/x-pkcs12 representation.
Example:
loadFileAsBase64('./somecert_so_company_org.pfx')
''')
param apimCertificateData string = ''

resource apimService 'Microsoft.ApiManagement/service@2023-03-01-preview' existing = {
  name: apiManagementServiceName
}

@description('Creating certificate. Use either data/password or keyVault')
resource apimCertificate 'Microsoft.ApiManagement/service/certificates@2023-03-01-preview' = {
  name: apimCertificateName
  parent: apimService
  properties: {
    data: apimCertificateData
    password: apimCertificatePassword
    keyVault: {
      identityClientId: !empty(identityClientId) ? identityClientId : null //system assigned identity will be used with null
      secretIdentifier: secretIdentifier
    }
  }
}

@description('The id of the created certificate.')
output certificateId string = apimCertificate.id
@description('The name of the created certificate.')
output certificateName string = apimCertificate.name
