# components

Target Scope: resourceGroup

## Synopsis
Creating an Application Insights instance.

## Description
Creating an Application Insights instance integrated with Log Analytics Workspace for Azure Monitor.<br>
<pre><br>
module appInsights 'br:contosoregistry.azurecr.io/insights/components:latest' = {<br>
  name: format('{0}-{1}', take('${deployment().name}', 52), 'appinsights')<br>
  params: {<br>
    appInsightsName: 'appi-myapp-dev'<br>
    logAnalyticsWorkspaceResourceId: logAnalyticsWorkspace.id<br>
    location: 'westeurope'<br>
    retentionInDays: 90<br>
    disableLocalAuth: true<br>
    publicNetworkAccessForIngestion: 'Enabled'<br>
    publicNetworkAccessForQuery: 'Enabled'<br>
    tags: {<br>
      Environment: 'Development'<br>
      Application: 'MyApp'<br>
    }<br>
  }<br>
}<br>
</pre><br>
<p>Creates an Application Insights component with Log Analytics workspace integration for application monitoring and telemetry collection.</p>

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| appInsightsName | string | <input type="checkbox" checked> | Length between 1-260 | <pre></pre> | The name of the Application Insights instance. |
| logAnalyticsWorkspaceResourceId | string | <input type="checkbox" checked> | None | <pre></pre> | The azure resource id of the Log Analytics Workspace to use as the data provider for this Application Insights. |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | The location for this Application Insights instance to be upserted in. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| kind | string | <input type="checkbox"> | None | <pre>'web'</pre> | The kind of application that this component refers to, used to customize UI. |
| applicationType | string | <input type="checkbox"> | None | <pre>'web'</pre> | Type of application being monitored. |
| flowType | string | <input type="checkbox"> | None | <pre>'Bluefield'</pre> | Used by the Application Insights system to determine what kind of flow this component was created by. |
| ingestionMode | string | <input type="checkbox"> | None | <pre>'LogAnalytics'</pre> | Indicates the flow of the ingestion. |
| publicNetworkAccessForIngestion | string | <input type="checkbox"> | None | <pre>'Enabled'</pre> | The network access type for accessing Application Insights ingestion. |
| publicNetworkAccessForQuery | string | <input type="checkbox"> | None | <pre>'Enabled'</pre> | The network access type for accessing Application Insights query. |
| requestSource | string | <input type="checkbox"> | None | <pre>'rest'</pre> | Describes what tool created this Application Insights component. |
| retentionInDays | int | <input type="checkbox"> | None | <pre>90</pre> | Retention period in days for Application Insights data. |
| disableIpMasking | bool | <input type="checkbox"> | None | <pre>false</pre> | Disable IP masking for telemetry data. |
| disableLocalAuth | bool | <input type="checkbox"> | None | <pre>false</pre> | Disable Non-AAD based authentication. |
| forceCustomerStorageForProfiler | bool | <input type="checkbox"> | None | <pre>false</pre> | Force users to create their own storage account for profiler and debugger. |
| hockeyAppId | string | <input type="checkbox"> | None | <pre>''</pre> | The unique application ID for HockeyApp integration. |
| immediatePurgeDataOn30Days | bool | <input type="checkbox"> | None | <pre>false</pre> | Purge data immediately after 30 days. |
| samplingPercentage | int? | <input type="checkbox" checked> | None | <pre></pre> | Percentage of the data produced by the application being monitored that is being sampled for Application Insights telemetry. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| appInsightsInstrumentationKey | string | The instrumentation key for this Applicaion Insights which can be used in an application. |
| appInsightsConnectionString | string | The connectionstring for this Applicaion Insights which can be used in an application. |
| appInsightsName | string | The name of the created application insights instance. |
| appInsightsResourceId | string | The Resource ID for this application insights. |

## Links
- [Bicep Application Insights Components](https://learn.microsoft.com/en-us/azure/templates/microsoft.insights/components?pivots=deployment-language-bicep)
