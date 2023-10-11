/*
.SYNOPSIS
Creating logger in an existing Api Management Service.
.DESCRIPTION
Creating logger in an existing Api Management Service.
<pre>
module logger 'br:contosoregistry.azurecr.io/service/loggers.bicep' = {
  name: format('{0}-{1}', take('${deployment().name}', 57), 'logger')
  params: {
    apiManagementServiceName: apimPost.outputs.apiManagementServiceName
    loggerType: 'applicationInsights'
    loggerName: 'appInsightsLogger'
    loggerDescription: 'Application Insights for APIM'
    resourceId: appInsights.outputs.appInsightsResourceId
    credentials: {
      instrumentationKey: namedValueAppInsightsKey.outputs.namedValueValue
    }
  }
}
</pre>
<p>Creates a logger with the name appInsightsLogger .</p>
.LINKS
- [Bicep Microsoft.ApiManagement named values](https://learn.microsoft.com/en-us/azure/templates/microsoft.apimanagement/service/loggers?pivots=deployment-language-bicep)
*/
// ===================================== Parameters =====================================
@description('The name of the existing API Management service instance.')
param apiManagementServiceName string

@description('The resource name of the logger.')
@maxLength(80)
@minLength(1)
param loggerName string

@description('The name and sendRule connection string of the Event Hub for an AzureEventHub logger. Or an Instrumentation key for applicationInsights logger.')
param credentials object = {}

param loggerDescription string = ''

@description('Whether records are buffered in the logger before publishing. Default is assumed to be true.')
param loggerIsBuffered bool = true

@description('Logger type. You need to define one type.')
@allowed([
  'applicationInsights'
  'azureEventHub'
  'azureMonitor'
])
param loggerType string = 'applicationInsights'

@description('The Azure Resource Id of a log target (either Azure Event Hub resource or Azure Application Insights resource).')
param resourceId string

resource apimService 'Microsoft.ApiManagement/service@2023-03-01-preview' existing = {
  name: apiManagementServiceName
}
resource logger 'Microsoft.ApiManagement/service/loggers@2023-03-01-preview' = {
  name: loggerName
  parent: apimService
  properties: {
    credentials: credentials
    description: loggerDescription
    isBuffered: loggerIsBuffered
    loggerType: loggerType
    resourceId: resourceId
  }
}

@description('The name of the existing API Management service instance.')
output loggerName string = logger.name
@description('The resource id of the logger.')
output loggerId string = logger.id
