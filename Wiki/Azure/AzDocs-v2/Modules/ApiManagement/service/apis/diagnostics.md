# diagnostics

Target Scope: resourceGroup

## User Defined Types
| Name | Type | Discriminator | Description
| -- |  -- | -- | -- |
| <a id="diagnosticNameTypes">diagnosticNameTypes</a>  | <pre>'applicationinsights' &#124; 'azuremonitor'</pre> |  | The name of the diagnostics. | 
| <a id="verobisityTypes">verobisityTypes</a>  | <pre>'error' &#124; 'information' &#124; 'verbose'</pre> |  | The verbosity level applied to traces emitted by trace policies | 
| <a id="httpCorrelationProtocolTypes">httpCorrelationProtocolTypes</a>  | <pre>'Legacy' &#124; 'None' &#124; 'W3C'</pre> |  | Sets correlation protocol to use for Application Insights diagnostics. | 

## Synopsis
Creating diagnostics in an existing Api Management API.

## Description
Creating diagnostics in an existing Api Management API.<br>
<pre><br>
module diagnostics 'br:contosoregistry.azurecr.io/service/apis/diagnostics.bicep' = {<br>
  name: format('{0}-{1}', take('${deployment().name}', 59), 'diag')<br>
  params: {<br>
    apiManagementServiceName: apimPost.outputs.apiManagementServiceName<br>
    apimDiagnosticsName: 'appInsightsDiagnostics'<br>
    loggerId: appInsights.outputs.appInsightsResourceId<br>
    logClientIp: true<br>
  }<br>
}<br>
</pre><br>
<p>Creates a diagnostics with the name appInsightsDiagnostics in the existing Apim API.</p>

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| apiManagementServiceName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the existing API Management service instance. |
| apiName | string | <input type="checkbox" checked> | Length between 1-50 | <pre></pre> | The api name which is created in the API Management service. |
| apimDiagnosticsName | diagnosticNameTypes | <input type="checkbox" checked> | None | <pre></pre> |  |
| loggerId | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | Resource Id of a target logger. For example the resourceId of an Application Insights resource. |
| logClientIp | bool | <input type="checkbox"> | None | <pre>true</pre> | Specifies whether to log the client IP address. Default is true. |
| alwaysLog | string | <input type="checkbox"> | None | <pre>'allErrors'</pre> | Specifies for what type of messages sampling settings should not apply. |
| verbosity | string | <input type="checkbox"> | None | <pre>'information'</pre> |  |
| samplingPercentage | int | <input type="checkbox"> | None | <pre>100</pre> | Rate of sampling for fixed-rate sampling. |
| samplingType | string | <input type="checkbox"> | None | <pre>'fixed'</pre> | Type of sampling. |
| httpCorrelationProtocol | httpCorrelationProtocolTypes | <input type="checkbox"> | None | <pre>'Legacy'</pre> |  |

## Links
- [Bicep Microsoft.ApiManagement diagnostics](https://learn.microsoft.com/en-us/azure/templates/microsoft.apimanagement/service/apis/diagnostics?pivots=deployment-language-bicep)
