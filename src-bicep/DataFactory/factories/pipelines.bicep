@description('The resource name of the Data Factory you are targeting. This resource has to be pre-existing.')
@minLength(3)
@maxLength(63)
param dataFactoryName string

@description('The resource name of the Data Factory pipeline to be upserted.')
@minLength(1)
@maxLength(260)
param dataFactoryPipelineName string

@description('List of activities in pipeline.	For options & formatting, please refer to: https://docs.microsoft.com/en-us/azure/templates/microsoft.datafactory/factories/pipelines?pivots=deployment-language-bicep#activity.')
param activities array = []

@description('Fetch the existing data factory & upsert its pipelines with the given parameters.')
resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: dataFactoryName

  resource pipeline 'pipelines@2018-06-01' = {
    name: dataFactoryPipelineName
    properties: {
      activities: activities
    }
  }
}

@description('The resource name of the upserted pipeline in the data factory')
output dataFactoryPipelineName string = dataFactory::pipeline.name
@description('The resource ID of the upserted pipeline in the data factory')
output dataFactoryPipelineResourceId string = dataFactory::pipeline.id
