# functionAppFlexConsumption

Target Scope: resourceGroup

> [!NOTE]
> This module uses Bicep resource-derived types (`resourceInput<>` / `resourceOutput<>`).
> - [Resource-derived types](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/user-defined-data-types#resource-derived-types)
> - [Bicep data types](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/data-types)

## User Defined Types
| Name | Type | Discriminator | Description
| -- |  -- | -- | -- |
| <a id="tlsVersionType">tlsVersionType</a>  | <pre>'1.2' &#124; '1.3'</pre> |  | The TLS version to use for the app service. | 
| <a id="tlsCipherSuite">tlsCipherSuite</a>  | <pre>&nbsp;&nbsp;&nbsp;&#124; 'TLS_AES_256_GCM_SHA384'<br>&nbsp;&nbsp;&nbsp;&#124; 'TLS_AES_128_GCM_SHA256'<br>&nbsp;&nbsp;&nbsp;&#124; 'TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384'<br>&nbsp;&nbsp;&nbsp;&#124; 'TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256'<br>&nbsp;&nbsp;&nbsp;&#124; 'TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384'<br>&nbsp;&nbsp;&nbsp;&#124; 'TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256'<br>&nbsp;&nbsp;&nbsp;&#124; 'TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256'<br>&nbsp;&nbsp;&nbsp;&#124; 'TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384'<br>&nbsp;&nbsp;&nbsp;&#124; 'TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256'<br>&nbsp;&nbsp;&nbsp;&#124; 'TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA'<br>&nbsp;&nbsp;&nbsp;&#124; 'TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA'<br>&nbsp;&nbsp;&nbsp;&#124; 'TLS_RSA_WITH_AES_256_GCM_SHA384'<br>&nbsp;&nbsp;&nbsp;&#124; 'TLS_RSA_WITH_AES_128_GCM_SHA256'<br>&nbsp;&nbsp;&nbsp;&#124; 'TLS_RSA_WITH_AES_256_CBC_SHA256'<br>&nbsp;&nbsp;&nbsp;&#124; 'TLS_RSA_WITH_AES_128_CBC_SHA256'<br>&nbsp;&nbsp;&nbsp;&#124; 'TLS_RSA_WITH_AES_256_CBC_SHA'<br>&nbsp;&nbsp;&nbsp;&#124; 'TLS_RSA_WITH_AES_128_CBC_SHA'<br></pre> |  | The TLS cipher suite in order of most secure to least secure to use for the app service. | 
| <a id="flexDeploymentStorageSystemAssignedIdentity">flexDeploymentStorageSystemAssignedIdentity</a>  | <pre>{<br>&nbsp;&nbsp;&nbsp;@description('The authentication type.')<br>&nbsp;&nbsp;&nbsp;type: 'SystemAssignedIdentity'<br>}<br></pre> |  | Deployment storage authentication using the system assigned identity of the Function App. | 
| <a id="flexDeploymentStorageUserAssignedIdentity">flexDeploymentStorageUserAssignedIdentity</a>  | <pre>{<br>&nbsp;&nbsp;&nbsp;@description('The authentication type.')<br>&nbsp;&nbsp;&nbsp;type: 'UserAssignedIdentity'<br><br>&nbsp;&nbsp;&nbsp;@description('The resource id of the user assigned identity that has access to the deployment storage account.')<br>&nbsp;&nbsp;&nbsp;userAssignedIdentityResourceId: string<br>}<br></pre> |  | Deployment storage authentication using a user assigned identity. | 
| <a id="flexDeploymentStorageConnectionString">flexDeploymentStorageConnectionString</a>  | <pre>{<br>&nbsp;&nbsp;&nbsp;@description('The authentication type.')<br>&nbsp;&nbsp;&nbsp;type: 'StorageAccountConnectionString'<br><br>&nbsp;&nbsp;&nbsp;@description('The name of the app setting that contains the storage account connection string.')<br>&nbsp;&nbsp;&nbsp;storageAccountConnectionStringName: string<br>}<br></pre> |  | Deployment storage authentication using a connection string stored in an app setting. | 
| <a id="flexDeploymentStorageAuthentication">flexDeploymentStorageAuthentication</a>  | <pre>&nbsp;&nbsp;&nbsp;&#124; flexDeploymentStorageSystemAssignedIdentity<br>&nbsp;&nbsp;&nbsp;&#124; flexDeploymentStorageUserAssignedIdentity<br>&nbsp;&nbsp;&nbsp;&#124; flexDeploymentStorageConnectionString<br></pre> | type | The authentication configuration for the deployment storage of a Flex Consumption Function App. | 
| <a id="flexAlwaysReadyInstance">flexAlwaysReadyInstance</a>  | <pre>{<br>&nbsp;&nbsp;&nbsp;@description('The scale group or function name: `http`, `durable`, `blob`, or `function:MyFunction`.')<br>&nbsp;&nbsp;&nbsp;@minLength(1)<br>&nbsp;&nbsp;&nbsp;name: string<br><br>&nbsp;&nbsp;&nbsp;@description('The number of Always ready instances for this scale group or function.')<br>&nbsp;&nbsp;&nbsp;@minValue(1)<br>&nbsp;&nbsp;&nbsp;instanceCount: int<br>}<br></pre> |  | An Always Ready instance assignment for a Flex Consumption Function App. | 

## Synopsis
Creating an Azure Functions Flex Consumption Function App.

## Description
Creating an Azure Functions Flex Consumption Function App with the given runtime, deployment storage, scaling, networking, and security settings.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. |
| appServiceName | string | <input type="checkbox" checked> | Length between 2-60 | <pre></pre> | The name of the Flex Consumption Function App. |
| appServicePlanName | string | <input type="checkbox" checked> | Length between 1-40 | <pre></pre> | The resource name of the FC1 Flex Consumption plan to use for this Function App. |
| appServicePlanResourceGroupName | string | <input type="checkbox"> | Length between 1-90 | <pre>az.resourceGroup().name</pre> | The name of the resourcegroup where the appserviceplan resides in to use for this App Service Instance. Defaults to the current resourcegroup. |
| appInsightsName | string | <input type="checkbox"> | Length between 0-260 | <pre>''</pre> | The name of the application insights instance to attach to this app service. If you leave this empty, the appsetting will not contain a referral to an AppInsights resource. |
| appInsightsResourceGroupName | string | <input type="checkbox"> | Length between 1-90 | <pre>az.resourceGroup().name</pre> | The name of the resourcegroup where the application insights instance resides in to attach to this app service. This application insights instance should be pre-existing. Defaults to the current resourcegroup. |
| identity | [resourceInput<'Microsoft.Web/sites@2025-03-01'>.identity](https://learn.microsoft.com/en-us/azure/templates/microsoft.web/2025-03-01/sites?pivots=deployment-language-bicep) | <input type="checkbox"> | Schema-constrained (resource-derived type) | <pre>{<br>  type: 'SystemAssigned'<br>}</pre> | Managed service identity to use for this App Service Instance. Defaults to a system assigned managed identity. For object format, refer to [documentation](https://docs.microsoft.com/en-us/azure/templates/microsoft.web/sites?tabs=bicep#managedserviceidentity). |
| appSettings | [resourceInput<'Microsoft.Web/sites/config@2022-09-01'>.properties](https://learn.microsoft.com/en-us/azure/templates/microsoft.web/2022-09-01/sites/config?pivots=deployment-language-bicep) | <input type="checkbox"> | Schema-constrained (resource-derived type) | <pre>{}</pre> | Application settings. This object is a plain key/value pair.<br>For example:<br>&nbsp;&nbsp;SomeSetting: 'myvalue'<br>&nbsp;&nbsp;AnotherSetting: 'Another value'<br>For a Flex Consumption Function App, do not set these deprecated settings, because the platform replaces them with `functionAppConfig`: FUNCTIONS_EXTENSION_VERSION, FUNCTIONS_WORKER_RUNTIME, FUNCTIONS_WORKER_RUNTIME_VERSION, FUNCTIONS_MAX_HTTP_CONCURRENCY, WEBSITE_CONTENTAZUREFILECONNECTIONSTRING, WEBSITE_CONTENTSHARE, WEBSITE_CONTENTOVERVNET, WEBSITE_RUN_FROM_PACKAGE, WEBSITE_VNET_ROUTE_ALL, WEBSITE_MAX_DYNAMIC_APPLICATION_SCALE_OUT, WEBSITE_NODE_DEFAULT_VERSION, WEBSITE_TIME_ZONE and TZ. |
| connectionStrings | [resourceInput<'Microsoft.Web/sites/config@2022-09-01'>.properties](https://learn.microsoft.com/en-us/azure/templates/microsoft.web/2022-09-01/sites/config?pivots=deployment-language-bicep) | <input type="checkbox"> | Schema-constrained (resource-derived type) | <pre>{}</pre> | Connectionstrings. This is an object with "connectionstring" objects.<br>For example:<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;MyConnectionString: {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;value: 'thisismyv;aluefor;myfirstconnectio;nstring'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;type: 'SQLAzure'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;AnotherConnectionString: {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;value: 'thisismyva;lueform;ysecond;connectionstring'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;type: 'Custom'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br>&nbsp;&nbsp;&nbsp;} |
| ipSecurityRestrictions | [resourceInput<'Microsoft.Web/sites@2025-03-01'>.properties.siteConfig.ipSecurityRestrictions](https://learn.microsoft.com/en-us/azure/templates/microsoft.web/2025-03-01/sites?pivots=deployment-language-bicep) | <input type="checkbox"> | Schema-constrained (resource-derived type) | <pre>[<br>  {<br>    ipAddress: '0.0.0.0/0'<br>    action: 'Deny'<br>    tag: 'Default'<br>    priority: 2147483646<br>    name: 'DefaultDeny'<br>    description: 'Default deny so that nothing is publicly exposed by accident'<br>  }<br>]</pre> | IP security restrictions for the main entrypoint. Defaults to closing down the appservice instance for all connections. For object format, please refer to [documentation](https://docs.microsoft.com/en-us/azure/templates/microsoft.web/sites?tabs=bicep#ipsecurityrestriction). |
| scmIpSecurityRestrictions | [resourceInput<'Microsoft.Web/sites@2025-03-01'>.properties.siteConfig.scmIpSecurityRestrictions](https://learn.microsoft.com/en-us/azure/templates/microsoft.web/2025-03-01/sites?pivots=deployment-language-bicep) | <input type="checkbox"> | Schema-constrained (resource-derived type) | <pre>[<br>  {<br>    ipAddress: '0.0.0.0/0'<br>    action: 'Deny'<br>    tag: 'Default'<br>    priority: 2147483646<br>    name: 'DefaultDeny'<br>    description: 'Default deny so that nothing is publicly exposed by accident'<br>  }<br>]</pre> | SCM(kudu) IP security restrictions for the SCM entrypoint. Defaults to closing down the appservice SCM instance for all connections. For object format, please refer to [documentation](https://docs.microsoft.com/en-us/azure/templates/microsoft.web/sites?tabs=bicep#ipsecurityrestriction). |
| keyVaultReferenceIdentity | string | <input type="checkbox"> | None | <pre>'SystemAssigned'</pre> | Identity to use for Key Vault Reference authentication. If you want to use a user assigned managed identity to access a keyvault using a keyvault reference, <br>you need to set this to the resource id of the user assigned managed identity. |
| vNetIntegrationSubnetResourceId | string | <input type="checkbox"> | None | <pre>''</pre> | The resource id of the subnet where to integrate the appservice/webapp/logicapp/functionapp into. |
| logAnalyticsWorkspaceResourceId | string | <input type="checkbox" checked> | Length between 0-* | <pre></pre> | The azure resource id of the log analytics workspace to log the diagnostics to. If you set this to an empty string, logging & diagnostics will be disabled. |
| diagnosticsName | string | <input type="checkbox"> | Length between 1-260 | <pre>'AzurePlatformCentralizedLogging'</pre> | The name of the diagnostics. This defaults to `AzurePlatformCentralizedLogging`. |
| diagnosticSettingsLogsCategories | [resourceInput<'Microsoft.Insights/diagnosticSettings@2021-05-01-preview'>.properties.logs](https://learn.microsoft.com/en-us/azure/templates/microsoft.insights/2021-05-01-preview/diagnosticsettings?pivots=deployment-language-bicep) | <input type="checkbox"> | Schema-constrained (resource-derived type) | <pre>[<br>  {<br>    categoryGroup: 'allLogs'<br>    enabled: true<br>  }<br>]</pre> | Which log categories to enable; This defaults to `allLogs`. For array/object format, please refer to [documentation](https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep#logsettings). |
| diagnosticSettingsMetricsCategories | [resourceInput<'Microsoft.Insights/diagnosticSettings@2021-05-01-preview'>.properties.metrics](https://learn.microsoft.com/en-us/azure/templates/microsoft.insights/2021-05-01-preview/diagnosticsettings?pivots=deployment-language-bicep) | <input type="checkbox"> | Schema-constrained (resource-derived type) | <pre>[<br>  {<br>    category: 'AllMetrics'<br>    enabled: true<br>  }<br>]</pre> | Which Metrics categories to enable; This defaults to `AllMetrics`. For array/object format, please refer to [documentation](https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep&pivots=deployment-language-bicep#metricsettings). |
| tags | [resourceInput<'Microsoft.Web/sites@2025-03-01'>.tags](https://learn.microsoft.com/en-us/azure/templates/microsoft.web/2025-03-01/sites?pivots=deployment-language-bicep) | <input type="checkbox"> | Schema-constrained (resource-derived type) | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs. Resource may inherit tags from the ResourceGroup instead.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| httpsOnly | bool | <input type="checkbox"> | None | <pre>true</pre> | Configures a web site to accept only https requests. Issues redirect for http requests |
| clientAffinityEnabled | bool | <input type="checkbox"> | None | <pre>true</pre> | True to enable client affinity; false to stop sending session affinity cookies, which route client requests in the same session to the same instance. Default is true. |
| clientAffinityProxyEnabled | bool | <input type="checkbox"> | None | <pre>false</pre> | True to override client affinity cookie domain with X-Forwarded-Host request header. False to use default domain. Default is false. |
| scmIpSecurityRestrictionsUseMain | bool | <input type="checkbox"> | None | <pre>true</pre> | IP security restrictions for scm to use the same settings as main. |
| http20Enabled | bool | <input type="checkbox"> | None | <pre>true</pre> | Http20Enabled: configures a web site to allow clients to connect over http2.0 |
| clientCertEnabled | bool | <input type="checkbox"> | None | <pre>false</pre> | You can restrict access to your Azure App Service app by enabling different types of authentication for it.<br>One way to do it is to request a client certificate when the client request is over TLS/SSL and validate the certificate.<br>This mechanism is called TLS mutual authentication or client certificate authentication.<br>If you put the value on true, the setting will be 'require' for the setting  `Client certificate mode`, unless determined elsewise by the clientCertMode parameter. |
| clientCertMode | string | <input type="checkbox"> | None | <pre>''</pre> | This setting is linked to the clientCertEnabled parameter.<br>ClientCertEnabled: false means ClientCert is ignored.<br>ClientCertEnabled: true and ClientCertMode: Required, means ClientCert is required.<br>ClientCertEnabled: true and ClientCertMode: Optional means ClientCert is optional or allow.<br>Example:<br>'Optional',<br>'OptionalInteractiveUser',<br>'Required' |
| publicNetworkAccess | string | <input type="checkbox"> | `'Enabled'` or `'Disabled'` or `''` | <pre>'Enabled'</pre> | Property to allow or block all public traffic. Allowed Values: `Enabled`, `Disabled` or an empty string. |
| cors | [resourceInput<'Microsoft.Web/sites@2025-03-01'>.properties.siteConfig.cors](https://learn.microsoft.com/en-us/azure/templates/microsoft.web/2025-03-01/sites?pivots=deployment-language-bicep) | <input type="checkbox"> | Schema-constrained (resource-derived type) | <pre>{}</pre> | Gets or sets the list of origins that should be allowed to make cross-origin calls (for example: http://example.com:12345).<br>Use "*" to allow all in the allowedOrigins array. The wildcard (*) is ignored if there's another domain entry.<br>Info about supportCredentials: [link](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS#Requests_with_credentials)<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;allowedOrigins: [<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'https://functions.azure.com'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'https://functions-staging.azure.com'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'https://functions-next.azure.com'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'https://portal.azure.com'<br>&nbsp;&nbsp;&nbsp;]<br>&nbsp;&nbsp;&nbsp;supportCredentials: false<br>} |
| healthCheckPath | string | <input type="checkbox"> | None | <pre>''</pre> | Relative path of the health check probe. A valid path starts with "/".<br>Example:<br>'/api/HealthCheck' |
| roleAssignments | [resourceInput<'Microsoft.Authorization/roleAssignments@2020-10-01-preview'>.properties](https://learn.microsoft.com/en-us/azure/templates/microsoft.authorization/2020-10-01-preview/roleassignments?pivots=deployment-language-bicep)[] | <input type="checkbox"> | Schema-constrained (resource-derived type) | <pre>[]</pre> | Setting up roleassignments for the resource.<br>Example:<br>&nbsp;&nbsp;[<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;roleDefinitionId: 'de139f84-1756-47ae-9be6-808fbbe84772' //Website Contributor<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;principalId: '74d905df-d648-4408-9b93-9bc3261b89ef'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;principalType: 'ServicePrincipal'<br>&nbsp;&nbsp;&nbsp;}<br>] |
| webSocketsEnabled | bool | <input type="checkbox"> | None | <pre>false</pre> | Determine whether to enable WebSockets for app (default: false). |
| tlsVersion | [tlsVersionType](#tlsVersionType) | <input type="checkbox"> | None | <pre>'1.3'</pre> | The TLS version to use for the app service. |
| minTlsCipherSuite | [tlsCipherSuite](#tlsCipherSuite) | <input type="checkbox"> | None | <pre>'TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256'</pre> | The TLS cipher suite in order of most secure to least secure to use for the app service. |
| runtimeName | string | <input type="checkbox"> | `'custom'` or `'dotnet-isolated'` or `'go'` or `'java'` or `'node'` or `'powershell'` or `'python'` | <pre>'dotnet-isolated'</pre> | The runtime stack for the Flex Consumption Function App. Defaults to `dotnet-isolated`. |
| runtimeVersion | string | <input type="checkbox"> | None | <pre>''</pre> | The runtime version for the Flex Consumption Function App. This is required and must match `runtimeName`.<br>Supported versions at the time of writing: dotnet-isolated 8.0, 9.0 and 10.0; node 22 and 24; python 3.10 to 3.14; java 8, 11, 17, 21 and 25; powershell 7.4; custom 1.0. |
| deploymentStorageBlobContainerUri | string | <input type="checkbox"> | None | <pre>''</pre> | The blob container URI that stores deployment packages for the Flex Consumption Function App. |
| deploymentStorageAuthentication | [flexDeploymentStorageAuthentication](#flexDeploymentStorageAuthentication) | <input type="checkbox"> | None | <pre>{<br>  type: 'SystemAssignedIdentity'<br>}</pre> | The authentication configuration used by a Flex Consumption Function App to access deployment storage. With `SystemAssignedIdentity` or `UserAssignedIdentity`, the identity needs a blob data role on the storage account. Defaults to the system assigned identity. |
| billingMode | string | <input type="checkbox"> | `'Always ready'` or `'On Demand'` | <pre>'On Demand'</pre> | The billing mode for a Flex Consumption Function App. On Demand scales to zero; Always ready keeps the configured trigger groups or functions warm and incurs baseline charges. |
| alwaysReadyInstances | [flexAlwaysReadyInstance](#flexAlwaysReadyInstance)[] | <input type="checkbox"> | None | <pre>[<br>  {<br>    name: 'http'<br>    instanceCount: 1<br>  }<br>]</pre> | Always Ready instance assignments for a Flex Consumption Function App. Names can be `http`, `durable`, `blob`, or `function:MyFunction`. Used when billing mode is Always ready; ignored for On Demand. When the App Service plan is zone redundant, each entry needs an instance count of at least 2. |
| maximumInstanceCount | int | <input type="checkbox"> | Value between 1-1000 | <pre>100</pre> | The maximum on-demand instance count for each scale group in a Flex Consumption Function App. Accepted values are 1 through 1000. |
| instanceMemoryMB | int | <input type="checkbox"> | `512` or `2048` or `4096` | <pre>2048</pre> | The memory size in MB for each Flex Consumption instance. Accepted values are 512, 2048, and 4096. |
| httpPerInstanceConcurrency | int | <input type="checkbox"> | Value between 0-* | <pre>0</pre> | The maximum number of concurrent HTTP requests per Flex Consumption instance. Set to 0 to let Azure select a default based on instance memory. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| webAppHostName | string | Output the default host name of the Flex Consumption Function App. |
| webAppPrincipalId | string | The principal id of the identity running this Flex Consumption Function App. |
| webAppResourceName | string | The resource name of the Flex Consumption Function App. |
| webAppResourceId | string | The resource id of the Flex Consumption Function App. |

## Examples
<pre>
module functionApp 'br:contosoregistry.azurecr.io/web/sites/functionappflexconsumption:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 52), 'functionapp')
  params: {
    appServiceName: functionAppName
    appServicePlanName: flexConsumptionPlan.outputs.appServicePlanResourceName
    roleAssignments: [
      {
        principalId: logicapp.outputs.principalId
        principalType: 'ServicePrincipal'
        roleDefinitionId: 'de139f84-1756-47ae-9be6-808fbbe84772' // website contributor
      }
    ]
    appInsightsName: appInsights.outputs.appInsightsName
    vNetIntegrationSubnetResourceId: vNetIntegrationSubnetResourceId
    location: location
    appSettings: {}
    connectionStrings: {}
    logAnalyticsWorkspaceResourceId: logAnalyticsWorkspaceResourceId
    runtimeName: 'dotnet-isolated'
    runtimeVersion: '8.0'
    deploymentStorageBlobContainerUri: deploymentStorageBlobContainerUri
    billingMode: 'Always ready'
    alwaysReadyInstances: [
      {
        name: 'http'
        instanceCount: 1
      }
    ]
    logAnalyticsWorkspaceResourceId: logAnalyticsWorkspaceResourceId
  }
}
</pre>
<p>Flex Consumption notes:</p>
<ul>
<li>A Flex Consumption plan supports one app only.</li>
<li>With the default `SystemAssignedIdentity` deployment storage authentication, grant the app identity a blob data role (for example Storage Blob Data Owner) on the deployment storage account. This module does not assign it.</li>
<li>VNet integration needs the `Microsoft.App` resource provider registered and a subnet delegated to `Microsoft.App/environments`.</li>
<li>When the plan is zone redundant, configure at least two Always ready instances per group.</li>
<li>Flex Consumption is not available in every region.</li>
</ul>

## Links
- [Bicep Microsoft.Web Sites](https://learn.microsoft.com/en-us/azure/templates/microsoft.web/sites?pivots=deployment-language-bicep)<br>
- [Azure Functions Flex Consumption](https://learn.microsoft.com/en-us/azure/azure-functions/flex-consumption-plan)<br>
- [Azure App Service Kind](https://github.com/Azure/app-service-linux-docs/blob/master/Things_You_Should_Know/kind_property.md)
