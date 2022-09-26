@description('The resource name of the Data Factory you are targeting. This resource has to be pre-existing.')
@minLength(3)
@maxLength(63)
param dataFactoryName string

@description('The resourcename of the linked service you want to use for this DataSet. This resource has to be pre-existing.')
@minLength(1)
@maxLength(260)
param dataFactoryLinkedServiceName string

@description('The properties for this linked service type. For options & formatting, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.datafactory/2018-06-01/factories/linkedservices?pivots=deployment-language-bicep#linkedservice-objects.')
param dataFactoryLinkedServiceTypeProperties object = {}

@description('List of tags that can be used for describing the linked service.')
param annotations array = []

@description('If you need to connect through a integration runtime, this is the parameter to define that. For options & formatting, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.datafactory/2018-06-01/factories/linkedservices?pivots=deployment-language-bicep#integrationruntimereference.')
param connectVia object = {}

@description('Sets the type for this linked service. For current options please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.datafactory/2018-06-01/factories/linkedservices?pivots=deployment-language-bicep#linkedservice-objects.')
param dataFactoryLinkedServiceType string = 'AzureBlobStorage'

@description('Fetch the existing datafactory')
resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: dataFactoryName
}

@description('Upsert the linkedservice with the given parameters.')
resource dataFactoryLinkedService 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  parent: dataFactory
  name: dataFactoryLinkedServiceName
  properties: {
    annotations: annotations
    #disable-next-line BCP225
    type: dataFactoryLinkedServiceType
    typeProperties: dataFactoryLinkedServiceTypeProperties
    connectVia: connectVia
  }
}

@description('Outputs the resource name of the upserted linkedservice')
output dataFactoryLinkedServiceName string = dataFactoryLinkedService.name
@description('Outputs the resource ID of the upserted linkedservice')
output dataFactoryLinkedServiceId string = dataFactoryLinkedService.id
