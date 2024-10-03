/*
.SYNOPSIS
Creating a webtest resource on an existing Application Insights Resource.
.DESCRIPTION
Creates a webtest resource
.NOTES
.EXAMPLE
<pre>
module webtest '.br:contosoregistry.azurecr.io/insights/webtests.bicep' = {
  name: format('{0}-{1}', take('${deployment().name}', 56), 'webtest')
  params: {
    applicationInsightsName: appInsights.outputs.appInsightsName
    request: {
      RequestUrl: 'https://www.nu.nl'
      HttpVerb: 'GET'
      ParseDependentRequests: false
    }
    webtestName: 'cmdbhandlertest'
    webtestResourceName: 'webtest'
    validationRules: {
      ExpectedHttpStatusCode: 200
      SSLCheck: true
      SSLCertRemainingLifetimeCheck: 7
    }
  }
}
</pre>
<p>Creates a Application Insights WebTest resource with the name 'webtest'</p>
.LINKS
- [Bicep AppInsights WebTests](https://learn.microsoft.com/en-us/azure/templates/microsoft.insights/webtests?pivots=deployment-language-bicep)
*/

// ================================================= Parameters =================================================
@description('The location for this Application Insights instance to be upserted in.')
param location string = resourceGroup().location

@description('Required. Name of the webtest resource to upsert.')
param webtestResourceName string

@description('Existing parent Application Insights resource')
@minLength(1)
param applicationInsightsName string

@description('Required. User defined name if this WebTest.')
param webtestName string

@description('Optional. Resource tags. Note: a mandatory tag \'hidden-link\' based on the \'appInsightResourceId\' parameter will be automatically added to the tags defined here.')
param tags object?

@description('''
Required. The collection of request properties.
Example:
{
  RequestUrl: 'https://${appService.properties.defaultHostName}'
  HttpVerb: 'GET'
  ParseDependentRequests: false
}
''')
param request object

@description('Optional. User defined description for this WebTest.')
param webtestDescription string = ''

@description('Optional. Unique ID of this WebTest.')
param syntheticMonitorId string = webtestResourceName

@description('Optional. The kind of WebTest that this web test watches.')
@allowed([
  'multistep'
  'ping'
  'standard'
])
param kind string = 'standard'

@description('''
Optional. [Complete list](https://learn.microsoft.com/en-us/previous-versions/azure/azure-monitor/app/monitor-web-app-availability#location-population-tags) 
of where to physically run the tests from to give global coverage for accessibility of your application.
''')
param webtestLocations array = [
  {
    Id: 'emea-nl-ams-azr' //West Europe
  }
  {
    Id: 'emea-ch-zrh-edge' //France South
  }
  {
    Id: 'emea-se-sto-edge' //UK West
  }
]

@description('Optional. Is the test actively being monitored.')
param enabled bool = true

@description('Optional. Interval in seconds between test runs for this WebTest.')
param frequency int = 300

@description('Optional. Seconds until this WebTest will timeout and fail.')
param timeout int = 30

@description('Optional. Allow for retries should this WebTest fail.')
param retryEnabled bool = true

@description('''
Optional. The collection of validation rule properties.
Example:
{
  ExpectedHttpStatusCode: 200
  SSLCheck: true
  SSLCertRemainingLifetimeCheck: 7
}
''')
param validationRules object = {}

@description('Optional. An XML configuration specification for a WebTest defining an XML specification of a WebTest to run against an application.')
param configuration object?

var hiddenLinkTag = {
  'hidden-link:${applicationInsights.id}': 'Resource'
}

// ================================================= Existing Resources ==========================================
resource applicationInsights 'microsoft.insights/components@2020-02-02' existing = {
  name: applicationInsightsName
}

// ================================================= Creating Resources ==========================================
resource webtest 'Microsoft.Insights/webtests@2022-06-15' = {
  name: webtestResourceName
  location: location
  tags: union(tags ?? {}, hiddenLinkTag)
  properties: {
    Kind: kind
    Locations: webtestLocations
    Name: webtestName
    Description: webtestDescription
    SyntheticMonitorId: syntheticMonitorId
    Enabled: enabled
    Frequency: frequency
    Timeout: timeout
    RetryEnabled: retryEnabled
    Request: request
    ValidationRules: validationRules
    Configuration: configuration
  }
}

@description('Outputs the resource id of the webtest resource.')
output webtestResourceId string = webtest.id
@description('Outputs the resourcename of the webtest resource.')
output webtestResourceName string = webtest.name
