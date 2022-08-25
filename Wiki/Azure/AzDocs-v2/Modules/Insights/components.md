# components

Target Scope: resourceGroup

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| appInsightsName | string | <input type="checkbox" checked> | Length between 1-260 | <pre></pre> | The name of the Application Insights instance. |
| logAnalyticsWorkspaceResourceId | string | <input type="checkbox" checked> | None | <pre></pre> | The azure resource id of the Log Analytics Workspace to use as the data provider for this Application Insights. |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | The location for this Application Insights instance to be upserted in. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| appInsightsInstrumentationKey | string | The instrumentation key for this Applicaion Insights which can be used in an application. |
| appInsightsConnectionString | string | The connectionstring for this Applicaion Insights which can be used in an application. |
| appInsightsName | string | The name of the created application insights instance. |
| appInsightsResourceId | string | The Resource ID for this application insights. |

