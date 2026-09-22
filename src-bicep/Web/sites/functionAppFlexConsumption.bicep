/*
.SYNOPSIS
Creating an Azure Functions Flex Consumption Function App.
.DESCRIPTION
Creating an Azure Functions Flex Consumption Function App with the given runtime, deployment storage, scaling, networking, and security settings.
.EXAMPLE
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
.LINKS
- [Bicep Microsoft.Web Sites](https://learn.microsoft.com/en-us/azure/templates/microsoft.web/sites?pivots=deployment-language-bicep)
- [Azure Functions Flex Consumption](https://learn.microsoft.com/en-us/azure/azure-functions/flex-consumption-plan)
- [Azure App Service Kind](https://github.com/Azure/app-service-linux-docs/blob/master/Things_You_Should_Know/kind_property.md)
*/

// ================================================= Parameters =================================================
@description('Specifies the Azure location where the resource should be created.')
param location string = resourceGroup().location

@description('The name of the Flex Consumption Function App.')
@minLength(2)
@maxLength(60)
param appServiceName string

@description('The resource name of the FC1 Flex Consumption plan to use for this Function App.')
@minLength(1)
@maxLength(40)
param appServicePlanName string

@description('The name of the resourcegroup where the appserviceplan resides in to use for this App Service Instance. Defaults to the current resourcegroup.')
@minLength(1)
@maxLength(90)
param appServicePlanResourceGroupName string = az.resourceGroup().name

@description('The name of the application insights instance to attach to this app service. If you leave this empty, the appsetting will not contain a referral to an AppInsights resource.')
@maxLength(260)
param appInsightsName string = ''

@description('The name of the resourcegroup where the application insights instance resides in to attach to this app service. This application insights instance should be pre-existing. Defaults to the current resourcegroup.')
@minLength(1)
@maxLength(90)
param appInsightsResourceGroupName string = az.resourceGroup().name

@description('Managed service identity to use for this App Service Instance. Defaults to a system assigned managed identity. For object format, refer to [documentation](https://docs.microsoft.com/en-us/azure/templates/microsoft.web/sites?tabs=bicep#managedserviceidentity).')
param identity resourceInput<'Microsoft.Web/sites@2025-03-01'>.identity = {
  type: 'SystemAssigned'
}

@description('''
Application settings. This object is a plain key/value pair.
For example:
 SomeSetting: 'myvalue'
 AnotherSetting: 'Another value'
For a Flex Consumption Function App, do not set these deprecated settings, because the platform replaces them with `functionAppConfig`: FUNCTIONS_EXTENSION_VERSION, FUNCTIONS_WORKER_RUNTIME, FUNCTIONS_WORKER_RUNTIME_VERSION, FUNCTIONS_MAX_HTTP_CONCURRENCY, WEBSITE_CONTENTAZUREFILECONNECTIONSTRING, WEBSITE_CONTENTSHARE, WEBSITE_CONTENTOVERVNET, WEBSITE_RUN_FROM_PACKAGE, WEBSITE_VNET_ROUTE_ALL, WEBSITE_MAX_DYNAMIC_APPLICATION_SCALE_OUT, WEBSITE_NODE_DEFAULT_VERSION, WEBSITE_TIME_ZONE and TZ.
''')
param appSettings resourceInput<'Microsoft.Web/sites/config@2022-09-01'>.properties = {}

@description('''
Connectionstrings. This is an object with "connectionstring" objects.
For example:
  {
    MyConnectionString: {
      value: 'thisismyv;aluefor;myfirstconnectio;nstring'
      type: 'SQLAzure'
    }
    AnotherConnectionString: {
      value: 'thisismyva;lueform;ysecond;connectionstring'
      type: 'Custom'
    }
  }
''')
param connectionStrings resourceInput<'Microsoft.Web/sites/config@2022-09-01'>.properties = {}

@description('IP security restrictions for the main entrypoint. Defaults to closing down the appservice instance for all connections. For object format, please refer to [documentation](https://docs.microsoft.com/en-us/azure/templates/microsoft.web/sites?tabs=bicep#ipsecurityrestriction).')
param ipSecurityRestrictions resourceInput<'Microsoft.Web/sites@2025-03-01'>.properties.siteConfig.ipSecurityRestrictions = [
  {
    ipAddress: '0.0.0.0/0'
    action: 'Deny'
    tag: 'Default'
    priority: 2147483646
    name: 'DefaultDeny'
    description: 'Default deny so that nothing is publicly exposed by accident'
  }
]

@description('SCM(kudu) IP security restrictions for the SCM entrypoint. Defaults to closing down the appservice SCM instance for all connections. For object format, please refer to [documentation](https://docs.microsoft.com/en-us/azure/templates/microsoft.web/sites?tabs=bicep#ipsecurityrestriction).')
param scmIpSecurityRestrictions resourceInput<'Microsoft.Web/sites@2025-03-01'>.properties.siteConfig.scmIpSecurityRestrictions = [
  {
    ipAddress: '0.0.0.0/0'
    action: 'Deny'
    tag: 'Default'
    priority: 2147483646
    name: 'DefaultDeny'
    description: 'Default deny so that nothing is publicly exposed by accident'
  }
]

@description('''
Identity to use for Key Vault Reference authentication. If you want to use a user assigned managed identity to access a keyvault using a keyvault reference, 
you need to set this to the resource id of the user assigned managed identity.
''')
param keyVaultReferenceIdentity string = 'SystemAssigned'

@description('The resource id of the subnet where to integrate the appservice/webapp/logicapp/functionapp into.')
param vNetIntegrationSubnetResourceId string = ''

@description('The azure resource id of the log analytics workspace to log the diagnostics to. If you set this to an empty string, logging & diagnostics will be disabled.')
@minLength(0)
param logAnalyticsWorkspaceResourceId string

@description('The name of the diagnostics. This defaults to `AzurePlatformCentralizedLogging`.')
@minLength(1)
@maxLength(260)
param diagnosticsName string = 'AzurePlatformCentralizedLogging'

@description('Which log categories to enable; This defaults to `allLogs`. For array/object format, please refer to [documentation](https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep#logsettings).')
param diagnosticSettingsLogsCategories resourceInput<'Microsoft.Insights/diagnosticSettings@2021-05-01-preview'>.properties.logs = [
  {
    categoryGroup: 'allLogs'
    enabled: true
  }
]

@description('Which Metrics categories to enable; This defaults to `AllMetrics`. For array/object format, please refer to [documentation](https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep&pivots=deployment-language-bicep#metricsettings).')
param diagnosticSettingsMetricsCategories resourceInput<'Microsoft.Insights/diagnosticSettings@2021-05-01-preview'>.properties.metrics = [
  {
    category: 'AllMetrics'
    enabled: true
  }
]

@description('''
The tags to apply to this resource. This is an object with key/value pairs. Resource may inherit tags from the ResourceGroup instead.
Example:
{
  FirstTag: myvalue
  SecondTag: another value
}
''')
param tags resourceInput<'Microsoft.Web/sites@2025-03-01'>.tags = {}

@description('Configures a web site to accept only https requests. Issues redirect for http requests')
param httpsOnly bool = true

@description('True to enable client affinity; false to stop sending session affinity cookies, which route client requests in the same session to the same instance. Default is true.')
param clientAffinityEnabled bool = true

@description('True to override client affinity cookie domain with X-Forwarded-Host request header. False to use default domain. Default is false.')
param clientAffinityProxyEnabled bool = false

@description('IP security restrictions for scm to use the same settings as main.')
param scmIpSecurityRestrictionsUseMain bool = true

@description('Http20Enabled: configures a web site to allow clients to connect over http2.0')
param http20Enabled bool = true

@description('''
You can restrict access to your Azure App Service app by enabling different types of authentication for it.
One way to do it is to request a client certificate when the client request is over TLS/SSL and validate the certificate.
This mechanism is called TLS mutual authentication or client certificate authentication.
If you put the value on true, the setting will be 'require' for the setting  `Client certificate mode`, unless determined elsewise by the clientCertMode parameter.
''')
param clientCertEnabled bool = false

@description('''
This setting is linked to the clientCertEnabled parameter.
ClientCertEnabled: false means ClientCert is ignored.
ClientCertEnabled: true and ClientCertMode: Required, means ClientCert is required.
ClientCertEnabled: true and ClientCertMode: Optional means ClientCert is optional or allow.
Example:
'Optional',
'OptionalInteractiveUser',
'Required'
''')
param clientCertMode string = ''

@description('Property to allow or block all public traffic. Allowed Values: `Enabled`, `Disabled` or an empty string.')
@allowed([
  'Enabled'
  'Disabled'
  ''
])
param publicNetworkAccess string = 'Enabled'

@description('''
Gets or sets the list of origins that should be allowed to make cross-origin calls (for example: http://example.com:12345).
Use "*" to allow all in the allowedOrigins array. The wildcard (*) is ignored if there's another domain entry.
Info about supportCredentials: [link](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS#Requests_with_credentials)
Example:
{
  allowedOrigins: [
    'https://functions.azure.com'
    'https://functions-staging.azure.com'
    'https://functions-next.azure.com'
    'https://portal.azure.com'
  ]
  supportCredentials: false
}
''')
param cors resourceInput<'Microsoft.Web/sites@2025-03-01'>.properties.siteConfig.cors = {}

@description('''
Relative path of the health check probe. A valid path starts with "/".
Example:
'/api/HealthCheck'
''')
param healthCheckPath string = ''

@description('''
Setting up roleassignments for the resource.
Example:
 [
  {
    roleDefinitionId: 'de139f84-1756-47ae-9be6-808fbbe84772' //Website Contributor
    principalId: '74d905df-d648-4408-9b93-9bc3261b89ef'
    principalType: 'ServicePrincipal'
  }
]
''')
param roleAssignments resourceInput<'Microsoft.Authorization/roleAssignments@2020-10-01-preview'>.properties[] = []

@description('Determine whether to enable WebSockets for app (default: false).')
param webSocketsEnabled bool = false

@description('The TLS version to use for the app service.')
type tlsVersionType = '1.2' | '1.3'

@description('The TLS version to use for the app service.')
param tlsVersion tlsVersionType = '1.3'

@description('The TLS cipher suite in order of most secure to least secure to use for the app service.')
type tlsCipherSuite =
  | 'TLS_AES_256_GCM_SHA384'
  | 'TLS_AES_128_GCM_SHA256'
  | 'TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384'
  | 'TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256'
  | 'TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384'
  | 'TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256'
  | 'TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256'
  | 'TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384'
  | 'TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256'
  | 'TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA'
  | 'TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA'
  | 'TLS_RSA_WITH_AES_256_GCM_SHA384'
  | 'TLS_RSA_WITH_AES_128_GCM_SHA256'
  | 'TLS_RSA_WITH_AES_256_CBC_SHA256'
  | 'TLS_RSA_WITH_AES_128_CBC_SHA256'
  | 'TLS_RSA_WITH_AES_256_CBC_SHA'
  | 'TLS_RSA_WITH_AES_128_CBC_SHA'

@description('The TLS cipher suite in order of most secure to least secure to use for the app service.')
param minTlsCipherSuite tlsCipherSuite = 'TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256'

@description('Deployment storage authentication using the system assigned identity of the Function App.')
type flexDeploymentStorageSystemAssignedIdentity = {
  @description('The authentication type.')
  type: 'SystemAssignedIdentity'
}

@description('Deployment storage authentication using a user assigned identity.')
type flexDeploymentStorageUserAssignedIdentity = {
  @description('The authentication type.')
  type: 'UserAssignedIdentity'

  @description('The resource id of the user assigned identity that has access to the deployment storage account.')
  userAssignedIdentityResourceId: string
}

@description('Deployment storage authentication using a connection string stored in an app setting.')
type flexDeploymentStorageConnectionString = {
  @description('The authentication type.')
  type: 'StorageAccountConnectionString'

  @description('The name of the app setting that contains the storage account connection string.')
  storageAccountConnectionStringName: string
}

@description('The authentication configuration for the deployment storage of a Flex Consumption Function App.')
@discriminator('type')
type flexDeploymentStorageAuthentication =
  | flexDeploymentStorageSystemAssignedIdentity
  | flexDeploymentStorageUserAssignedIdentity
  | flexDeploymentStorageConnectionString

@description('An Always Ready instance assignment for a Flex Consumption Function App.')
type flexAlwaysReadyInstance = {
  @description('The scale group or function name: `http`, `durable`, `blob`, or `function:MyFunction`.')
  @minLength(1)
  name: string

  @description('The number of Always ready instances for this scale group or function.')
  @minValue(1)
  instanceCount: int
}

@description('The runtime stack for the Flex Consumption Function App. Defaults to `dotnet-isolated`.')
@allowed([
  'custom'
  'dotnet-isolated'
  'go'
  'java'
  'node'
  'powershell'
  'python'
])
param runtimeName string = 'dotnet-isolated'

@description('''
The runtime version for the Flex Consumption Function App. This is required and must match `runtimeName`.
Supported versions at the time of writing: dotnet-isolated 8.0, 9.0 and 10.0; node 22 and 24; python 3.10 to 3.14; java 8, 11, 17, 21 and 25; powershell 7.4; custom 1.0.
''')
param runtimeVersion string = ''

@description('The blob container URI that stores deployment packages for the Flex Consumption Function App.')
param deploymentStorageBlobContainerUri string = ''

@description('The authentication configuration used by a Flex Consumption Function App to access deployment storage. With `SystemAssignedIdentity` or `UserAssignedIdentity`, the identity needs a blob data role on the storage account. Defaults to the system assigned identity.')
param deploymentStorageAuthentication flexDeploymentStorageAuthentication = {
  type: 'SystemAssignedIdentity'
}

@description('The billing mode for a Flex Consumption Function App. On Demand scales to zero; Always ready keeps the configured trigger groups or functions warm and incurs baseline charges.')
@allowed([
  'Always ready'
  'On Demand'
])
param billingMode string = 'On Demand'

@description('Always Ready instance assignments for a Flex Consumption Function App. Names can be `http`, `durable`, `blob`, or `function:MyFunction`. Used when billing mode is Always ready; ignored for On Demand. When the App Service plan is zone redundant, each entry needs an instance count of at least 2.')
param alwaysReadyInstances flexAlwaysReadyInstance[] = [
  {
    name: 'http'
    instanceCount: 1
  }
]

@description('The maximum on-demand instance count for each scale group in a Flex Consumption Function App. Accepted values are 1 through 1000.')
@minValue(1)
@maxValue(1000)
param maximumInstanceCount int = 100

@description('The memory size in MB for each Flex Consumption instance. Accepted values are 512, 2048, and 4096.')
@allowed([
  512
  2048
  4096
])
param instanceMemoryMB int = 2048

@description('The maximum number of concurrent HTTP requests per Flex Consumption instance. Set to 0 to let Azure select a default based on instance memory.')
@minValue(0)
param httpPerInstanceConcurrency int = 0

// ================================================= Resources =================================================
@description('Fetch the app service plan to be used for this appservice instance. This app service plan should be pre-existing.')
resource appServicePlan 'Microsoft.Web/serverfarms@2025-03-01' existing = {
  scope: az.resourceGroup(appServicePlanResourceGroupName)
  name: appServicePlanName
}

@description('Fetch the application insights instance. This application insights instance should be pre-existing.')
resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = if (!empty(appInsightsName)) {
  scope: az.resourceGroup(appInsightsResourceGroupName)
  name: !empty(appInsightsName) ? appInsightsName : 'donotuse' // in order to prevent a pre-validation error, fill in a dummy value
}

@description('''
Unify the user-defined settings with the internal settings (for example for auto-configuring Application Insights).
[link](https://learn.microsoft.com/en-us/azure/azure-monitor/app/sdk-connection-string?tabs=dotnet5)
''')
var internalSettings = !empty(appInsightsName)
  ? {
  APPLICATIONINSIGHTS_CONNECTION_STRING: any(appInsights).properties.ConnectionString // Recommended MS way
  APPINSIGHTS_INSTRUMENTATIONKEY: any(appInsights).properties.InstrumentationKey // Some features don't work without this (for example Log Stream)
    }
  : {}

@description('The validated deployment storage URI for Flex Consumption Function Apps.')
var flexConsumptionDeploymentStorageUri = !empty(deploymentStorageBlobContainerUri)
  ? deploymentStorageBlobContainerUri
  : fail('deploymentStorageBlobContainerUri must be provided.')

@description('The validated runtime version for Flex Consumption Function Apps.')
var flexConsumptionRuntimeVersionValidated = !empty(runtimeVersion)
  ? runtimeVersion
  : fail('runtimeVersion must be provided.')

@description('The Azure Functions configuration for the Flex Consumption Function App.')
var flexConsumptionFunctionAppConfig = {
  deployment: {
    storage: {
      authentication: deploymentStorageAuthentication
      type: 'blobContainer'
      value: flexConsumptionDeploymentStorageUri
    }
  }
  runtime: {
    name: runtimeName
    version: flexConsumptionRuntimeVersionValidated
  }
  scaleAndConcurrency: {
    alwaysReady: billingMode == 'Always ready' ? alwaysReadyInstances : []
    instanceMemoryMB: instanceMemoryMB
    maximumInstanceCount: maximumInstanceCount
    triggers: httpPerInstanceConcurrency > 0
      ? {
          http: {
            perInstanceConcurrency: httpPerInstanceConcurrency
          }
        }
      : null
  }
}

@description('Site configuration for the Flex Consumption Function App.')
var siteConfig = {
  minTlsVersion: tlsVersion
  minTlsCipherSuite: minTlsCipherSuite
  cors: empty(cors) ? null : cors
  healthCheckPath: empty(healthCheckPath) ? null : healthCheckPath
  ipSecurityRestrictions: ipSecurityRestrictions
  scmIpSecurityRestrictions: scmIpSecurityRestrictions
  scmIpSecurityRestrictionsUseMain: scmIpSecurityRestrictionsUseMain
  http20Enabled: http20Enabled
  webSocketsEnabled: webSocketsEnabled
}

@description('Upsert the webApp and potential VNet integration with the given parameters.')
resource webApp 'Microsoft.Web/sites@2025-03-01' = {
  name: appServiceName
  location: location
  kind: 'functionapp,linux'
  identity: identity
  tags: tags
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: httpsOnly
    clientAffinityEnabled: clientAffinityEnabled
    clientAffinityProxyEnabled: clientAffinityProxyEnabled
    clientCertEnabled: clientCertEnabled
    clientCertMode: empty(clientCertMode) ? null : clientCertMode
    publicNetworkAccess:  publicNetworkAccess
    keyVaultReferenceIdentity: keyVaultReferenceIdentity
    virtualNetworkSubnetId: !empty(vNetIntegrationSubnetResourceId) ? vNetIntegrationSubnetResourceId : null
    functionAppConfig: flexConsumptionFunctionAppConfig
    siteConfig: siteConfig
  }

  resource config 'config@2022-09-01' = {
    name: 'appsettings'
    properties: {
      ...internalSettings
      ...appSettings
    }
  }

  resource connectionString 'config@2022-09-01' = {
    name: 'connectionstrings'
    properties: connectionStrings
  }

  resource basicPublishingCredentialsPoliciesFtp 'basicPublishingCredentialsPolicies@2022-09-01' = {
    name: 'ftp'
    properties: {
      allow: false
    }
  }

  resource basicPublishingCredentialsPoliciesScm 'basicPublishingCredentialsPolicies@2022-09-01' = {
    name: 'scm'
    properties: {
      allow: false
    }
  }

}

resource RoleAssignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = [
  for assignment in roleAssignments: {
    name: guid(webApp.name, assignment.roleDefinitionId, assignment.principalId)
    scope: webApp
    properties: {
      roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', '${assignment.roleDefinitionId}')
      principalId: assignment.principalId
      principalType: assignment.principalType
    }
  }
]

@description('Upsert the diagnostic settings for the webapp with the given parameters.')
resource webAppDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceResourceId)) {
  name: diagnosticsName
  scope: webApp
  properties: {
    workspaceId: logAnalyticsWorkspaceResourceId
    logs: diagnosticSettingsLogsCategories
    metrics: diagnosticSettingsMetricsCategories
  }
}

@description('Output the default host name of the Flex Consumption Function App.')
output webAppHostName string = webApp.properties.defaultHostName
@description('The principal id of the identity running this Flex Consumption Function App.')
output webAppPrincipalId string = identity.type == 'SystemAssigned'
  ? webApp.identity.principalId
  : identity.type == 'SystemAssigned, UserAssigned' ? webApp.identity.principalId : ''
@description('The resource name of the Flex Consumption Function App.')
output webAppResourceName string = webApp.name
@description('The resource id of the Flex Consumption Function App.')
output webAppResourceId string = webApp.id
