/* This module automatically approves an accesspolicy for an API connection */

@description('Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location.')
param location string = resourceGroup().location

@description('The name of the access policy to approve within the API connection.')
param connectionsAccessPolicyName string

@description('The Object ID of the AAD principal to allow access to this API connection.')
@minLength(36)
@maxLength(36)
param azureActiveDirectoryPrincipalObjectId string

@description('''
The tags to apply to this resource. This is an object with key/value pairs.
Example:
{
  FirstTag: myvalue
  SecondTag: another value
}
''')
param tags object = {}

@description('Upsert the accessPolicy for the API connection resource with the given parameters.')
#disable-next-line BCP081
resource policy 'Microsoft.Web/connections/accessPolicies@2016-06-01' = {
  name: connectionsAccessPolicyName
  location: location
  tags: tags
  properties: {
    principal: {
      type: 'ActiveDirectory'
      identity: {
        tenantId: subscription().tenantId
        objectId: azureActiveDirectoryPrincipalObjectId
      }
    }
  }
}
