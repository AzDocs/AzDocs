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
| httpCorrelationProtocol | string | <input type="checkbox"> | `'error'` or `'information'` or `)` or `` or `param samplingPercentage int = 100` or `` or `` or `@allowed([` or `'Legacy'` or `'None'` or `'W3C'` | <pre>'Legacy'</pre> | The verbosity level applied to traces emitted by trace policies |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |
## Links
- [Bicep Microsoft.ApiManagement diagnostics](https://learn.microsoft.com/en-us/azure/templates/microsoft.apimanagement/service/diagnostics?pivots=deployment-language-bicep)


