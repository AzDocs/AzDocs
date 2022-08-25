@description('The resourcename of the routetable. Preferably the same as the VNet')
@minLength(1)
@maxLength(80)
param routeTableName string

@description('Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location.')
param location string = resourceGroup().location

@description('Array containing routes. For array/object format refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.network/routetables?tabs=bicep#route')
param routes array

@description('''
The tags to apply to this resource. This is an object with key/value pairs.
Example:
{
  FirstTag: myvalue
  SecondTag: another value
}
''')
param tags object = {}

@description('Upsert the routeTable with the given parameters.')
resource routeTable 'Microsoft.Network/routeTables@2021-03-01' = {
  name: routeTableName
  location: location
  tags: tags
  properties: {
    disableBgpRoutePropagation: false
    routes: routes
  }
}

@description('Output the resourcename of this routetable.')
output routeTableName string = routeTable.name
@description('Output the resource id of this routetable.')
output routeTableResourceId string = routeTable.id
