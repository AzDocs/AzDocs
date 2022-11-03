//https://learn.microsoft.com/en-us/azure/templates/microsoft.web/sites?pivots=deployment-language-bicep
@description('Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location.')
param location string = resourceGroup().location

@description('The name of the App Service app.')
@minLength(2)
@maxLength(60)
param appServiceName string

@description('The resource name of the appserviceplan to use for this logic app.')
@minLength(1)
@maxLength(40)
param appServicePlanName string

@description('The name of the resourcegroup where the appserviceplan resides in to use for this logic app. Defaults to the current resourcegroup.')
@minLength(1)
@maxLength(90)
param appServicePlanResourceGroupName string = az.resourceGroup().name

@description('The name of the application insights instance to attach to this app service. This App Insights instance should be pre-existing.')
@minLength(1)
@maxLength(260)
param appInsightsName string = ''

@description('The name of the resourcegroup where the application insights instance resides in to attach to this app service. This App Insights instance should be pre-existing. Defaults to the current resourcegroup.')
@minLength(1)
@maxLength(90)
param appInsightsResourceGroupName string = az.resourceGroup().name

@description('Managed service identity to use for this logic app. Defaults to a system assigned managed identity. For object format, refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.web/sites?tabs=bicep#managedserviceidentity.')
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

@allowed([
  'api'
  'app'
  'app,linux'
  'functionapp'
  'functionapp,linux'
])
@description('''
The type of webapp to create. Options are:
  'api' --> API App
  'app' --> Windows WebApp
  'app,linux' --> Linux WebApp
  'functionapp' --> Windows FunctionApp
  'functionapp,linux' --> Linux FunctionApp.
  'functionapp,linux,kubernetes'
  'functionapp,linux,kubernetes,container'
''')
param webAppKind string = 'app,linux'

@description('IP security restrictions for the main entrypoint. Defaults to closing down the appservice for all connections (you need to manually define this). For object format, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.web/sites?tabs=bicep#ipsecurityrestriction.')
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
The tags to apply to this resource. This is an object with key/value pairs.
Example:
{
  FirstTag: myvalue
  SecondTag: another value
}
''')
param tags object = {}

@description('''
To provide Azure with the ability to create resources on the Azure Arc enabled Kubernetes cluster a Custom Location needs to be created.
Use e.g. `az customlocation create` (which is just creating another resource type) in Azure.
This will effectively allow Azure to “route” the creation request to the appropriate location (i.e. a namespace on our cluster).
You will need to associate the App Service Kubernetes environment with that custom location.
Example:
{
  name: customLocationId
}
''')
param extendedLocation string = ''

@description('Configures a web site to accept only https requests. Issues redirect for http requests')
param httpsOnly bool = true

@description('True to enable client affinity; false to stop sending session affinity cookies, which route client requests in the same session to the same instance. Default is true.')
param clientAffinityEnabled bool = true

@description('Virtual Network Route All enabled. This causes all outbound traffic to have Virtual Network Security Groups and User Defined Routes applied.')
param vnetRouteAllEnabled bool = false

@description('True if Always On is enabled; otherwise, false.')
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

@description('True to enable client certificate authentication (TLS mutual authentication); otherwise, false. Default is false.')
param clientCertEnabled bool = false

@description('''
Setting is linked to clientCertEnabled parameter.
ClientCertEnabled: false means ClientCert is ignored.
ClientCertEnabled: true and ClientCertMode: Required means ClientCert is required.
ClientCertEnabled: true and ClientCertMode: Optional means ClientCert is optional or accepted.
Example:
'Optional',
'OptionalInteractiveUser',
'Required'
''')
param clientCertMode string  = ''

@description('Property to allow or block all public traffic. Allowed Values: `Enabled`, `Disabled` or an empty string.')
@allowed([
  'Enabled'
  'Disabled'
  ''
])
param publicNetworkAccess string = 'Enabled'

@description('Unify the user-defined settings with the internal settings (for example for auto-configuring Application Insights).')
var internalSettings = !empty(appInsightsName) ? {
  APPINSIGHTS_INSTRUMENTATIONKEY: appInsights.properties.InstrumentationKey
} : {}

@description('Fetch the app service plan to be used for this logic app. This app service plan should be pre-existing.')
resource appServicePlan 'Microsoft.Web/serverfarms@2021-03-01' existing = {
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
  extendedLocation: {
    name: empty(extendedLocation)? null : extendedLocation
  }
  identity: identity
  tags: tags
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: httpsOnly
    clientAffinityEnabled: clientAffinityEnabled
    clientCertEnabled: clientCertEnabled
    clientCertMode: empty(clientCertMode)? null : clientCertMode
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

  resource vnetIntegration 'networkConfig@2021-03-01' = if (!empty(vNetIntegrationSubnetResourceId)) {
    name: 'virtualNetwork'
    properties: {
      subnetResourceId: vNetIntegrationSubnetResourceId
      swiftSupported: true
    }
  }
}

@description('Upsert the stagingslot, appsettings, connectionstrings & potential VNet integration with the given parameters.')
resource webAppStagingSlot 'Microsoft.Web/sites/slots@2021-03-01' = {
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

  resource vnetIntegration 'networkConfig@2021-03-01' = if (!empty(vNetIntegrationSubnetResourceId)) {
    name: 'virtualNetwork'
    properties: {
      subnetResourceId: vNetIntegrationSubnetResourceId
      swiftSupported: true
    }
    dependsOn: [
      webApp::vnetIntegration
    ]
  }

  resource config 'config@2021-03-01' = {
    name: 'appsettings'
    properties: union(internalSettings, appSettings)
    dependsOn: [
      vnetIntegration
    ]
  }

  resource connectionString 'config@2020-12-01' = {
    name: 'connectionstrings'
    properties: connectionStrings
    dependsOn: [
      config
    ]
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
resource webappdiagnosticSettingAppSlot 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceResourceId)) {
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
output webAppStagingSlotHostName string = webAppStagingSlot.properties.defaultHostName
@description('The principal id of the identity running this webapp')
output webAppPrincipalId string = webApp.identity.principalId
@description('The principal id of the identity running this webapp\'s staging slot')
output webAppStagingSlotPrincipalId string = webAppStagingSlot.identity.principalId
@description('The resource name of the webapp.')
output webAppResourceName string = webApp.name
@description('The resource name of the webapp\'s staging slot.')
output webAppStagingSlotResourceName string = webAppStagingSlot.name
