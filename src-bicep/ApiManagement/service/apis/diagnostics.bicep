/*
.SYNOPSIS
Creating diagnostics in an existing Api Management API.
.DESCRIPTION
Creating diagnostics in an existing Api Management API.
<pre>
module diagnostics 'br:contosoregistry.azurecr.io/service/apis/diagnostics.bicep' = {
  name: format('{0}-{1}', take('${deployment().name}', 59), 'diag')
  params: {
    apiManagementServiceName: apimPost.outputs.apiManagementServiceName
    apimDiagnosticsName: 'appInsightsDiagnostics'
    loggerId: appInsights.outputs.appInsightsResourceId
    logClientIp: true
  }
}
</pre>
<p>Creates a diagnostics with the name appInsightsDiagnostics in the existing Apim API.</p>
.LINKS
- [Bicep Microsoft.ApiManagement diagnostics](https://learn.microsoft.com/en-us/azure/templates/microsoft.apimanagement/service/apis/diagnostics?pivots=deployment-language-bicep)
*/
// ===================================== Parameters =====================================
@description('The name of the existing API Management service instance.')
param apiManagementServiceName string

@description('The api name which is created in the API Management service.')
@minLength(1)
@maxLength(50)
param apiName string

@description('The name of the diagnostics.')
type diagnosticNameTypes = 'applicationinsights' | 'azuremonitor'
param apimDiagnosticsName diagnosticNameTypes

@description('Resource Id of a target logger. For example the resourceId of an Application Insights resource.')
@minLength(1)
param loggerId string

@description('Specifies whether to log the client IP address. Default is true.')
param logClientIp bool = true

@description('Specifies for what type of messages sampling settings should not apply.')
param alwaysLog string = 'allErrors'

@description('The verbosity level applied to traces emitted by trace policies')
type verobisityTypes = 'error' | 'information' | 'verbose'
param verbosity string = 'information'

@description('Rate of sampling for fixed-rate sampling.')
param samplingPercentage int = 100

@description('Type of sampling.')
param samplingType string = 'fixed'

@description('Sets correlation protocol to use for Application Insights diagnostics.')
type httpCorrelationProtocolTypes = 'Legacy' | 'None' | 'W3C'
param httpCorrelationProtocol httpCorrelationProtocolTypes = 'Legacy'

resource apimService 'Microsoft.ApiManagement/service@2023-03-01-preview' existing = {
  name: apiManagementServiceName
}

resource apiManagementServiceApi 'Microsoft.ApiManagement/service/apis@2023-09-01-preview' existing = {
  name: apiName
  parent: apimService
}

resource apimDiagnostics 'Microsoft.ApiManagement/service/apis/diagnostics@2023-09-01-preview' = {
  parent: apiManagementServiceApi
  name: apimDiagnosticsName
  properties: {
    loggerId: loggerId
    logClientIp: logClientIp
    alwaysLog: alwaysLog
    verbosity: verbosity
    sampling: {
      percentage: samplingPercentage
      samplingType: samplingType
    }
    httpCorrelationProtocol: httpCorrelationProtocol
  }
}
