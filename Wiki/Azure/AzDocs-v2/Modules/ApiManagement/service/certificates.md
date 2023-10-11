# certificates

Target Scope: resourceGroup

## Synopsis
Creating certificates in an existing Api Management Service.

## Description
Creating certificates in an existing Api Management Service.<br>
<pre><br>
module certs 'br:contosoregistry.azurecr.io/service/certificates.bicep' = {<br>
  name: format('{0}-{1}', take('${deployment().name}', 59), 'certs')<br>
  params: {<br>
    apiManagementServiceName: apiManagementServiceName<br>
    apimCertificateData: loadFileAsBase64('./domain_company_so_org.pfx')<br>
    apimCertificatePassword: 'myCertPassword'<br>
  }<br>
}<br>
</pre><br>
<p>Creates a certificate by loading the pfx as base64 encoded and providing the password.</p><br>
<pre><br>
module certs2 'br:contosoregistry.azurecr.io/service/certificates.bicep' = {<br>
  name: format('{0}-{1}', take('${deployment().name}', 58), 'certs2')<br>
  params: {<br>
    apiManagementServiceName: apiManagementServiceName<br>
    secretIdentifier: 'https://keyvaultname${environment().suffixes.keyvaultDns}/secrets/certname-org'<br>
  }<br>
}<br>
</pre><br>
<p>Creates a certificate in the existing Apim service by using the system assigned identity of the Apim service to access the keyvault for the certificate.</p>

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| apiManagementServiceName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the existing API Management service instance. |
| apimCertificateName | string | <input type="checkbox"> | Length between 1-80 | <pre>'apimCertificate'</pre> | The id/name of the certificate to create. |
| apimCertificatePassword | string | <input type="checkbox"> | None | <pre>''</pre> | The password for the certificate. |
| identityClientId | string | <input type="checkbox"> | None | <pre>''</pre> | The client id of the identity to use to access the keyvault. If left empty the system assigned identity will be used. |
| secretIdentifier | string | <input type="checkbox"> | None | <pre>''</pre> | The secret identifier of the certificate in the keyvault. |
| apimCertificateData | string | <input type="checkbox"> | None | <pre>''</pre> | Base 64 encoded certificate using the application/x-pkcs12 representation.<br>Example:<br>loadFileAsBase64('./somecert_so_company_org.pfx') |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| certificateId | string | The id of the created certificate. |
| certificateName | string | The name of the created certificate. |
## Links
- [Bicep Microsoft.ApiManagement certificates](https://learn.microsoft.com/en-us/azure/templates/microsoft.apimanagement/service/certificates?pivots=deployment-language-bicep)<br>
- [APIM and Identities](https://learn.microsoft.com/en-us/azure/api-management/api-management-howto-use-managed-service-identity)


