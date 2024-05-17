/*
.SYNOPSIS
Creating a policy resource in an existing Api Management Service.
.DESCRIPTION
Creating a policy resource in an existing Api Management Service.
<pre>
module policies 'br:contosoregistry.azurecr.io/service/policies.bicep' = {
  name: format('{0}-{1}', take('${deployment().name}', 46), 'policies')
  params: {
    apiManagementServiceName: apiManagementServiceName
    name: policyName
    format: format
    value: value
  }
}
</pre>
<p>Creates a policy resource with the name policyFragmentName.</p>
.LINKS
- [Bicep Microsoft.ApiManagement policies](https://learn.microsoft.com/en-us/azure/templates/microsoft.apimanagement/service/policies?pivots=deployment-language-bicep)
*/
// ===================================== Parameters =====================================
@description('The name of the existing API Management service instance.')
@minLength(1)
@maxLength(50)
param apiManagementServiceName string

@description('The resource name')
@minLength(1)
param name string

@description('Format of the policyContent.')
@allowed([
  'rawxml'
  'rawxml-link'
  'xml'
  'xml-link'
])
param format string = 'rawxml'

@description('Contents of the Policy as defined by the format.')
@minLength(1)
param value string

resource apimService 'Microsoft.ApiManagement/service@2023-05-01-preview' existing = {
  name: apiManagementServiceName
}

resource servicePolicy 'Microsoft.ApiManagement/service/policies@2023-05-01-preview' = {
  name: name
  parent: apimService
  properties: {
    format: format
    value: value
  }
}

@description('The name of the created service policy instance.')
output servicePolicyName string = servicePolicy.name
@description('The resource id of the created service policy instance.')
output servicePolicyId string = servicePolicy.id
