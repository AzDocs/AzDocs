/*
.SYNOPSIS
Creating a Resource Group.
.DESCRIPTION
Creating a Resource Group.
.EXAMPLE
<p>Creates a Resource group with the name  MyFirstRg in subscriptionId a56350f0-347b-4393-963e-e3e090286fd6</p>
<pre>
param location string = 'westeurope'
var subscriptionId = 'a56350f0-347b-4393-963e-e3e090286fd6'
module rg '../../AzDocs/src-bicep/Resources/resourceGroups.bicep' = {
  name: 'Creating_RG_MyFirstVM'
  scope: az.subscription(subscriptionId)
  params: {
    resourceGroupName: 'MyFirstRg'
    location: location
  }
}
</pre>
.LINKS
- [Bicep Microsoft.Resources resourceGroups](https://docs.microsoft.com/en-us/azure/templates/microsoft.resources/resourcegroups?pivots=deployment-language-bicep)
*/

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
