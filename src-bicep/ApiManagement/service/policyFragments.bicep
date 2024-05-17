/*
.SYNOPSIS
Creating a policy fragement to re-use in a policy definition in an existing Api Management Service.
.DESCRIPTION
Creating a policy fragement to re-use in a policy definition in an existing Api Management Service.
<pre>
module policyFragment 'br:contosoregistry.azurecr.io/service/policyFragments.bicep' = {
  name: format('{0}-{1}', take('${deployment().name}', 57), 'policyFragment')
  params: {
    apiManagementServiceName: apiManagementServiceName
    name: policyFragmentName
    fragmentDescription: description
    fragmentValue: value
  }
}
</pre>
<p>Creates a policy fragment with the name policyFragmentName.</p>
.LINKS
- [Bicep Microsoft.ApiManagement policy fragments](https://learn.microsoft.com/en-us/azure/templates/microsoft.apimanagement/service/policyfragments?pivots=deployment-language-bicep)
*/
// ===================================== Parameters =====================================
@description('The name of the existing API Management service instance.')
@minLength(1)
@maxLength(50)
param apiManagementServiceName string

@description('The resource name')
@minLength(1)
param name string

@description('Format of the policy fragment content.')
@allowed([
  'rawxml'
  'xml'
])
param format string = 'rawxml'

@description('The policy fragment description')
@minLength(1)
param fragmentDescription string

@description('Contents of the policy fragment.')
@minLength(1)
param fragmentValue string


resource apimService 'Microsoft.ApiManagement/service@2023-05-01-preview' existing = {
  name: apiManagementServiceName
}

resource policyFragment 'Microsoft.ApiManagement/service/policyFragments@2023-05-01-preview' = {
  name: name
  parent: apimService
  properties: {
    description: fragmentDescription
    format: format
    value: fragmentValue
  }
}

@description('The name of the created policy fragment.')
output policyFragmentName string = policyFragment.name
@description('The resource id of the created policy fragment.')
output policyFragmentId string = policyFragment.id
