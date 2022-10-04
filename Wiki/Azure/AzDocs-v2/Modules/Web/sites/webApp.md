# webApp

Target Scope: resourceGroup

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location. |
| appServiceName | string | <input type="checkbox" checked> | Length between 2-60 | <pre></pre> | The name of the App Service app. |
| appServicePlanName | string | <input type="checkbox" checked> | Length between 1-40 | <pre></pre> | The resource name of the appserviceplan to use for this logic app. |
| appServicePlanResourceGroupName | string | <input type="checkbox"> | Length between 1-90 | <pre>az.resourceGroup().name</pre> | The name of the resourcegroup where the appserviceplan resides in to use for this logic app. Defaults to the current resourcegroup. |
| appInsightsName | string | <input type="checkbox"> | Length between 1-260 | <pre>''</pre> | The name of the application insights instance to attach to this app service. This App Insights instance should be pre-existing. |
| appInsightsResourceGroupName | string | <input type="checkbox"> | Length between 1-90 | <pre>az.resourceGroup().name</pre> | The name of the resourcegroup where the application insights instance resides in to attach to this app service. This App Insights instance should be pre-existing. Defaults to the current resourcegroup. |
| identity | object | <input type="checkbox"> | None | <pre>{<br>  type: 'SystemAssigned'<br>}</pre> | Managed service identity to use for this logic app. Defaults to a system assigned managed identity. For object format, refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.web/sites?tabs=bicep#managedserviceidentity. |
| appSettings | object | <input type="checkbox"> | None | <pre>{}</pre> | Application settings. This object is a plain key/value pair.<br>For example:<br>&nbsp;&nbsp;SomeSetting: 'myvalue'<br>&nbsp;&nbsp;AnotherSetting: 'Another value' |
| connectionStrings | object | <input type="checkbox"> | None | <pre>{}</pre> | Connectionstrings. This object is a plain key/value pair.<br>For example:<br>&nbsp;&nbsp;MyConnectionString: 'thisismyv;aluefor;myfirstconnectio;nstring'<br>&nbsp;&nbsp;AnotherConnectionString: 'thisismyva;lueform;ysecond;connectionstring' |
| webAppKind | string | <input type="checkbox"> | `'api'` or  `'app'` or  `'app,linux'` or  `'functionapp'` or  `'functionapp,linux'` | <pre>'app,linux'</pre> | The type of webapp to create. Options are:<br>&nbsp;&nbsp;&nbsp;'api' --> API App<br>&nbsp;&nbsp;&nbsp;'app' --> Windows WebApp<br>&nbsp;&nbsp;&nbsp;'app,linux' --> Linux WebApp<br>&nbsp;&nbsp;&nbsp;'functionapp' --> Windows FunctionApp<br>&nbsp;&nbsp;&nbsp;'functionapp,linux' --> Linux FunctionApp. |
| ipSecurityRestrictions | array | <input type="checkbox"> | None | <pre>[<br>  {<br>    ipAddress: '0.0.0.0/0'<br>    action: 'Deny'<br>    tag: 'Default'<br>    priority: 10<br>    name: 'DefaultDeny'<br>    description: 'Default deny to make sure that something isnt publicly exposed on accident.'<br>  }<br>]</pre> | IP security restrictions for the main entrypoint. Defaults to closing down the appservice for all connections (you need to manually define this). For object format, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.web/sites?tabs=bicep#ipsecurityrestriction. |
| vNetIntegrationSubnetResourceId | string | <input type="checkbox"> | None | <pre>''</pre> | The resource id of the subnet where to integrate the appservice/webapp/logicapp/functionapp into. |
| logAnalyticsWorkspaceResourceId | string | <input type="checkbox" checked> | Length between 0-* | <pre></pre> | The azure resource id of the log analytics workspace to log the diagnostics to. If you set this to an empty string, logging & diagnostics will be disabled. |
| diagnosticsName | string | <input type="checkbox"> | Length between 1-260 | <pre>'AzurePlatformCentralizedLogging'</pre> | The name of the diagnostics. This defaults to `AzurePlatformCentralizedLogging`. |
| diagnosticSettingsLogsCategories | array | <input type="checkbox"> | None | <pre>[<br>  {<br>    categoryGroup: 'allLogs'<br>    enabled: true<br>  }<br>]</pre> | Which log categories to enable; This defaults to `allLogs`. For array/object format, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep#logsettings. |
| diagnosticSettingsMetricsCategories | array | <input type="checkbox"> | None | <pre>[<br>  {<br>    categoryGroup: 'AllMetrics'<br>    enabled: true<br>  }<br>]</pre> | Which Metrics categories to enable; This defaults to `AllMetrics`. For array/object format, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep&pivots=deployment-language-bicep#metricsettings |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| webAppHostName | string | Output the default host name of the webapp. |
| webAppStagingSlotHostName | string | Output the default host name of the webapp\'s staging slot. |
| webAppPrincipalId | string | The principal id of the identity running this webapp |
| webAppStagingSlotPrincipalId | string | The principal id of the identity running this webapp\'s staging slot |
| webAppResourceName | string | The resource name of the webapp. |
| webAppStagingSlotResourceName | string | The resource name of the webapp\'s staging slot. |

