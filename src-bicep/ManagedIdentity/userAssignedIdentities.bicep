/*
.SYNOPSIS
Creating a User Assigned Managed Identity.
.DESCRIPTION
This Bicep file provisions a userassigned managed identity with the specified name, location, and tags.
.EXAMPLE
<pre>
module userAssignedIdentity 'br:contosoregistry.azurecr.io/managedidentity/userassignedidentities:latest' = {
  name: 'userAssignedIdentityDeployment'
  params: {
    userAssignedManagedIdentityName: 'myManagedIdentity'
    tags: {
      Environment: 'Development'
      Project: 'ManagedIdentity'
    }
  }
}
</pre>
<p>Creates a user assigned managed identity with the name myManagedIdentity</p>
.LINKS
- [Bicep Microsoft.ManagedIdentity userAssignedIdentities](https://learn.microsoft.com/en-us/azure/templates/microsoft.managedidentity/2024-11-30/userassignedidentities?pivots=deployment-language-bicep)
*/


// ===================================== Parameters =====================================
@description('The location of this logic app to reside in. This defaults to the resourcegroup location.')
param location string = resourceGroup().location

@description('The name to assign to this user assigned managed identity.')
@minLength(3)
@maxLength(128)
param userAssignedManagedIdentityName string

@description('''
The tags to apply to this resource. This is an object with key/value pairs.
Example:
{
  FirstTag: myvalue
  SecondTag: another value
}
''')
param tags object = {}

@description('Upsert the user assigned managed identity.')
resource userManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2024-11-30' = {
  name: userAssignedManagedIdentityName
  tags: tags
  location: location
}

@description('The User Assigned Managed Identities Resource ID.')
output userManagedIdentityId string = userManagedIdentity.id
@description('The User Assigned Managed Identities Principal ID.')
output userManagedIdentityPrincipalId string = userManagedIdentity.properties.principalId
@description('The User Assigned Managed Identities Client ID.')
output userManagedIdentityClientId string = userManagedIdentity.properties.clientId
@description('The User Assigned Managed Identities Resource name.')
output userManagedIdentityName string = userManagedIdentity.name
@description('The User Assigned Managed Identities Object (principal) ID.')
output userManagedIdentityObjectId string = userManagedIdentity.properties.principalId
