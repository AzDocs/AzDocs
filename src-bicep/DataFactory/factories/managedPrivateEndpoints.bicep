@description('The resource name of the Data Factory you are targeting. This resource has to be pre-existing.')
@minLength(3)
@maxLength(63)
param dataFactoryName string

@description('The resource id of the resource you want to put this private endpoint in front of.')
param targetResourceId string

@description('The groupId to which the managed private endpoint is created. You can use Azure CLI with the command "az network private-link-resource list" to obtain the supported group ids.')
param groupId string

@description('The resource name of the managed private endpoint to create.')
@minLength(2)
@maxLength(64)
param managedPrivateEndpointName string

@description('The resource name of the managed virtual network to use while creating the managed private endpoint.')
@minLength(2)
@maxLength(64)
param managedVirtualNetworkName string

@description('Fully qualified domain names to attach to this private endpoint. You should fix the DNS yourself.') // TODO: Check workings & update docs
param managedPrivateEndpointFqdnsToAttach array = []

@description('Fetch the existing datafactory')
resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: dataFactoryName

  resource managedVirtualNetwork 'managedVirtualNetworks@2018-06-01' existing = {
    name: managedVirtualNetworkName

    resource managedPrivateEndpoint 'managedPrivateEndpoints@2018-06-01' = {
      name: managedPrivateEndpointName
      properties: {
        privateLinkResourceId: targetResourceId
        groupId: groupId
        fqdns: managedPrivateEndpointFqdnsToAttach
      }
    }
  }
}

// TODO: you need to approve the connection from target resource, eg storage

@description('Output the resource name for the upserted managed private endpoint.')
output managedPrivateEndpointResourceName string = dataFactory::managedVirtualNetwork::managedPrivateEndpoint.name
@description('Output the resource id for the upserted managed private endpoint.')
output managedPrivateEndpointResourceId string = dataFactory::managedVirtualNetwork::managedPrivateEndpoint.id
