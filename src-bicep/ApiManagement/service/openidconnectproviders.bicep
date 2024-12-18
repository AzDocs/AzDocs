/*
.SYNOPSIS
Register or modify OpenId Connect in Api Management Service.
.DESCRIPTION
Register a new or modify OpenId Connect provider in Api Management Service.
<pre>
module diagnostics 'br:contosoregistry.azurecr.io/service/openidconnectproviders.bicep' = {
  name: format('{0}-{1}', take('${deployment().name}', 58), 'openidconnectproviders')
  params: {
    apiManagementServiceName: apiManagementServiceName
    clientId: clientId
    clientSecret: clientSecret
    description: description
    displayName: displayName
    metadataEndpoint: metadataEndpoint
    name: name
    useInApiDocumentation: useInApiDocumentation
    useInTestConsole: useInTestConsole
  }
}
</pre>
<p>Register or modify OpenId Connect in Api Management Service.</p>
.LINKS
- [Bicep Microsoft.ApiManagement diagnostics](https://learn.microsoft.com/en-us/azure/templates/microsoft.apimanagement/service/openidconnectproviders?pivots=deployment-language-bicep)
*/
// ===================================== Parameters =====================================
@sys.description('''
Character limit: 1-50

Valid characters:
Alphanumerics and hyphens.

Start with letter and end with alphanumeric.

Resource name must be unique across Azure.
''')
@minLength(1)
@maxLength(50)
param apiManagementServiceName string

@sys.description('Client ID for the OpenID Connect Provider.')
@minLength(1)
param clientId string

@sys.description('Client Secret for the OpenID Connect Provider.')
@secure()
@minLength(1)
param clientSecret string

@sys.description('User-friendly description of OpenID Connect Provider.')
@minLength(1)
@maxLength(256)
param description string

@sys.description('User-friendly OpenID Connect Provider name.')
@minLength(1)
@maxLength(50)
param displayName string

@sys.description('Metadata endpoint URL for the OpenID Connect Provider.')
param metadataEndpoint string

@sys.description('The resource name.')
@minLength(1)
param name string

@sys.description('If true, the Open ID Connect provider will be used in the API documentation in the developer portal. False by default if no value is provided.')
param useInApiDocumentation bool = false

@sys.description('If true, the Open ID Connect provider may be used in the developer portal test console. True by default if no value is provided.')
param useInTestConsole bool = true

resource apiManagementService 'Microsoft.ApiManagement/service@2023-03-01-preview' existing = {
  name: apiManagementServiceName
}

resource symbolicname 'Microsoft.ApiManagement/service/openidConnectProviders@2024-06-01-preview' = {
  parent: apiManagementService
  name: name
  properties: {
    clientId: clientId
    clientSecret: clientSecret
    description: description
    displayName: displayName
    metadataEndpoint: metadataEndpoint
    useInApiDocumentation: useInApiDocumentation
    useInTestConsole: useInTestConsole
  }
}
