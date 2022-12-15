@description('The name of the Application Insights instance.')
@minLength(1)
@maxLength(260)
param appInsightsName string

@description('The azure resource id of the Log Analytics Workspace to use as the data provider for this Application Insights.')
param logAnalyticsWorkspaceResourceId string

@description('The location for this Application Insights instance to be upserted in.')
param location string = resourceGroup().location

@description('''
The tags to apply to this resource. This is an object with key/value pairs.
Example:
{
  FirstTag: myvalue
  SecondTag: another value
}
''')
param tags object = {}

@description('Upsert the Application Insights instance.')
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Flow_Type: 'Bluefield'
    IngestionMode: 'LogAnalytics'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    Request_Source: 'rest'
    WorkspaceResourceId: logAnalyticsWorkspaceResourceId
  }
}

@description('The instrumentation key for this Applicaion Insights which can be used in an application.')
output appInsightsInstrumentationKey string = appInsights.properties.InstrumentationKey
@description('The connectionstring for this Applicaion Insights which can be used in an application.')
output appInsightsConnectionString string = appInsights.properties.ConnectionString
@description('The name of the created application insights instance.')
output appInsightsName string = appInsights.name
@description('The Resource ID for this application insights.')
output appInsightsResourceId string = appInsights.id
