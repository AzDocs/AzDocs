# diagnostics

Target Scope: resourceGroup

## Synopsis
Creating diagnostics in an existing Api Management Service.

## Description
Creatingdiagnostics in an existing Api Management Service.<br>
<pre><br>
module diagnostics 'br:contosoregistry.azurecr.io/service/diagnostics.bicep' = {<br>
  name: format('{0}-{1}', take('${deployment().name}', 59), 'diag')<br>
  params: {<br>
    apiManagementServiceName: apimPost.outputs.apiManagementServiceName<br>
    apimDiagnosticsName: 'appInsightsDiagnostics'<br>
    loggerId: appInsights.outputs.appInsightsResourceId<br>
    logClientIp: true<br>
  }<br>
}<br>
</pre><br>
<p>Creates a diagnostics with the name appInsightsDiagnostics in the existing Apim service.</p>

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| apiManagementServiceName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the existing API Management service instance. |
| apimDiagnosticsName | string | <input type="checkbox" checked> | Length between 1-80 | <pre></pre> | The name of the diagnostics. |
| loggerId | string | <input type="checkbox" checked> | None | <pre></pre> | Resource Id of a target logger. For example the resourceId of an Application Insights resource. |
| logClientIp | bool | <input type="checkbox"> | None | <pre>true</pre> | Specifies whether to log the client IP address. Default is true. |
| alwaysLog | string | <input type="checkbox"> | None | <pre>'allErrors'</pre> | Specifies for what type of messages sampling settings should not apply. |
| verbosity | string | <input type="checkbox"> | `'error'` or `'information'` or `'verbose'` | <pre>'information'</pre> | The verbosity level applied to traces emitted by trace policies |
| samplingPercentage | int | <input type="checkbox"> | None | <pre>100</pre> | Rate of sampling for fixed-rate sampling. |
| samplingType | string | <input type="checkbox"> | None | <pre>'fixed'</pre> | Type of sampling. |
| httpCorrelationProtocol | string | <input type="checkbox"> | `'Legacy'` or `'None'` or `'W3C'` | <pre>'Legacy'</pre> | Sets correlation protocol to use for Application Insights diagnostics. |

## Links
- [Bicep Microsoft.ApiManagement diagnostics](https://learn.microsoft.com/en-us/azure/templates/microsoft.apimanagement/service/diagnostics?pivots=deployment-language-bicep)
