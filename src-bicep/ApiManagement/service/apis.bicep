/*
.SYNOPSIS
Creating an api instance in an existing Api Management Service.
.DESCRIPTION
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
</pre>
<p>Creates an api instance with the name displayName.</p>
.LINKS
- [Bicep Microsoft.ApiManagement apis](https://learn.microsoft.com/en-us/azure/templates/microsoft.apimanagement/service/apis?pivots=deployment-language-bicep)
*/
// ===================================== Parameters =====================================
@description('The name of the existing API Management service instance.')
@minLength(1)
@maxLength(50)
param apiManagementServiceName string

@description('The resource name of the api.')
@maxLength(80)
@minLength(1)
param name string

@description('Description of the API. May include HTML formatting tags.')
param apiDescription string = ''

@description('API name.')
@maxLength(300)
@minLength(1)
param displayName string

@description('Type of API to create. You need to define one type.')
@allowed([
  'graphql'
  'http'
  'odata'
  'soap'
  'websocket'
])
param apiType string = 'http'

@description('Indicates if API revision is current api revision. Default is true.')
param isCurrent bool = true

@description('Specifies whether an API or Product subscription is required for accessing the API. Default is true.')
param isSubscriptionRequired bool = true

@description('Relative URL uniquely identifying this API and all of its resource paths within the API Management service instance. It is appended to the API endpoint base URL specified during the service instance creation to form a public URL for this API.')
@minLength(1)
param apiPath string

// Format 'swagger-link-json' (OpenAPI 2.0 JSON Document) , 'openapi+json-link' (OpenAPI 3.0 JSON document) & 'openapi-link' (OpenAPI 3.0 YAML document) works only for documents hosted on public internet
@description('Format of the Content in which the API is getting imported.')
@allowed([
  'graphql-link'
  'odata'
  'odata-link'
  'openapi'
  'openapi+json'
  'openapi+json-link'
  'openapi-link'
  'swagger-json'
  'swagger-link-json'
  'wadl-link-json'
  'wadl-xml'
  'wsdl'
  'wsdl-link'])
param contentFormat string

@description('Content value when Importing an API.')
param contentValue string

resource apimService 'Microsoft.ApiManagement/service@2023-05-01-preview' existing = {
  name: apiManagementServiceName
}

resource api 'Microsoft.ApiManagement/service/apis@2023-05-01-preview' = {
  name: name
  parent: apimService
  properties: {
    description: apiDescription
    type: apiType
    apiType: apiType
    isCurrent: isCurrent
    subscriptionRequired: isSubscriptionRequired
    displayName: displayName
    path: apiPath
    protocols: [
      'https'
    ]
    format: contentFormat
    value: contentValue
  }
}

@description('The name of the created API instance.')
output apiName string = api.name
@description('The resource id of the created API instance.')
output apiId string = api.id


