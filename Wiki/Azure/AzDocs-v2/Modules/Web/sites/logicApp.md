# logicApp

Target Scope: resourceGroup

## Synopsis
Creating a Logic Standard Instance.

## Description
Creating a Logic Standard Instance with the given specs.<br>
Currently kind: functionapp,workflowapp does not seem to be completely supported in the webapp regarding settings appsettings using 'Microsoft.Web/sites/config@2022-03-01'.<br>
Therefore this separate bicep file.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| logicAppName | string | <input type="checkbox" checked> | Length between 2-60 | <pre></pre> | The name of the Logic app. |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location. |
| appServicePlanName | string | <input type="checkbox" checked> | Length between 1-40 | <pre></pre> | The resource name of the appserviceplan to use for this logic app. |
| appServicePlanResourceGroupName | string | <input type="checkbox" checked> | Length between 1-90 | <pre></pre> | The name of the resourcegroup where the appserviceplan resides in to use for this logic app. |
| storageAccountName | string | <input type="checkbox" checked> | Length between 3-24 | <pre></pre> | The name of the storageaccount to use as the underlying storage provider for this logic app. |
| storageAccountResourceGroupName | string | <input type="checkbox"> | Length between 1-90 | <pre>az.resourceGroup().name</pre> | The name of the resourcegroup where the storageaccount resides in to use as the underlying storage provider for this logic app. Defaults to the current resourcegroup. |
| logAnalyticsWorkspaceResourceId | string | <input type="checkbox" checked> | Length between 0-* | <pre></pre> | The azure resource id of the log analytics workspace to log the diagnostics to. If you set this to an empty string, logging & diagnostics will be disabled. |
| diagnosticsName | string | <input type="checkbox"> | Length between 1-260 | <pre>'AzurePlatformCentralizedLogging'</pre> | The name of the diagnostics. This defaults to `AzurePlatformCentralizedLogging`. |
| diagnosticSettingsLogsCategories | array | <input type="checkbox"> | None | <pre>[<br>  {<br>    categoryGroup: 'allLogs'<br>    enabled: true<br>  }<br>]</pre> | Which log categories to enable; This defaults to `allLogs`. For array/object format, please refer to [documentation](https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep#logsettings). |
| diagnosticSettingsMetricsCategories | array | <input type="checkbox"> | None | <pre>[<br>  {<br>    categoryGroup: 'AllMetrics'<br>    enabled: true<br>  }<br>]</pre> | Which Metrics categories to enable; This defaults to `AllMetrics`. For array/object format, please refer to [documentation](https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep&pivots=deployment-language-bicep#metricsettings). |
| identity | object | <input type="checkbox"> | None | <pre>{<br>  type: 'SystemAssigned'<br>}</pre> | Managed service identity to use for this logic app. Defaults to a system assigned managed identity. For object format, refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.web/sites?tabs=bicep#managedserviceidentity. |
| ipSecurityRestrictions | array | <input type="checkbox"> | None | <pre>[<br>  {<br>    ipAddress: '0.0.0.0/0'<br>    action: 'Deny'<br>    tag: 'Default'<br>    priority: 10<br>    name: 'DefaultDeny'<br>    description: 'Default deny so that something is not publicly exposed.'<br>  }<br>]</pre> | IP security restrictions for the main entrypoint. Defaults to closing down the appservice for all connections (you need to manually define this). For object format, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.web/sites?tabs=bicep#ipsecurityrestriction. |
| appSettings | array | <input type="checkbox"> | None | <pre>[<br>  {<br>    name: 'APP_KIND'<br>    value: 'workflowApp'<br>  }<br>  {<br>    name: 'AzureFunctionsJobHost__extensionBundle__id'<br>    value: 'Microsoft.Azure.Functions.ExtensionBundle.Workflows'<br>  }<br>  {<br>    name: 'WEBSITE_ENABLE_SYNC_UPDATE_SITE'<br>    value: 'true'<br>  }<br>  {<br>    name: 'FUNCTIONS_WORKER_RUNTIME'<br>    value: 'node'<br>  }<br>  {<br>    name: 'FUNCTIONS_EXTENSION_VERSION'<br>    value: '~4'<br>  }<br>  {<br>    name: 'WEBSITE_NODE_DEFAULT_VERSION'<br>    value: '~18'<br>  }<br>]</pre> | Application settings. For array/object format, refer to [the docs](https://docs.microsoft.com/en-us/azure/templates/microsoft.web/sites?tabs=bicep#namevaluepair).<br>Remark: if you want to use version 4 of the Azure Functions extension bundle, you should include the AzureFunctionsJobHost__extensionBundle__version setting with value [1.*, 2.0.0) in your configuration. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| logicAppKind | string | <input type="checkbox"> | `'kubernetes,functionapp,workflowapp,linux'` or `'functionapp,workflowapp'` | <pre>'functionapp,workflowapp'</pre> | The kind of logic app to create |
| logicAppExtendedLocation | object | <input type="checkbox"> | None | <pre>{}</pre> | For Azure Arc-enabled Logic Apps. This object requires the "name" of your custom location for your Kubernetes environment and must have the "type" set to "CustomLocation (and linuxFxVersion to Node&#124;12)".<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;name: "customLocationId'",<br>&nbsp;&nbsp;&nbsp;type: "CustomLocation"<br>}, |
| clientAffinityEnabled | bool | <input type="checkbox"> | None | <pre>true</pre> | True to enable client affinity; false to stop sending session affinity cookies, which route client requests in the same session to the same instance. Default is true. |
| httpsOnly | bool | <input type="checkbox"> | None | <pre>true</pre> | Configures a web site to accept only https requests. Issues redirect for http requests |
| logicAppKeyVaultReferenceIdentity | string | <input type="checkbox"> | None | <pre>'SystemAssigned'</pre> | Identity to use for Key Vault Reference authentication. |
| logicAppEnabledState | bool | <input type="checkbox"> | None | <pre>true</pre> | Setting this value to false disables the app (takes the app offline). |
| vnetRouteAllEnabled | bool | <input type="checkbox"> | None | <pre>true</pre> | Virtual Network `route all` enabled. This causes all outbound traffic to have Virtual Network Network Security Groups (nsg) and User Defined Routes applied. |
| alwaysOn | bool | <input type="checkbox"> | None | <pre>false</pre> | The `Always On` feature of Azure App Service, keeps the host process running.<br>This allows your site to be more responsive to request after significant idle periods.<br>Otherwise, once a request comes in, the App Service will have to cold boot and load into memory before responding to the request. |
| ftpsState | string | <input type="checkbox"> | `'AllAllowed'` or `'Disabled'` or `'FtpsOnly'` | <pre>'Disabled'</pre> | State of FTP / FTPS service |
| virtualApplications | array | <input type="checkbox"> | None | <pre>[<br>  {<br>    virtualPath: '/'<br>    physicalPath: 'site\\wwwroot'<br>    preloadEnabled: false<br>  }<br>]</pre> | The option will create Virtual Directories/Application and is only available for Azure Windows App Service. Find it in the Portal under App Service => Configuration => Path mappings => Virtual applications and directories. |
| logicAppCorsAllowedOrigins | array | <input type="checkbox"> | None | <pre>[]</pre> | Cross-Origin Resource Sharing (CORS) settings.Gets or sets the list of origins that should be allowed to make cross-origin calls,<br>for example: http://example.com:12345). Use "*" to allow all.<br>Example:<br>[<br>&nbsp;&nbsp;&nbsp;'https://afd.hosting.portal.azure.net'<br>&nbsp;&nbsp;&nbsp;'https://afd.hosting-ms.portal.azure.net'<br>&nbsp;&nbsp;&nbsp;'https://hosting.portal.azure.net'<br>&nbsp;&nbsp;&nbsp;'https://ms.hosting.portal.azure.net'<br>&nbsp;&nbsp;&nbsp;'https://ema-ms.hosting.portal.azure.net'<br>&nbsp;&nbsp;&nbsp;'https://ema.hosting.portal.azure.net'<br>] |
| logicAppNumberOfWorkers | int | <input type="checkbox"> | None | <pre>-1</pre> | If the AppServicePlan has enabled per-app scaling, you can configure the number of instances the app can use. |
| scmIpSecurityRestrictionsUseMain | bool | <input type="checkbox"> | None | <pre>true</pre> | IP security restrictions for scm to use the same settings as main. |
| http20Enabled | bool | <input type="checkbox"> | None | <pre>true</pre> | Http20Enabled: configures a web site to allow clients to connect over http2.0 |
| clientCertEnabled | bool | <input type="checkbox"> | None | <pre>false</pre> | You can restrict access to your Azure App Service app by enabling different types of authentication for it.<br>One way to do it is to request a client certificate when the client request is over TLS/SSL and validate the certificate.<br>This mechanism is called TLS mutual authentication or client certificate authentication.<br>If you put the value on true, the setting will be 'require' for the setting  `Client certificate mode`, unless determined elsewise by the clientCertMode parameter. |
| clientCertMode | string | <input type="checkbox"> | None | <pre>''</pre> | This setting is linked to the clientCertEnabled parameter.<br>ClientCertEnabled: false means ClientCert is ignored.<br>ClientCertEnabled: true and ClientCertMode: Required, means ClientCert is required.<br>ClientCertEnabled: true and ClientCertMode: Optional means ClientCert is optional or allow.<br>Example:<br>'Optional',<br>'OptionalInteractiveUser',<br>'Required' |
| connectionStrings | object | <input type="checkbox"> | None | <pre>{}</pre> | Connectionstrings. This object is a plain key/value pair.<br>Example:<br>{<br>&nbsp;&nbsp;name: 'SQLServerConnectionstring'<br>&nbsp;&nbsp;connectionString: 'thisismyv;aluefor;myfirstconnectio;nstring'<br>&nbsp;&nbsp;type: 'SQLAzure'<br>} |
| scmIpSecurityRestrictions | array | <input type="checkbox"> | None | <pre>[<br>  {<br>    ipAddress: '0.0.0.0/0'<br>    action: 'Deny'<br>    tag: 'Default'<br>    priority: 10<br>    name: 'DefaultDeny'<br>    description: 'Default deny so that nothing is publicly exposed by accident'<br>  }<br>]</pre> | SCM(kudu) IP security restrictions for the SCM entrypoint. Defaults to closing down the appservice SCM instance for all connections. For object format, please refer to [documentation](https://docs.microsoft.com/en-us/azure/templates/microsoft.web/sites?tabs=bicep#ipsecurityrestriction). |
| vNetIntegrationSubnetResourceId | string | <input type="checkbox"> | None | <pre>''</pre> | The resource id of the subnet where to integrate the appservice/webapp/logicapp/functionapp into. |
| linuxFxVersion | string | <input type="checkbox"> | None | <pre>''</pre> | Linux App Framework and version<br>Example:<br>'DOTNETCORE&#124;6.0' |
| publicNetworkAccess | string | <input type="checkbox"> | `'Enabled'` or `'Disabled'` or `''` | <pre>'Enabled'</pre> | Property to allow or block all public traffic. Allowed Values: `Enabled`, `Disabled` or an empty string. |
| appInsightsName | string | <input type="checkbox"> | Length between 0-260 | <pre>''</pre> | The name of the application insights instance to attach to this app service. If you leave this empty, no AppInsights resource will be created. |
| appInsightsResourceGroupName | string | <input type="checkbox"> | Length between 1-90 | <pre>az.resourceGroup().name</pre> | The name of the resourcegroup where the application insights instance resides in to attach to this app service. This application insights instance should be pre-existing. Defaults to the current resourcegroup. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| logicAppName | string | Output the logic app\'s resource name. |
| logicAppPrincipalId | string | Output the logic app\'s identity principal object id. |

## Examples
<pre>
module logicApp 'br:contosoregistry.azurecr.io/web/sites/logicapp:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 55), 'lappname')
  params: {
    logicAppName: logicAppName
    appServicePlanResourceGroupName: appServicePlanResourceGroupName
    storageAccountName: logicappstorage.outputs.storageAccountName
    appServicePlanName: appServicePlan.outputs.appServicePlanResourceName
    location: location
    appSettings: [
      {
        name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
        value: appInsights.outputs.appInsightsInstrumentationKey
      }
      {
        name: 'AzureFunctionsJobHost__extensionBundle__id'
        value: 'Microsoft.Azure.Functions.ExtensionBundle.Workflows'
      }
      {
        name: 'APP_KIND'
        value: 'workflowApp'
      }
      {
        name: 'WEBSITE_ENABLE_SYNC_UPDATE_SITE'
        value: 'true'
      }
      {
        name: 'FUNCTIONS_WORKER_RUNTIME'
        value: 'node'
      }
      {
        name: 'FUNCTIONS_EXTENSION_VERSION'
        value: '~4'
      }
      {
        name: 'WEBSITE_NODE_DEFAULT_VERSION'
        value: '~18'
      }
    ]
    ipSecurityRestrictions: union(homeIps, [
      {
        ipAddress: '0.0.0.0/0'
        action: 'Deny'
        tag: 'Default'
        priority: 10
        name: 'DefaultDeny'
        description: 'Default deny so that nothing is publicly exposed by accident'
      }
    ])
  }
}
</pre>
<p>Creates a logic app standard with the name 'logicAppName'</p>

## Links
- [Bicep Microsoft.Web Sites](https://learn.microsoft.com/en-us/azure/templates/microsoft.web/sites?pivots=deployment-language-bicep)<br>
- [Azure App Service Kind](https://github.com/Azure/app-service-linux-docs/blob/master/Things_You_Should_Know/kind_property.md)
