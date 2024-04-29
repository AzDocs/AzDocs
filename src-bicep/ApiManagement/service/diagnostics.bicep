/*
.SYNOPSIS
Creating diagnostics in an existing Api Management Service.
.DESCRIPTION
Creatingdiagnostics in an existing Api Management Service.
<pre>
module diagnostics 'br:contosoregistry.azurecr.io/service/diagnostics.bicep' = {
  name: format('{0}-{1}', take('${deployment().name}', 59), 'diag')
  params: {
    apiManagementServiceName: apimPost.outputs.apiManagementServiceName
    apimDiagnosticsName: 'appInsightsDiagnostics'
    loggerId: appInsights.outputs.appInsightsResourceId
    logClientIp: true
  }
}
</pre>
<p>Creates a diagnostics with the name appInsightsDiagnostics in the existing Apim service.</p>
.LINKS
- [Bicep Microsoft.ApiManagement diagnostics](https://learn.microsoft.com/en-us/azure/templates/microsoft.apimanagement/service/diagnostics?pivots=deployment-language-bicep)
*/
// ===================================== Parameters =====================================
@description('The name of the existing API Management service instance.')
param apiManagementServiceName string

@description('The name of the diagnostics.')
@maxLength(80)
@minLength(1)
param apimDiagnosticsName string

@description('Resource Id of a target logger. For example the resourceId of an Application Insights resource.')
param loggerId string

@description('Specifies whether to log the client IP address. Default is true.')
param logClientIp bool = true

@description('Specifies for what type of messages sampling settings should not apply.')
param alwaysLog string = 'allErrors'

@description('The verbosity level applied to traces emitted by trace policies')
@allowed([
  'error'
  'information'
  'verbose'
])
param verbosity string = 'information'

@description('Rate of sampling for fixed-rate sampling.')
param samplingPercentage int = 100

@description('Type of sampling.')
param samplingType string = 'fixed'

@description('Sets correlation protocol to use for Application Insights diagnostics.')
@allowed([
  'Legacy'
  'None'
  'W3C'
])
param httpCorrelationProtocol string = 'Legacy'

resource apimService 'Microsoft.ApiManagement/service@2023-03-01-preview' existing = {
  name: apiManagementServiceName
}

resource apimDiagnostics 'Microsoft.ApiManagement/service/diagnostics@2023-03-01-preview' = {
  parent: apimService
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
