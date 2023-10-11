# loggers

Target Scope: resourceGroup

## Synopsis
Creating logger in an existing Api Management Service.

## Description
Creating logger in an existing Api Management Service.<br>
<pre><br>
module logger 'br:contosoregistry.azurecr.io/service/loggers.bicep' = {<br>
  name: format('{0}-{1}', take('${deployment().name}', 57), 'logger')<br>
  params: {<br>
    apiManagementServiceName: apimPost.outputs.apiManagementServiceName<br>
    loggerType: 'applicationInsights'<br>
    loggerName: 'appInsightsLogger'<br>
    loggerDescription: 'Application Insights for APIM'<br>
    resourceId: appInsights.outputs.appInsightsResourceId<br>
    credentials: {<br>
      instrumentationKey: namedValueAppInsightsKey.outputs.namedValueValue<br>
    }<br>
  }<br>
}<br>
</pre><br>
<p>Creates a logger with the name appInsightsLogger .</p>

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| apiManagementServiceName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the existing API Management service instance. |
| loggerName | string | <input type="checkbox" checked> | Length between 1-80 | <pre></pre> | The resource name of the logger. |
| credentials | object | <input type="checkbox"> | None | <pre>{}</pre> | The name and sendRule connection string of the Event Hub for an AzureEventHub logger. Or an Instrumentation key for applicationInsights logger. |
| loggerDescription | string | <input type="checkbox"> | None | <pre>''</pre> |  |
| loggerIsBuffered | bool | <input type="checkbox"> | None | <pre>true</pre> | Whether records are buffered in the logger before publishing. Default is assumed to be true. |
| loggerType | string | <input type="checkbox"> | `'applicationInsights'` or `'azureEventHub'` or `'azureMonitor'` | <pre>'applicationInsights'</pre> | Logger type. You need to define one type. |
| resourceId | string | <input type="checkbox" checked> | None | <pre></pre> | The Azure Resource Id of a log target (either Azure Event Hub resource or Azure Application Insights resource). |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| loggerName | string | The name of the existing API Management service instance. |
| loggerId | string | The resource id of the logger. |
## Links
- [Bicep Microsoft.ApiManagement named values](https://learn.microsoft.com/en-us/azure/templates/microsoft.apimanagement/service/loggers?pivots=deployment-language-bicep)


