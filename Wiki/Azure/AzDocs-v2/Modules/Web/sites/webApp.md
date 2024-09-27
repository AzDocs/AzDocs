# webApp

Target Scope: resourceGroup

## User Defined Types
| Name | Type | Discriminator | Description
| -- |  -- | -- | -- |
| <a id="publicCertifcate">publicCertifcate</a>  | <pre>{</pre> |  | Public certificates for Azure App Service for example intermediate and root certificates. See https://github.com/Azure/azure-quickstart-templates/blob/master/quickstarts/microsoft.web/web-app-public-certificate/azuredeploy.json [   {     name: 'TrustedRootCertificate'     blob: 'base64 encoded public certificate file'     publicCertificateLocation: 'LocalMachineMy'   } ] | 

## Synopsis
Creating an AppService Instance: WebApp, FunctionApp etc.

## Description
Creating an AppService Instance: WebApp, FunctionApp etc. with the given specs.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. |
| appServiceName | string | <input type="checkbox" checked> | Length between 2-60 | <pre></pre> | The name of the App Service Instance. |
| appServicePlanName | string | <input type="checkbox" checked> | Length between 1-40 | <pre></pre> | The resource name of the appserviceplan to use for this App Service Instance. |
| appServicePlanResourceGroupName | string | <input type="checkbox"> | Length between 1-90 | <pre>az.resourceGroup().name</pre> | The name of the resourcegroup where the appserviceplan resides in to use for this App Service Instance. Defaults to the current resourcegroup. |
| appInsightsName | string | <input type="checkbox"> | Length between 0-260 | <pre>''</pre> | The name of the application insights instance to attach to this app service. If you leave this empty, the appsetting will not contain a referral to an AppInsights resource. |
| appInsightsResourceGroupName | string | <input type="checkbox"> | Length between 1-90 | <pre>az.resourceGroup().name</pre> | The name of the resourcegroup where the application insights instance resides in to attach to this app service. This application insights instance should be pre-existing. Defaults to the current resourcegroup. |
| identity | object | <input type="checkbox"> | None | <pre>{<br>  type: 'SystemAssigned'<br>}</pre> | Managed service identity to use for this App Service Instance. Defaults to a system assigned managed identity. For object format, refer to [documentation](https://docs.microsoft.com/en-us/azure/templates/microsoft.web/sites?tabs=bicep#managedserviceidentity). |
| appSettings | object | <input type="checkbox"> | None | <pre>{}</pre> | Application settings. This object is a plain key/value pair.<br>For example:<br>&nbsp;&nbsp;SomeSetting: 'myvalue'<br>&nbsp;&nbsp;AnotherSetting: 'Another value' |
| connectionStrings | object | <input type="checkbox"> | None | <pre>{}</pre> | Connectionstrings. This is an object with "connectionstring" objects.<br>For example:<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;MyConnectionString: {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;value: 'thisismyv;aluefor;myfirstconnectio;nstring'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;type: 'SQLAzure'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;AnotherConnectionString: {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;value: 'thisismyva;lueform;ysecond;connectionstring'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;type: 'Custom'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br>&nbsp;&nbsp;&nbsp;} |
| webAppKind | string | <input type="checkbox"> | `'api'` or `'app'` or `'app,linux'` or `'app,linux,container'` or `'hyperV'` or `'app,container,windows'` or `'app,linux,kubernetes'` or `'functionapp'` or `'functionapp,linux'` or `'functionapp,linux,kubernetes'` or `'functionapp,linux,kubernetes,container'` | <pre>'app,linux'</pre> | The type of webapp to create.<br><br>See also: https://github.com/Azure/app-service-linux-docs/blob/master/Things_You_Should_Know/kind_property.md |
| ipSecurityRestrictions | array | <input type="checkbox"> | None | <pre>[<br>  {<br>    ipAddress: '0.0.0.0/0'<br>    action: 'Deny'<br>    tag: 'Default'<br>    priority: 2147483646<br>    name: 'DefaultDeny'<br>    description: 'Default deny so that nothing is publicly exposed by accident'<br>  }<br>]</pre> | IP security restrictions for the main entrypoint. Defaults to closing down the appservice instance for all connections. For object format, please refer to [documentation](https://docs.microsoft.com/en-us/azure/templates/microsoft.web/sites?tabs=bicep#ipsecurityrestriction). |
| scmIpSecurityRestrictions | array | <input type="checkbox"> | None | <pre>[<br>  {<br>    ipAddress: '0.0.0.0/0'<br>    action: 'Deny'<br>    tag: 'Default'<br>    priority: 2147483646<br>    name: 'DefaultDeny'<br>    description: 'Default deny so that nothing is publicly exposed by accident'<br>  }<br>]</pre> | SCM(kudu) IP security restrictions for the SCM entrypoint. Defaults to closing down the appservice SCM instance for all connections. For object format, please refer to [documentation](https://docs.microsoft.com/en-us/azure/templates/microsoft.web/sites?tabs=bicep#ipsecurityrestriction). |
| keyVaultReferenceIdentity | string | <input type="checkbox"> | None | <pre>'SystemAssigned'</pre> | Identity to use for Key Vault Reference authentication. If you want to use a user assigned managed identity to access a keyvault using a keyvault reference, <br>you need to set this to the resource id of the user assigned managed identity. |
| vNetIntegrationSubnetResourceId | string | <input type="checkbox"> | None | <pre>''</pre> | The resource id of the subnet where to integrate the appservice/webapp/logicapp/functionapp into. |
| logAnalyticsWorkspaceResourceId | string | <input type="checkbox" checked> | Length between 0-* | <pre></pre> | The azure resource id of the log analytics workspace to log the diagnostics to. If you set this to an empty string, logging & diagnostics will be disabled. |
| diagnosticsName | string | <input type="checkbox"> | Length between 1-260 | <pre>'AzurePlatformCentralizedLogging'</pre> | The name of the diagnostics. This defaults to `AzurePlatformCentralizedLogging`. |
| diagnosticSettingsLogsCategories | array | <input type="checkbox"> | None | <pre>[<br>  {<br>    categoryGroup: 'allLogs'<br>    enabled: true<br>  }<br>]</pre> | Which log categories to enable; This defaults to `allLogs`. For array/object format, please refer to [documentation](https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep#logsettings). |
| diagnosticSettingsMetricsCategories | array | <input type="checkbox"> | None | <pre>[<br>  {<br>    categoryGroup: 'AllMetrics'<br>    enabled: true<br>  }<br>]</pre> | Which Metrics categories to enable; This defaults to `AllMetrics`. For array/object format, please refer to [documentation](https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep&pivots=deployment-language-bicep#metricsettings). |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs. Resource may inherit tags from the ResourceGroup instead.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| httpsOnly | bool | <input type="checkbox"> | None | <pre>true</pre> | Configures a web site to accept only https requests. Issues redirect for http requests |
| clientAffinityEnabled | bool | <input type="checkbox"> | None | <pre>true</pre> | True to enable client affinity; false to stop sending session affinity cookies, which route client requests in the same session to the same instance. Default is true. |
| vnetRouteAllEnabled | bool | <input type="checkbox"> | None | <pre>false</pre> | Virtual Network `route all` enabled. This causes all outbound traffic to have Virtual Network Network Security Groups (nsg) and User Defined Routes applied. |
| alwaysOn | bool | <input type="checkbox"> | None | <pre>true</pre> | The `Always On` feature of Azure App Service, keeps the host process running.<br>This allows your site to be more responsive to request after significant idle periods.<br>Otherwise, once a request comes in, the App Service will have to cold boot and load into memory before responding to the request. |
| scmIpSecurityRestrictionsUseMain | bool | <input type="checkbox"> | None | <pre>true</pre> | IP security restrictions for scm to use the same settings as main. |
| ftpsState | string | <input type="checkbox"> | `'AllAllowed'` or `'Disabled'` or `'FtpsOnly'` | <pre>'Disabled'</pre> | State of FTP / FTPS service |
| http20Enabled | bool | <input type="checkbox"> | None | <pre>true</pre> | Http20Enabled: configures a web site to allow clients to connect over http2.0 |
| linuxFxVersion | string | <input type="checkbox"> | None | <pre>'DOTNETCORE&#124;6.0'</pre> | Linux App Framework and version.<br>Example:<br>'DOTNET-ISOLATED&#124;8.0' |
| clientCertEnabled | bool | <input type="checkbox"> | None | <pre>false</pre> | You can restrict access to your Azure App Service app by enabling different types of authentication for it.<br>One way to do it is to request a client certificate when the client request is over TLS/SSL and validate the certificate.<br>This mechanism is called TLS mutual authentication or client certificate authentication.<br>If you put the value on true, the setting will be 'require' for the setting  `Client certificate mode`, unless determined elsewise by the clientCertMode parameter. |
| clientCertMode | string | <input type="checkbox"> | None | <pre>''</pre> | This setting is linked to the clientCertEnabled parameter.<br>ClientCertEnabled: false means ClientCert is ignored.<br>ClientCertEnabled: true and ClientCertMode: Required, means ClientCert is required.<br>ClientCertEnabled: true and ClientCertMode: Optional means ClientCert is optional or allow.<br>Example:<br>'Optional',<br>'OptionalInteractiveUser',<br>'Required' |
| publicNetworkAccess | string | <input type="checkbox"> | `'Enabled'` or `'Disabled'` or `''` | <pre>'Enabled'</pre> | Property to allow or block all public traffic. Allowed Values: `Enabled`, `Disabled` or an empty string. |
| deploySlot | bool | <input type="checkbox"> | None | <pre>true</pre> | Determine whether to deploy a staging slot in the webApp (default: true). |
| use32BitWorkerProcess | bool | <input type="checkbox"> | None | <pre>true</pre> | Use 32-bit worker process on 64-bit platform. Uses 64-bit worker process if false. Default is true (will use 32-bit). |
| cors | object | <input type="checkbox"> | None | <pre>{}</pre> | Gets or sets the list of origins that should be allowed to make cross-origin calls (for example: http://example.com:12345).<br>Use "*" to allow all in the allowedOrigins array. The wildcard (*) is ignored if there's another domain entry.<br>Info about supportCredentials: [link](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS#Requests_with_credentials)<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;allowedOrigins: [<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'https://functions.azure.com'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'https://functions-staging.azure.com'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'https://functions-next.azure.com'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'https://portal.azure.com'<br>&nbsp;&nbsp;&nbsp;]<br>&nbsp;&nbsp;&nbsp;supportCredentials: false<br>} |
| numberOfWorkers | int | <input type="checkbox"> | None | <pre>2</pre> | Number to indicate on how many instances the app will run. |
| healthCheckPath | string | <input type="checkbox"> | None | <pre>''</pre> | Relative path of the health check probe. A valid path starts with "/".<br>Example:<br>'/api/HealthCheck' |
| roleAssignments | array | <input type="checkbox"> | None | <pre>[]</pre> | Setting up roleassignments for the resource.<br>Example:<br>&nbsp;&nbsp;[<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;roleDefinitionId: 'de139f84-1756-47ae-9be6-808fbbe84772' //Website Contributor<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;principalId: '74d905df-d648-4408-9b93-9bc3261b89ef'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;principalType: 'ServicePrincipal'<br>&nbsp;&nbsp;&nbsp;}<br>] |
| netFrameworkVersion | string | <input type="checkbox"> | None | <pre>''</pre> | The .NET Framework version to set for the app. Default it is null. Get the list of supported versions by running: `az functionapp list-runtimes`.<br>Example:<br>'v8.0' |
| publicCertificates | publicCertifcate[] | <input type="checkbox"> | None | <pre>[]</pre> |  |
| minimumElasticInstanceCount | int? | <input type="checkbox" checked> | None | <pre></pre> | Number of minimum instance count for a site. This setting only applies to the Elastic Plans. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| webAppHostName | string | Output the default host name of the webapp. |
| webAppStagingSlotHostName | string | Output the default host name of the webapp\'s staging slot. |
| webAppPrincipalId | string | The principal id of the identity running this webapp |
| webAppStagingSlotPrincipalId | string | The principal id of the identity running this webapp\'s staging slot |
| webAppResourceName | string | The resource name of the webapp. |
| webAppStagingSlotResourceName | string | The resource name of the webapp\'s staging slot. |

## Examples
<pre>
module webApp 'br:contosoregistry.azurecr.io/web/sites/webapp:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 57), 'webapp')
  params: {
    appServiceName: webAppName
    roleAssignments: [
      {
        principalId: logicapp.outputs.principalId
        principalType: 'ServicePrincipal'
        roleDefinitionId: 'de139f84-1756-47ae-9be6-808fbbe84772' // website contributor
      }
    appInsightsName: appInsights.outputs.appInsightsName
    appServicePlanResourceGroupName: appServicePlanResourceGroupName
    ipSecurityRestrictions: union(homeIps, [
      {
        action: 'Allow'
        description: 'subnet'
        name: 'subnet'
        priority: 20
        tag: 'Default'
        vnetSubnetResourceId: gatewaySubnetExisting.id
      }
    ])
    appServicePlanName: appServicePlan.outputs.appServicePlanResourceName
    vNetIntegrationSubnetResourceId: vNetIntegrationSubnetResourceId
    location: location
    vnetRouteAllEnabled: true
    appSettings: {}
    connectionStrings: {}
    logAnalyticsWorkspaceResourceId: logAnalyticsWorkspaceResourceId
    minimumElasticInstanceCount: minimumElasticInstanceCount
    publicCertificates: [
      {
        name: 'TrustedRootCertificate'
        blob: 'base64 encoded public certificate file'
        publicCertificateLocation: 'LocalMachineMy'
      }
    ]
  }
}
</pre>
<p>Creates a WebApp with the name 'webAppName'</p>

## Links
- [Bicep Microsoft.Web Sites](https://learn.microsoft.com/en-us/azure/templates/microsoft.web/sites?pivots=deployment-language-bicep)<br>
- [Azure App Service Kind](https://github.com/Azure/app-service-linux-docs/blob/master/Things_You_Should_Know/kind_property.md)
