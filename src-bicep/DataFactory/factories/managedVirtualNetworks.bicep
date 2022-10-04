@description('The resource name of the Data Factory you are targeting. This resource has to be pre-existing.')
@minLength(3)
@maxLength(63)
param dataFactoryName string

@description('The resource name of the managed virtual network to be upserted.')
@minLength(2)
@maxLength(64)
param dataFactoryManagedVirtualNetworkName string

@description('Fetch the existing data factory & Upsert the datafactory managed virtual network with the given parameters.')
resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: dataFactoryName

  resource managedVirtualNetwork 'managedVirtualNetworks@2018-06-01' = {
    name: dataFactoryManagedVirtualNetworkName
    properties: {}
  }
}

@description('Output the resourcename for the upserted managed virtual network.')
output dataFactoryManagedVirtualNetworkName string = dataFactory::managedVirtualNetwork.name
