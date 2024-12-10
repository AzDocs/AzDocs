/*
.SYNOPSIS
Add a grouplink to a product in Api Management Service.
.DESCRIPTION
Add a grouplink to a product Access Control List (ACL) in Api Management Service.
<pre>
module diagnostics 'br:contosoregistry.azurecr.io/service/groups.bicep' = {
  name: format('{0}-{1}', take('${deployment().name}', 58), 'groups')
  params: {
    apiManagementServiceName: apiManagementServiceName
    groupId: groupId
    groupLinkName: groupLinkName
    productName: productName
  }
}
</pre>
<p>Add a grouplink to a product Access Control List (ACL) in Api Management Service.</p>
.LINKS
- [Bicep Microsoft.ApiManagement diagnostics](https://learn.microsoft.com/en-us/azure/templates/microsoft.apimanagement/service/products/grouplinks?pivots=deployment-language-bicep)
*/
// ===================================== Parameters =====================================
@description('The name of the API Management service.')
@minLength(1)
@maxLength(50)
param apiManagementServiceName string

@description('The ID of the group.')
@minLength(1)
param groupId string

@description('The name of the group link.')
@minLength(1)
param groupLinkName string

@description('The name of the product.')
@minLength(1)
param productName string

resource apiManagementService 'Microsoft.ApiManagement/service@2023-03-01-preview' existing = {
  name: apiManagementServiceName
}

resource product 'Microsoft.ApiManagement/service/products@2023-03-01-preview' existing = {
  parent: apiManagementService
  name: productName
}

resource productGroupLink 'Microsoft.ApiManagement/service/products/groupLinks@2023-03-01-preview' = {
  parent: product
  name: groupLinkName
  properties: {
    groupId: groupId
  }
}

@description('The resource ID of the group link.')
output groupIdOutput string = groupId
@description('The name of the group link.')
output groupLinkNameOutput string = groupLinkName
@description('The name of the product.')
output productNameOutput string = productName
