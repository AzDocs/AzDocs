/*
.SYNOPSIS
Creating an AppService Instance: WebApp, FunctionApp etc.
.DESCRIPTION
Creating an AppService Instance: WebApp, FunctionApp etc. with the given specs.
.EXAMPLE
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
  }
}
</pre>
<p>Creates a WebApp with the name 'webAppName'</p>
.LINKS
- [Bicep Microsoft.Web Sites](https://learn.microsoft.com/en-us/azure/templates/microsoft.web/sites?pivots=deployment-language-bicep)
- [Azure App Service Kind](https://github.com/Azure/app-service-linux-docs/blob/master/Things_You_Should_Know/kind_property.md)
*/

// ================================================= Parameters =================================================
@description('Specifies the Azure location where the resource should be created.')
param location string = resourceGroup().location

@description('The name of the App Service Instance.')
@minLength(2)
@maxLength(60)
param appServiceName string

@description('The resource name of the appserviceplan to use for this App Service Instance.')
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
param identity object = {
  type: 'SystemAssigned'
}

@description('''
Application settings. This object is a plain key/value pair.
For example:
 SomeSetting: 'myvalue'
 AnotherSetting: 'Another value'
''')
param appSettings object = {}

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
param connectionStrings object = {}

@description('''
The type of webapp to create.
''')
@allowed([
  'api'
  'app'
  'app,linux'
  'app,linux,container'
  'hyperV'
  'app,container,windows'
  'app,linux,kubernetes'
  'functionapp'
  'functionapp,linux'
  'functionapp,linux,kubernetes'
  'functionapp,linux,kubernetes,container'
])
param webAppKind string = 'app,linux'

@description('IP security restrictions for the main entrypoint. Defaults to closing down the appservice instance for all connections. For object format, please refer to [documentation](https://docs.microsoft.com/en-us/azure/templates/microsoft.web/sites?tabs=bicep#ipsecurityrestriction).')
param ipSecurityRestrictions array = [
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
param scmIpSecurityRestrictions array = [
  {
    ipAddress: '0.0.0.0/0'
    action: 'Deny'
    tag: 'Default'
    priority: 2147483646
    name: 'DefaultDeny'
    description: 'Default deny so that nothing is publicly exposed by accident'
  }
]

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
param diagnosticSettingsLogsCategories array = [
  {
    categoryGroup: 'allLogs'
    enabled: true
  }
]

@description('Which Metrics categories to enable; This defaults to `AllMetrics`. For array/object format, please refer to [documentation](https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep&pivots=deployment-language-bicep#metricsettings).')
param diagnosticSettingsMetricsCategories array = [
  {
    categoryGroup: 'AllMetrics'
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
param tags object = {}

@description('Configures a web site to accept only https requests. Issues redirect for http requests')
param httpsOnly bool = true

@description('True to enable client affinity; false to stop sending session affinity cookies, which route client requests in the same session to the same instance. Default is true.')
param clientAffinityEnabled bool = true

@description('Virtual Network `route all` enabled. This causes all outbound traffic to have Virtual Network Network Security Groups (nsg) and User Defined Routes applied.')
param vnetRouteAllEnabled bool = false

@description('''
The `Always On` feature of Azure App Service, keeps the host process running.
This allows your site to be more responsive to request after significant idle periods.
Otherwise, once a request comes in, the App Service will have to cold boot and load into memory before responding to the request.
''')
param alwaysOn bool = true

@description('IP security restrictions for scm to use the same settings as main.')
param scmIpSecurityRestrictionsUseMain bool = true

@description('State of FTP / FTPS service')
@allowed([
  'AllAllowed'
  'Disabled'
  'FtpsOnly'
])
param ftpsState string = 'Disabled'

@description('Http20Enabled: configures a web site to allow clients to connect over http2.0')
param http20Enabled bool = true

@description('Linux App Framework and version.')
param linuxFxVersion string = 'DOTNETCORE|6.0'

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

@description('Determine whether to deploy a staging slot in the webApp (default: true).')
param deploySlot bool = true

@description('Use 32-bit worker process on 64-bit platform. Uses 64-bit worker process if false. Default is true (will use 32-bit).')
param use32BitWorkerProcess bool = true

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
param cors object = {}

@description('Number to indicate on how many instances the app will run.')
param numberOfWorkers int = 2

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
param roleAssignments array = []

// ================================================= Variables =================================================
@description('''
Unify the user-defined settings with the internal settings (for example for auto-configuring Application Insights).
[link](https://learn.microsoft.com/en-us/azure/azure-monitor/app/sdk-connection-string?tabs=dotnet5)
''')
var internalSettings = !empty(appInsightsName) ? {
  APPLICATIONINSIGHTS_CONNECTION_STRING: appInsights.properties.ConnectionString
} : {}

// ================================================= Resources =================================================
@description('Fetch the app service plan to be used for this appservice instance. This app service plan should be pre-existing.')
resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' existing = {
  scope: az.resourceGroup(appServicePlanResourceGroupName)
  name: appServicePlanName
}

@description('Fetch the application insights instance. This application insights instance should be pre-existing.')
resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  scope: az.resourceGroup(appInsightsResourceGroupName)
  name: appInsightsName
}

@description('Upsert the webApp and potential VNet integration with the given parameters.')
resource webApp 'Microsoft.Web/sites@2022-09-01' = {
  name: appServiceName
  location: location
  kind: webAppKind
  identity: identity
  tags: tags
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: httpsOnly
    clientAffinityEnabled: clientAffinityEnabled
    clientCertEnabled: clientCertEnabled
    clientCertMode: empty(clientCertMode) ? null : clientCertMode
    publicNetworkAccess: publicNetworkAccess
    virtualNetworkSubnetId: !empty(vNetIntegrationSubnetResourceId) ? vNetIntegrationSubnetResourceId : null
    siteConfig: {
      cors: empty(cors) ? null : cors
      healthCheckPath: empty(healthCheckPath) ? null : healthCheckPath
      vnetRouteAllEnabled: vnetRouteAllEnabled
      alwaysOn: alwaysOn
      ipSecurityRestrictions: ipSecurityRestrictions
      scmIpSecurityRestrictions: scmIpSecurityRestrictions
      scmIpSecurityRestrictionsUseMain: scmIpSecurityRestrictionsUseMain
      ftpsState: ftpsState
      http20Enabled: http20Enabled
      linuxFxVersion: empty(linuxFxVersion) ? null : linuxFxVersion
      use32BitWorkerProcess: use32BitWorkerProcess
      numberOfWorkers: numberOfWorkers
    }
  }

  resource config 'config@2022-09-01' = {
    name: 'appsettings'
    properties: union(internalSettings, appSettings)
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

@description('Upsert the stagingslot, appsettings, connectionstrings & potential VNet integration with the given parameters.')
resource webAppStagingSlot 'Microsoft.Web/sites/slots@2022-09-01' = if (deploySlot) {
  parent: webApp
  name: 'staging'
  location: location
  kind: webAppKind
  identity: identity
  tags: tags
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: httpsOnly
    publicNetworkAccess: publicNetworkAccess
    clientAffinityEnabled: clientAffinityEnabled
    virtualNetworkSubnetId: !empty(vNetIntegrationSubnetResourceId) ? vNetIntegrationSubnetResourceId : null
    siteConfig: {
      cors: empty(cors) ? null : cors
      vnetRouteAllEnabled: vnetRouteAllEnabled
      alwaysOn: alwaysOn
      ipSecurityRestrictions: ipSecurityRestrictions
      scmIpSecurityRestrictionsUseMain: scmIpSecurityRestrictionsUseMain
      ftpsState: ftpsState
      http20Enabled: http20Enabled
      linuxFxVersion: linuxFxVersion
      use32BitWorkerProcess: use32BitWorkerProcess
      numberOfWorkers: numberOfWorkers
    }
  }

  resource config 'config@2022-09-01' = if (deploySlot) {
    name: 'appsettings'
    properties: union(internalSettings, appSettings)
  }

  resource connectionString 'config@2022-09-01' = if (deploySlot) {
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

resource RoleAssignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = [for assignment in roleAssignments:{
  name: guid(webApp.name, assignment.RoleDefinitionId, assignment.principalId)
  scope: webApp
  properties: {
    roleDefinitionId:resourceId('Microsoft.Authorization/roleDefinitions','${assignment.roleDefinitionId}')
    principalId: assignment.principalId
    principalType: assignment.principalType
  }
}]

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

@description('Upsert the diagnostic settings for the webapp\'s staging slot with the given parameters.')
resource webappdiagnosticSettingAppSlot 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceResourceId) && deploySlot) {
  name: diagnosticsName
  scope: webAppStagingSlot
  properties: {
    workspaceId: logAnalyticsWorkspaceResourceId
    logs: diagnosticSettingsLogsCategories
    metrics: diagnosticSettingsMetricsCategories
  }
}

@description('Output the default host name of the webapp.')
output webAppHostName string = webApp.properties.defaultHostName
@description('Output the default host name of the webapp\'s staging slot.')
output webAppStagingSlotHostName string = deploySlot ? webAppStagingSlot.properties.defaultHostName : ''
@description('The principal id of the identity running this webapp')
output webAppPrincipalId string = identity.type == 'SystemAssigned' ? webApp.identity.principalId : identity.type == 'SystemAssigned, UserAssigned' ? webApp.identity.principalId  : ''
@description('The principal id of the identity running this webapp\'s staging slot')
output webAppStagingSlotPrincipalId string = deploySlot ? identity.type == 'SystemAssigned' ? webAppStagingSlot.identity.principalId : identity.type == 'SystemAssigned, UserAssigned' ? webAppStagingSlot.identity.principalId  : '' : ''
@description('The resource name of the webapp.')
output webAppResourceName string = webApp.name
@description('The resource name of the webapp\'s staging slot.')
output webAppStagingSlotResourceName string = deploySlot ? webAppStagingSlot.name : ''
