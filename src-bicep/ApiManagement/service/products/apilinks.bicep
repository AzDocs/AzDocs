/*
.SYNOPSIS
Creating a apiLink resource on an existing Product to an existing API.
.DESCRIPTION
Creating a apiLink resource on an existing Product to an existing API.
<pre>
module apiLink 'br:contosoregistry.azurecr.io/service/products/apilinks.bicep' = {
  name: format('{0}-{1}', take('${deployment().name}', 57), 'apilink')
  params: {
    apiLinkName: apiLinkName
    apiId: apiId
    productName: productName
  }
}
</pre>
<p>Creates an apiLink resource with the specified parameters.</p>
.LINKS
- [Bicep Microsoft.ApiManagement products](https://learn.microsoft.com/en-us/azure/templates/microsoft.apimanagement/2023-05-01-preview/service/products/apilinks?pivots=deployment-language-bicep)
*/
// ===================================== Parameters =====================================

@description('The name of the apiLink.')
@minLength(1)
param apiLinkName string

@description('Full resource Id of an existing API.')
@minLength(1)
param apiId string

@description('The name of an existing product in the following format: <apimServiceName>/<productName>.')
@minLength(1)
param productName string

resource product 'Microsoft.ApiManagement/service/products@2023-05-01-preview' existing = {
  name: productName
}

resource apilink 'Microsoft.ApiManagement/service/products/apiLinks@2023-05-01-preview' = {
  name: apiLinkName
  parent: product
  properties: {
    apiId: apiId
  }
}

@description('The id of the apiLink.')
output apilinkId string = apilink.id

@description('The name of the apiLink.')
output apilinkName string = apilink.name
