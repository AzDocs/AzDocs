/*
.SYNOPSIS
Creating an api policy in an existing Api Management Service.
.DESCRIPTION
Creating an api policy in an existing Api Management Service.
<pre>
module apipolicies 'br:contosoregistry.azurecr.io/service/apis/policies.bicep:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 46), 'apipolicies')
  dependsOn: [
    apimServices
  ]
  params: {
    serviceApiName: serviceApiName
    name: apiPolicyName
    contentValue: contentValue
    contentFormat: contentFormat
  }
</pre>
<p>Creates an api policy with the name apiPolicyName.</p>
.LINKS
- [Bicep Microsoft.ApiManagement api policies](https://learn.microsoft.com/en-us/azure/templates/microsoft.apimanagement/service/apis/policies?pivots=deployment-language-bicep)
*/
// ===================================== Parameters =====================================
@description('The name of the existing service API instance.')
@minLength(1)
param serviceApiName string

@description('Format of the Content in which the API is getting imported.')
@allowed([
  'rawxml'
  'rawxml-link'
  'xml'
  'xml-link'
])
param contentFormat string = 'rawxml'

@description('''
Contents of the Policy as defined by the format.
Example:
loadTextContent('./policysample.xml')
''')
param contentValue string

resource serviceApi 'Microsoft.ApiManagement/service/apis@2023-03-01-preview' existing = {
  name: serviceApiName
}

resource apiPolicy 'Microsoft.ApiManagement/service/apis/policies@2023-03-01-preview' = {
  name: 'policy'
  parent: serviceApi
  properties: {
    value: contentValue
    format: contentFormat
  }
}

@description('The name of the created API policy instance.')
output apiPolicyName string = apiPolicy.name
@description('The resource id of the created API policy instance.')
output apiPolicyId string = apiPolicy.id



