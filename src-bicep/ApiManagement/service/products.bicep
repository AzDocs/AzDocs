/*
.SYNOPSIS
Creating a product resource in an existing Api Management Service.
.DESCRIPTION
Creating a product resource in an existing Api Management Service.
<pre>
module products 'br:contosoregistry.azurecr.io/service/products.bicep' = {
  name: format('{0}-{1}', take('${deployment().name}', 46), 'products')
  params: {
    apiManagementServiceName: apiManagementServiceName
    approvalRequired: approvalRequired
    productDescription: productDescription
    productDisplayName: productDisplayName
    name: productName
    state: state
    subscriptionRequired: subscriptionRequired
    subscriptionLimit: subscriptionLimit
    terms: terms
  }
}
</pre>
<p>Creates a product resource with the specified parameters.</p>
.LINKS
- [Bicep Microsoft.ApiManagement products](https://learn.microsoft.com/en-us/azure/templates/microsoft.apimanagement/service/products?pivots=deployment-language-bicep)
*/
// ===================================== Parameters =====================================
@description('The name of the existing API Management service instance.')
@minLength(1)
@maxLength(50)
param apiManagementServiceName string

@description('Whether subscription approval is required or not.')
param approvalRequired bool?

@description('Product description. May include HTML formatting tags.')
param productDescription string

@description('Product display name.')
param productDisplayName string

@description('The resource name')
@minLength(1)
@maxLength(80)
param name string

@allowed([
  'notPublished'
  'published'
])
@description('whether product is published or not. Published products are discoverable by users of developer portal. Non published products are visible only to administrators. Default state of Product is notPublished.')
param state string = 'notPublished'

@description('Whether subscription is required or not.')
param subscriptionRequired bool?

@description('Whether the number of subscriptions a user can have to this product at the same time. Set to null or omit to allow unlimited per user subscriptions. Can be present only if subscriptionRequired property is present and has a value of false.')
param subscriptionLimit int?

@description('Product terms of use. Developers trying to subscribe to the product will be presented and required to accept these terms before they can complete the subscription process.')
param terms string

resource apimService 'Microsoft.ApiManagement/service@2023-05-01-preview' existing = {
  name: apiManagementServiceName
}

resource product 'Microsoft.ApiManagement/service/products@2023-05-01-preview' = {
  name: name
  parent: apimService
  properties: {
    approvalRequired: approvalRequired
    description: productDescription
    displayName: productDisplayName
    state: state
    subscriptionRequired: subscriptionRequired
    subscriptionsLimit: subscriptionLimit
    terms: terms
  }
}

@description('The name of the product.')
output productName string = product.name

@description('The id of the product.')
output productId string = product.id
