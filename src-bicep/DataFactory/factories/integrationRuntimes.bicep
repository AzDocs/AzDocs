@description('The resource name of the Data Factory you are targeting. This resource has to be pre-existing.')
@minLength(3)
@maxLength(63)
param dataFactoryName string

@description('The resource name of the managed virtual network within the given Data Factory. This resource should be pre-existing.')
@minLength(2)
@maxLength(64)
param dataFactoryManagedVirtualNetworkName string

@description('The resource name of the integration runtime to upsert.')
@minLength(3)
@maxLength(63)
param dataFactoryIntegrationRuntimeName string

@description('''
Data flow properties for managed integration runtime. For options & formatting, please refer to: https://docs.microsoft.com/en-us/azure/templates/microsoft.datafactory/2018-06-01/factories/integrationruntimes?pivots=deployment-language-bicep#integrationruntimedataflowproperties.
Defaults to:
{
  computeType: 'General'
  coreCount: 8
  timeToLive: 0
}
''')
param integrationRuntimeDataFlowProperties object = {
  computeType: 'General'
  coreCount: 8
  timeToLive: 0
}

@description('The type of the integration runtime.')
@allowed([
  'Managed'
  'SelfHosted'
])
param dataFactoryIntegrationRuntimeType string = 'Managed'

@description('Fetch existing datafactory & managedvirtualnetwork to upsert the integration runtime')
resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: dataFactoryName

  resource managedVirtualNetwork 'managedVirtualNetworks@2018-06-01' existing = {
    name: dataFactoryManagedVirtualNetworkName
  }

  resource integrationRuntime 'integrationRuntimes@2018-06-01' = {
    name: dataFactoryIntegrationRuntimeName
    properties: {
      description: dataFactoryIntegrationRuntimeName
      #disable-next-line BCP225
      type: dataFactoryIntegrationRuntimeType
      managedVirtualNetwork: {
        referenceName: 'default' // TODO: Find out if this is always hardcoded default.
        type: 'ManagedVirtualNetworkReference'
      }
      typeProperties: {
        computeProperties: {
          location: 'AutoResolve'
          dataFlowProperties: integrationRuntimeDataFlowProperties
        }
      }
    }
    dependsOn: [
      managedVirtualNetwork
    ]
  }
}

@description('Output the resourcename of this integration runtime.')
output dataFactoryIntegrationRuntimeResourceName string = dataFactory::integrationRuntime.name
@description('Output the resource id of this integration runtime.')
output dataFactoryIntegrationRuntimeResourceId string = dataFactory::integrationRuntime.id
