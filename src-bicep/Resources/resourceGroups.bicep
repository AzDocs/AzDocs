// Scope definition (Targeting Subscription to be able to create a resourcegroup)
targetScope = 'subscription'

@description('Specifies the Azure location where the resource should be created.')
param location string = 'westeurope'

@description('The name of the resourcegroup to upsert.')
@minLength(1)
@maxLength(90)
param resourceGroupName string

@description('''
The tags to apply to this resourcegroup. This is an object with key/value pairs.
Example:
{
  FirstTag: myvalue
  SecondTag: another value
}
''')
param tags object = {}

@description('Upsert the resourcegroup with the given parameters.')
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

@description('Output the name of the resourcegroup.')
output resourceGroupName string = resourceGroup.name
