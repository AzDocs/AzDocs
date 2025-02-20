/*
.SYNOPSIS
Provision an operation policy in an existing Api Management Service.
.DESCRIPTION
Provision an operation policy on an existing API in an existing Api Management Service.
<pre>
module apiOperationPolicy 'policies/resource.policies.bicep' = {
  name: '${take(deployment().name, 12)}-apioperation-${take(apiName, 20)}-${take(operationName, 10)}-policy'
  params: {
    apiManagementServiceName: apiManagementServiceName
    apiName: apiName
    contentFormat: contentFormat
    operationName: operationName
    operationValue: operationValue
  }
}
</pre>
<p>Provision an operation policy on an existing API in an existing Api Management Service.</p>
.LINKS
- [Bicep Microsoft.ApiManagement api policies](https://learn.microsoft.com/en-us/azure/templates/microsoft.apimanagement/service/apis/operations/policies?pivots=deployment-language-bicep)
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

@description('Format of the Content in which the API is getting imported.')
@allowed([
  'rawxml'
  'rawxml-link'
  'xml'
  'xml-link'
])
param contentFormat string = 'rawxml'

@description('The name of the deployment.')
@minLength(1)
param operationName string

@description('The operation policy value.')
@minLength(1)
param operationValue string

resource apiManagementService 'Microsoft.ApiManagement/service@2023-09-01-preview' existing = {
  name: apiManagementServiceName
}

resource api 'Microsoft.ApiManagement/service/apis@2023-09-01-preview' existing = {
  name: apiName
  parent: apiManagementService
}

resource operation 'Microsoft.ApiManagement/service/apis/operations@2023-09-01-preview' existing = {
  name: operationName
  parent: api
}

resource policyOperation 'Microsoft.ApiManagement/service/apis/operations/policies@2023-09-01-preview' = {
  name: 'policy'
  parent: operation
  properties: {
    value: operationValue
    format: contentFormat
  }
}
