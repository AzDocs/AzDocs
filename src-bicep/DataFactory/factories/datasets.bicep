@description('The resource name of the Data Factory you are targeting. This resource has to be pre-existing.')
@minLength(3)
@maxLength(63)
param dataFactoryName string

@description('The name of the dataset to create.')
@minLength(1)
@maxLength(260)
param dataFactoryDatasetName string

@description('The resourcename of the linked service you want to use for this DataSet. This resource has to be pre-existing.')
@minLength(1)
@maxLength(260)
param dataFactoryLinkedServiceName string

@description('The type of the dataset to upsert. For options & formatting, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.datafactory/factories/datasets?pivots=deployment-language-bicep#dataset-objects.')
param dataFactoryDatasetType string = 'Binary'

@description('The properties of the datasettype to upsert. For options & formatting, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.datafactory/factories/datasets?pivots=deployment-language-bicep#dataset-objects.')
param dataFactoryDatasetTypeProperties object = {}

@description('Fetch the existing DataFactory.')
resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: dataFactoryName
}

@description('Fetch the existing Linked Service to use in this dataset.')
resource dataFactoryLinkedService 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' existing = {
  name: dataFactoryLinkedServiceName
}

@description('Upsert the Dataset with the given parameters.')
resource dataFactoryDataset 'Microsoft.DataFactory/factories/datasets@2018-06-01' = {
  parent: dataFactory
  name: dataFactoryDatasetName
  properties: {
    linkedServiceName: {
      referenceName: dataFactoryLinkedService.name
      type: 'LinkedServiceReference'
    }
    #disable-next-line BCP225
    type: dataFactoryDatasetType
    typeProperties: dataFactoryDatasetTypeProperties
  }
}

@description('Output the resource name of this dataset.')
output dataFactoryDatasetName string = dataFactoryDataset.name

@description('Output the resource id of this dataset.')
output dataFactoryDatasetResourceId string = dataFactoryDataset.id
