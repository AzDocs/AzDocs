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

#disable-next-line BCP081
@description('Upsert the user assigned managed identity.')
resource userManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2021-09-30-preview' = {
  name: userAssignedManagedIdentityName
  tags: tags
  location: location
}

@description('The User Assigned Managed Identities Resource ID.')
output userManagedIdentityId string = userManagedIdentity.id
@description('The User Assigned Managed Identities Resource name.')
output userManagedIdentityName string = userManagedIdentity.name
@description('The User Assigned Managed Identities Object ID.')
output userManagedIdentityObjectId string = userManagedIdentity.properties.principalId
