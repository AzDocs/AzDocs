/*
.SYNOPSIS
Creating an subscription in an existing Api Management Service.
.DESCRIPTION
Creating an subscription in an existing Api Management Service.
<pre>
module apis 'br:contosoregistry.azurecr.io/service/subscriptions:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 37), 'subscriptions')
  params: {
    allowTracing: allowTracing
    apiManagementServiceName: apiManagementServiceName
    displayName: displayName
    subscriptionName: apiName
    scope: scope
  }
}
</pre>
<p>Creates an subscription with the name displayName.</p>
.LINKS
- [Bicep Microsoft.ApiManagement subscriptions](https://learn.microsoft.com/en-us/azure/templates/microsoft.apimanagement/2023-05-01-preview/service/subscriptions?pivots=deployment-language-bicep)
*/
// ===================================== Parameters =====================================

@description('Specifies whether tracing is allowed for the subscription.')
param allowTracing bool = false

@description('The name of the API Management service.')
@minLength(1)
param apiManagementServiceName string

@description('The display name of the subscription.')
@minLength(1)
param displayName string

@description('The resource name of the subscription.')
@maxLength(80)
@minLength(1)
param subscriptionName string

@description('The state of the subscription.')
@allowed([
  'active'
  'cancelled'
  'expired'
  'rejected'
  'submitted'
  'suspended'
])
param state string

@description('''
The scope of entities this subscription is valid for. This can be a product, an API, or a product API.

Scope like /products/{productId} or /apis/{apiId}

When provided '/apis' is used as default scope (all APIs and Products)
''')
param scope string

resource apiManagementService 'Microsoft.ApiManagement/service@2023-05-01-preview' existing = {
  name: apiManagementServiceName
}

resource subscription 'Microsoft.ApiManagement/service/subscriptions@2023-05-01-preview' = {
  parent: apiManagementService
  name: subscriptionName
  properties: {
    allowTracing: allowTracing
    displayName: displayName
    scope: scope
    state: state
  }
}

@description('The name of the created subscription.')
output subscriptionName string = subscription.name
@description('The resource id of the created subscription.')
output subscriptionId string = subscription.id
