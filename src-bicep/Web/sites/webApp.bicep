/*
.SYNOPSIS
Creating an AppService Instance: WebApp, FunctionApp etc.
.DESCRIPTION
Creating an AppService Instance: WebApp, FunctionApp etc. with the given specs.
.EXAMPLE
<pre>
module webApp 'br:acrazdocsprd.azurecr.io/web/sites/webapp:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 57), 'webapp')
  params: {
    appServiceName: webAppName
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
@description('Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location.')
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

@description('The name of the application insights instance to attach to this app service. If you leave this empty, no AppInsights resource will be created.')
@maxLength(260)
param appInsightsName string = ''

@description('The name of the resourcegroup where the application insights instance resides in to attach to this app service. This application insights instance should be pre-existing. Defaults to the current resourcegroup.')
@minLength(1)
@maxLength(90)
param appInsightsResourceGroupName string = az.resourceGroup().name

@description('Managed service identity to use for this App Service Instance. Defaults to a system assigned managed identity. For object format, refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.web/sites?tabs=bicep#managedserviceidentity.')
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
Connectionstrings. This object is a plain key/value pair.
For example:
 MyConnectionString: 'thisismyv;aluefor;myfirstconnectio;nstring'
 AnotherConnectionString: 'thisismyva;lueform;ysecond;connectionstring'
''')
param connectionStrings object = {}

@description('''
The type of webapp to create. Defaults to a Linux App Service Instance.
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

@description('IP security restrictions for the main entrypoint. Defaults to closing down the appservice instance for all connections. For object format, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.web/sites?tabs=bicep#ipsecurityrestriction.')
param ipSecurityRestrictions array = [
  {
    ipAddress: '0.0.0.0/0'
    action: 'Deny'
    tag: 'Default'
    priority: 10
    name: 'DefaultDeny'
    description: 'Default deny to make sure that something isnt publicly exposed on accident.'
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

@description('Which log categories to enable; This defaults to `allLogs`. For array/object format, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep#logsettings.')
param diagnosticSettingsLogsCategories array = [
  {
    categoryGroup: 'allLogs'
    enabled: true
  }
]

@description('Which Metrics categories to enable; This defaults to `AllMetrics`. For array/object format, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep&pivots=deployment-language-bicep#metricsettings')
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

@description('Linux App Framework and version')
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

// ================================================= Variables =================================================
@description('Unify the user-defined settings with the internal settings (for example for auto-configuring Application Insights).')
var internalSettings = !empty(appInsightsName) ? {
  APPINSIGHTS_INSTRUMENTATIONKEY: appInsights.properties.InstrumentationKey
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

@description('Upsert the webApp & potential VNet integration with the given parameters.')
resource webApp 'Microsoft.Web/sites@2022-03-01' = {
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
    siteConfig: {
      vnetRouteAllEnabled: vnetRouteAllEnabled
      alwaysOn: alwaysOn
      ipSecurityRestrictions: ipSecurityRestrictions
      scmIpSecurityRestrictionsUseMain: scmIpSecurityRestrictionsUseMain
      ftpsState: ftpsState
      http20Enabled: http20Enabled
      linuxFxVersion: linuxFxVersion
    }
  }

  resource vnetIntegration 'networkConfig@2022-03-01' = if (!empty(vNetIntegrationSubnetResourceId)) {
    name: 'virtualNetwork'
    properties: {
      subnetResourceId: vNetIntegrationSubnetResourceId
      swiftSupported: true
    }
  }

  resource config 'config@2022-03-01' = {
    name: 'appsettings'
    properties: union(internalSettings, appSettings)
  }

  resource connectionString 'config@2022-03-01' = {
    name: 'connectionstrings'
    properties: connectionStrings
  }
}

@description('Upsert the stagingslot, appsettings, connectionstrings & potential VNet integration with the given parameters.')
resource webAppStagingSlot 'Microsoft.Web/sites/slots@2022-03-01' = if (deploySlot) {
  name: '${webApp.name}/staging'
  location: location
  kind: webAppKind
  identity: identity
  tags: tags
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: httpsOnly
    clientAffinityEnabled: clientAffinityEnabled
    siteConfig: {
      vnetRouteAllEnabled: vnetRouteAllEnabled
      alwaysOn: alwaysOn
      ipSecurityRestrictions: ipSecurityRestrictions
      scmIpSecurityRestrictionsUseMain: scmIpSecurityRestrictionsUseMain
      ftpsState: ftpsState
      http20Enabled: http20Enabled
      linuxFxVersion: linuxFxVersion
    }
  }

  resource vnetIntegration 'networkConfig@2022-03-01' = if (!empty(vNetIntegrationSubnetResourceId) && (deploySlot)) {
    name: 'virtualNetwork'
    properties: {
      subnetResourceId: vNetIntegrationSubnetResourceId
      swiftSupported: true
    }
  }

  resource config 'config@2022-03-01' = if (deploySlot) {
    name: 'appsettings'
    properties: union(internalSettings, appSettings)
  }

  resource connectionString 'config@2022-03-01' = if (deploySlot) {
    name: 'connectionstrings'
    properties: connectionStrings
  }
}

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
resource webappdiagnosticSettingAppSlot 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceResourceId) && (deploySlot)) {
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
output webAppStagingSlotHostName string = (deploySlot) ? webAppStagingSlot.properties.defaultHostName : ''
@description('The principal id of the identity running this webapp')
output webAppPrincipalId string = webApp.identity.principalId
@description('The principal id of the identity running this webapp\'s staging slot')
output webAppStagingSlotPrincipalId string = (deploySlot) ? webAppStagingSlot.identity.principalId : ''
@description('The resource name of the webapp.')
output webAppResourceName string = webApp.name
@description('The resource name of the webapp\'s staging slot.')
output webAppStagingSlotResourceName string = (deploySlot) ? webAppStagingSlot.name : ''
