/*
.SYNOPSIS
Creating an Application Insights instance.
.DESCRIPTION
Creating an Application Insights instance integrated with Log Analytics Workspace for Azure Monitor.
<pre>
module appInsights 'br:contosoregistry.azurecr.io/insights/components:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 52), 'appinsights')
  params: {
    appInsightsName: 'appi-myapp-dev'
    logAnalyticsWorkspaceResourceId: logAnalyticsWorkspace.id
    location: 'westeurope'
    retentionInDays: 90
    disableLocalAuth: true
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    tags: {
      Environment: 'Development'
      Application: 'MyApp'
    }
  }
}
</pre>
<p>Creates an Application Insights component with Log Analytics workspace integration for application monitoring and telemetry collection.</p>
.LINKS
- [Bicep Application Insights Components](https://learn.microsoft.com/en-us/azure/templates/microsoft.insights/components?pivots=deployment-language-bicep)
*/
// ===================================== Parameters =====================================
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

@description('The kind of application that this component refers to, used to customize UI.')
@allowed(['web', 'ios', 'other', 'store', 'java', 'phone'])
param kind string = 'web'

@description('Type of application being monitored.')
@allowed(['web', 'other'])
param applicationType string = 'web'

@description('Used by the Application Insights system to determine what kind of flow this component was created by.')
param flowType string = 'Bluefield'

@description('Indicates the flow of the ingestion.')
@allowed(['ApplicationInsights', 'ApplicationInsightsWithDiagnosticSettings', 'LogAnalytics'])
param ingestionMode string = 'LogAnalytics'

@description('The network access type for accessing Application Insights ingestion.')
@allowed(['Enabled', 'Disabled'])
param publicNetworkAccessForIngestion string = 'Enabled'

@description('The network access type for accessing Application Insights query.')
@allowed(['Enabled', 'Disabled'])
param publicNetworkAccessForQuery string = 'Enabled'

@description('Describes what tool created this Application Insights component.')
param requestSource string = 'rest'

@description('Retention period in days for Application Insights data.')
param retentionInDays int = 90

@description('Disable IP masking for telemetry data.')
param disableIpMasking bool = false

@description('Disable Non-AAD based authentication.')
param disableLocalAuth bool = false

@description('Force users to create their own storage account for profiler and debugger.')
param forceCustomerStorageForProfiler bool = false

@description('The unique application ID for HockeyApp integration.')
param hockeyAppId string = ''

@description('Purge data immediately after 30 days.')
param immediatePurgeDataOn30Days bool = false

@description('Percentage of the data produced by the application being monitored that is being sampled for Application Insights telemetry.')
param samplingPercentage int?

@description('Upsert the Application Insights instance.')
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: kind
  tags: tags
  properties: {
    Application_Type: applicationType
    Flow_Type: flowType
    IngestionMode: ingestionMode
    publicNetworkAccessForIngestion: publicNetworkAccessForIngestion
    publicNetworkAccessForQuery: publicNetworkAccessForQuery
    Request_Source: requestSource
    WorkspaceResourceId: logAnalyticsWorkspaceResourceId
    RetentionInDays: retentionInDays
    DisableIpMasking: disableIpMasking
    DisableLocalAuth: disableLocalAuth
    ForceCustomerStorageForProfiler: forceCustomerStorageForProfiler
    HockeyAppId: !empty(hockeyAppId) ? hockeyAppId : null
    ImmediatePurgeDataOn30Days: immediatePurgeDataOn30Days
    SamplingPercentage: samplingPercentage
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
