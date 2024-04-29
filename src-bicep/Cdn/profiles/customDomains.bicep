/*
.SYNOPSIS
Create a custom domain in an existing frontdoor CDN profile.
.DESCRIPTION
Create a custom domain in an existing frontdoor CDN profile.
<pre>
module customdomain 'br:contosoregistry.azurecr.io/cdn/profiles/customDomains.bicep' = {
    name: format('{0}-{1}', take('${deployment().name}', 51), 'customdomain')
  params: {
    customDomainName: 'my.perfect.site.company.org'
    frontDoorName: frontDoorProfile.outputs.frontDoorName
    customDomainCertificateType: 'CustomerCertificate'
    frontDoorSecretName: frontdoorsecret.outputs.secretName
  }
}
</pre>
<p>Creates a custom domain called my.perfect.site.company.org in an existing Frontdoor Cdn Profile.</p>
.LINKS
- [Bicep Microsoft.Cdn profiles custom domain](https://learn.microsoft.com/en-us/azure/templates/microsoft.cdn/profiles/customdomains?pivots=deployment-language-bicep)
*/
// ===================================== Parameters =====================================
@description('The custom domain name to associate with your Front Door endpoint (for example, `www.contoso.com`)')
param customDomainName string

@description('The name of the existing Front Door Cdn profile.')
param frontDoorName string

@description('The name of the existing Front Door secret when used.')
param frontDoorSecretName string = ''

@description('The name of the custom domain resource. This is a valid resource name and does not include periods.')
param customDomainResourceName string  = replace(customDomainName, '.', '-')

@description('''
The type of certificate. If the type "CustomerCertificate" is used, there must be a valid Secret Resource Reference Id.
Your domain will need to be validated before traffic is delivered to it. This can be done by creating a DNS TXT record with the name and value provided in the outputs.
''')
@allowed([
  'AzureFirstPartyManagedCertificate'
  'CustomerCertificate'
  'ManagedCertificate'
])
param customDomainCertificateType string

@description('Resource reference to the Azure DNS zone')
param azureDNSZoneId string = ''

@description('Resource reference to the Azure pre-validated domain')
param preValidatedCustomDomainResourceId string = ''

@description('''
The minimum TLS version required for this domain. TLS protocol version that will be used for Https.
Example:
'TLS10'
'TLS12'
''')
param customDomainTLSVersion string = 'TLS12'

// ===================================== Resources =====================================
@description('The existing Azure resource that represents the Front Door Cdn profile.')
resource CDNProfile 'Microsoft.Cdn/profiles@2022-11-01-preview' existing = {
  name: frontDoorName
}

@description('The existing Azure resource that represents the Front Door secret when used.')
resource frontDoorSecret 'Microsoft.Cdn/profiles/secrets@2022-11-01-preview' existing = if (!empty(frontDoorSecretName)) {
  parent: CDNProfile
  name: frontDoorSecretName
}

@description('''
If prevalidatedCustomDomainResourceId is not specified, a Non-Azure validated domain is used.
A non-Azure validated domain is a domain that requires ownership validation.
An Azure pre-validated domain is a domain already validated by another Azure service. Domain ownership validation isn't required by Azure Front Door then.
Currently Azure pre-validated domains only supports domains validated by Static Web App (custom domain in static web app).
You can bring your own certificate (use frontdoor secret).  A Self Signed certificate and is not permitted for Bring Your Own Certificate
''')
resource customDomain 'Microsoft.Cdn/profiles/customDomains@2022-11-01-preview' = {
  parent: CDNProfile
  name: customDomainResourceName
  properties: {
    azureDnsZone: !empty(azureDNSZoneId) ? {
      id: azureDNSZoneId
    }: null
    hostName: customDomainName
    preValidatedCustomDomainResourceId: !empty(preValidatedCustomDomainResourceId) ? {
      id: preValidatedCustomDomainResourceId
    }: null
    tlsSettings: {
      certificateType: customDomainCertificateType
      minimumTlsVersion: customDomainTLSVersion
      secret: empty(frontDoorSecretName) ? null : {
        id: frontDoorSecret.id
      }
    }
  }
}

@description('The name of the DNS TXT record to create to validate the domain. This is only required if you are using Azure DNS.')
output customDomainValidationDnsTxtRecordName string = '_dnsauth.${customDomain.properties.hostName}'
@description('The value of the DNS TXT record to create to validate the domain. This is only required if you are using Azure DNS.')
output customDomainValidationDnsTxtRecordValue string = customDomain.properties.validationProperties.validationToken
@description('The expiration date of the DNS TXT record. This is only required if you are using Azure DNS.')
output customDomainValidationExpiry string = customDomain.properties.validationProperties.expirationDate
@description('The ID of the custom domain.')
output customDomainId string = customDomain.id
