/*
.SYNOPSIS
Creating an api operation in an existing Api Management Service.
.DESCRIPTION
Creating an api opreation in an existing Api Management Service.
<pre>
module apiOperation 'resource.operation.bicep' = {
  name: '${take(deployment().name, 19)}-apioperation-${take(apiName, 20)}-${take(operationName, 10)}'
  params: {
    apiManagementServiceName: apiManagementServiceName
    apiName: apiName
    operationName: operationName
    operationDisplayName: operationDisplayName
    operationMethod: operationMethod
    operationRequestDescription: operationRequestDescription
    operationRequestQueryParameters: operationRequestQueryParameters
    operationResponses: operationResponses
    operationUrlTemplate: operationUrlTemplate
  }
}
</pre>
<p>Creates an api operation on an existing api with the name operationName.</p>
.LINKS
- [Bicep Microsoft.ApiManagement api opreations](https://learn.microsoft.com/en-us/azure/templates/microsoft.apimanagement/service/apis/operations?pivots=deployment-language-bicep)
*/
// ===================================== Parameters =====================================
@description('The name of the API Management service instance.')
@minLength(1)
@maxLength(50)
param apiManagementServiceName string

@description('The api name.')
@minLength(1)
@maxLength(50)
param apiName string

@description('The name of the deployment.')
@minLength(1)
param operationName string

@description('The HTTP method of the operation.')
@minLength(1)
param operationMethod string

@description('The display name of the operation.')
@minLength(1)
param operationDisplayName string

@description('The query parameters of the operation.')
param operationRequestQueryParameters array

@description('The request description of the operation.')
@minLength(1)
param operationRequestDescription string

@description('The responses of the operation.')
@minLength(1)
param operationResponses array

@description('The URL template of the operation.')
@minLength(1)
param operationUrlTemplate string

//------------------------------------------------------------------------------------
// Resources
//------------------------------------------------------------------------------------

resource apiManagementService 'Microsoft.ApiManagement/service@2023-09-01-preview' existing = {
  name: apiManagementServiceName
}

resource api 'Microsoft.ApiManagement/service/apis@2023-09-01-preview' existing = {
  name: apiName
  parent: apiManagementService
}

resource operation 'Microsoft.ApiManagement/service/apis/operations@2023-09-01-preview' = {
  name: operationName
  parent: api
  properties: {
    displayName: operationDisplayName
    method: operationMethod
    urlTemplate: operationUrlTemplate
    request: {
      description: operationRequestDescription
      queryParameters: operationRequestQueryParameters
    }
    responses: operationResponses
  }
}

@description('The name of the API Management service instance.')
output operationName string = operation.name
@description('The display name of the operation.')
output operationDisplayName string = operation.properties.displayName
@description('The id of the operation.')
output operationId string = operation.id
