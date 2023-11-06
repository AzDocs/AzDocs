/*
.SYNOPSIS
Creating a Logic Standard Instance.
.DESCRIPTION
Creating a Logic Standard Instance with the given specs.
Currently kind: functionapp,workflowapp does not seem to be completely supported in the webapp regarding settings appsettings using 'Microsoft.Web/sites/config@2022-03-01'.
Therefore this separate bicep file.
.EXAMPLE
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
.LINKS
- [Bicep Microsoft.Web Sites](https://learn.microsoft.com/en-us/azure/templates/microsoft.web/sites?pivots=deployment-language-bicep)
- [Azure App Service Kind](https://github.com/Azure/app-service-linux-docs/blob/master/Things_You_Should_Know/kind_property.md)
*/

// ================================================= Parameters =================================================
@description('The name of the Logic app.')
@minLength(2)
@maxLength(60)
param logicAppName string

@description('Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location.')
param location string = resourceGroup().location

@description('The resource name of the appserviceplan to use for this logic app.')
@minLength(1)
@maxLength(40)
param appServicePlanName string

@description('The name of the resourcegroup where the appserviceplan resides in to use for this logic app.')
@minLength(1)
@maxLength(90)
param appServicePlanResourceGroupName string

@description('The name of the storageaccount to use as the underlying storage provider for this logic app.')
@minLength(3)
@maxLength(24)
param storageAccountName string

@description('The name of the resourcegroup where the storageaccount resides in to use as the underlying storage provider for this logic app. Defaults to the current resourcegroup.')
@minLength(1)
@maxLength(90)
param storageAccountResourceGroupName string = az.resourceGroup().name

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

@description('Managed service identity to use for this logic app. Defaults to a system assigned managed identity. For object format, refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.web/sites?tabs=bicep#managedserviceidentity.')
param identity object = {
  type: 'SystemAssigned'
}

@description('IP security restrictions for the main entrypoint. Defaults to closing down the appservice for all connections (you need to manually define this). For object format, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.web/sites?tabs=bicep#ipsecurityrestriction.')
param ipSecurityRestrictions array = [
  {
    ipAddress: '0.0.0.0/0'
    action: 'Deny'
    tag: 'Default'
    priority: 10
    name: 'DefaultDeny'
    description: 'Default deny so that something is not publicly exposed.'
  }
]

@description('''
Application settings. For array/object format, refer to [the docs](https://docs.microsoft.com/en-us/azure/templates/microsoft.web/sites?tabs=bicep#namevaluepair).
Remark: if you want to use version 4 of the Azure Functions extension bundle, you should include the AzureFunctionsJobHost__extensionBundle__version setting with value [1.*, 2.0.0) in your configuration.
However, if you don't need to specify a specific version, you can leave this setting out and the Logic App Standard will use the latest version of the extension bundle by default.''')
param appSettings array = [
  {
    name: 'APP_KIND'
    value: 'workflowApp'
  }
  {
    name: 'AzureFunctionsJobHost__extensionBundle__id'
    value: 'Microsoft.Azure.Functions.ExtensionBundle.Workflows'
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

@description('''
The tags to apply to this resource. This is an object with key/value pairs.
Example:
{
  FirstTag: myvalue
  SecondTag: another value
}
''')
param tags object = {}

@description('The kind of logic app to create')
@allowed([
  'kubernetes,functionapp,workflowapp,linux'
  'functionapp,workflowapp'
])
param logicAppKind string = 'functionapp,workflowapp'

@description('''
For Azure Arc-enabled Logic Apps. This object requires the "name" of your custom location for your Kubernetes environment and must have the "type" set to "CustomLocation (and linuxFxVersion to Node|12)".
Example:
{
  name: "customLocationId'",
  type: "CustomLocation"
},
''')
param logicAppExtendedLocation object = {}

@description('True to enable client affinity; false to stop sending session affinity cookies, which route client requests in the same session to the same instance. Default is true.')
param clientAffinityEnabled bool = true

@description('Configures a web site to accept only https requests. Issues redirect for http requests')
param httpsOnly bool = true

@description('Identity to use for Key Vault Reference authentication.')
param logicAppKeyVaultReferenceIdentity string = 'SystemAssigned'

@description('Setting this value to false disables the app (takes the app offline).')
param logicAppEnabledState bool = true

@description('Virtual Network `route all` enabled. This causes all outbound traffic to have Virtual Network Network Security Groups (nsg) and User Defined Routes applied.')
param vnetRouteAllEnabled bool = true

@description('''
The `Always On` feature of Azure App Service, keeps the host process running.
This allows your site to be more responsive to request after significant idle periods.
Otherwise, once a request comes in, the App Service will have to cold boot and load into memory before responding to the request.
''')
param alwaysOn bool = false

@description('State of FTP / FTPS service')
@allowed([
  'AllAllowed'
  'Disabled'
  'FtpsOnly'
])
param ftpsState string = 'Disabled'

@description('''
The option will create Virtual Directories/Application and is only available for Azure Windows App Service. Find it in the Portal under App Service => Configuration => Path mappings => Virtual applications and directories.
''')
param virtualApplications array = [
  {
    virtualPath: '/'
    physicalPath: 'site\\wwwroot'
    preloadEnabled: false
  }
]

@description('''
Cross-Origin Resource Sharing (CORS) settings.Gets or sets the list of origins that should be allowed to make cross-origin calls,
for example: http://example.com:12345). Use "*" to allow all.
Example:
[
  'https://afd.hosting.portal.azure.net'
  'https://afd.hosting-ms.portal.azure.net'
  'https://hosting.portal.azure.net'
  'https://ms.hosting.portal.azure.net'
  'https://ema-ms.hosting.portal.azure.net'
  'https://ema.hosting.portal.azure.net'
]
''')
param logicAppCorsAllowedOrigins array = []

@description('If the AppServicePlan has enabled per-app scaling, you can configure the number of instances the app can use.')
param logicAppNumberOfWorkers int = -1

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

@description('''
Connectionstrings. This object is a plain key/value pair.
Example:
{
 name: 'SQLServerConnectionstring'
 connectionString: 'thisismyv;aluefor;myfirstconnectio;nstring'
 type: 'SQLAzure'
}
''')
param connectionStrings object = {}

@description('SCM(kudu) IP security restrictions for the SCM entrypoint. Defaults to closing down the appservice SCM instance for all connections. For object format, please refer to [documentation](https://docs.microsoft.com/en-us/azure/templates/microsoft.web/sites?tabs=bicep#ipsecurityrestriction).')
param scmIpSecurityRestrictions array = [
  {
    ipAddress: '0.0.0.0/0'
    action: 'Deny'
    tag: 'Default'
    priority: 10
    name: 'DefaultDeny'
    description: 'Default deny so that nothing is publicly exposed by accident'
  }
]

@description('The resource id of the subnet where to integrate the appservice/webapp/logicapp/functionapp into.')
param vNetIntegrationSubnetResourceId string = ''

@description('''
Linux App Framework and version
Example:
'DOTNETCORE|6.0'
''')
param linuxFxVersion string = ''

@description('Property to allow or block all public traffic. Allowed Values: `Enabled`, `Disabled` or an empty string.')
@allowed([
  'Enabled'
  'Disabled'
  ''
])
param publicNetworkAccess string = 'Enabled'

@description('The name of the application insights instance to attach to this app service. If you leave this empty, no AppInsights resource will be created.')
@maxLength(260)
param appInsightsName string = ''

@description('The name of the resourcegroup where the application insights instance resides in to attach to this app service. This application insights instance should be pre-existing. Defaults to the current resourcegroup.')
@minLength(1)
@maxLength(90)
param appInsightsResourceGroupName string = az.resourceGroup().name

// ================================================= Variables ==================================================

@description('Unify the user-defined settings with the internal settings (for example for auto-configuring Application Insights).')
var internalSettings = !empty(appInsightsName) ? [ {
    name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
    value: appInsights.properties.InstrumentationKey
  } ] : []

@description('Unify the user-defined appsettings with the needed default settings for this logic app.')
var appSettingsFinal = union(appSettings, [
    {
      name: 'AzureWebJobsStorage'
      value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value}'
    }
    {
      name: 'AzureWebJobsDashboard'
      value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value}'
    }
  ])
// ================================================== Resources ===================================================

@description('Fetch the application insights instance. This application insights instance should be pre-existing.')
resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  scope: az.resourceGroup(appInsightsResourceGroupName)
  name: appInsightsName
}

@description('Fetch the storage account to be used for this logic app. This storage account should be pre-existing.')
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  scope: az.resourceGroup(storageAccountResourceGroupName)
  name: storageAccountName
}

@description('Fetch the app service plan to be used for this logic app. This app service plan should be pre-existing.')
resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' existing = {
  scope: az.resourceGroup(appServicePlanResourceGroupName)
  name: appServicePlanName
}

// ================================================== Creating Resources ============================================

@description('Upsert the Workflow Logic App with the given parameters.')
resource workflowLogicApp 'Microsoft.Web/sites@2022-03-01' = {
  name: logicAppName
  location: location
  kind: logicAppKind
  identity: identity
  extendedLocation: empty(logicAppExtendedLocation) ? null : logicAppExtendedLocation
  tags: tags
  properties: {
    enabled: logicAppEnabledState
    serverFarmId: appServicePlan.id
    siteConfig: {
      connectionStrings: empty(connectionStrings) ? null : [
        connectionStrings
      ]
      linuxFxVersion: linuxFxVersion
      scmIpSecurityRestrictions: scmIpSecurityRestrictions
      alwaysOn: alwaysOn
      vnetRouteAllEnabled: vnetRouteAllEnabled
      virtualApplications: virtualApplications
      ipSecurityRestrictions: ipSecurityRestrictions
      ftpsState: ftpsState
      numberOfWorkers: logicAppNumberOfWorkers
      scmIpSecurityRestrictionsUseMain: scmIpSecurityRestrictionsUseMain
      http20Enabled: http20Enabled
      appSettings: union(internalSettings, appSettingsFinal) //appSettingsFinal
      cors: {
        allowedOrigins: logicAppCorsAllowedOrigins
      }
    }
    clientAffinityEnabled: clientAffinityEnabled
    httpsOnly: httpsOnly
    publicNetworkAccess: publicNetworkAccess
    keyVaultReferenceIdentity: logicAppKeyVaultReferenceIdentity
    clientCertEnabled: clientCertEnabled
    clientCertMode: clientCertMode
  }

  resource vnetIntegration 'networkConfig@2022-03-01' = if (!empty(vNetIntegrationSubnetResourceId)) {
    name: 'virtualNetwork'
    properties: {
      subnetResourceId: vNetIntegrationSubnetResourceId
      swiftSupported: true
    }
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

@description('Upsert the diagnostic settings for the webapp with the given parameters.')
resource webAppDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceResourceId)) {
  name: diagnosticsName
  scope: workflowLogicApp
  properties: {
    workspaceId: logAnalyticsWorkspaceResourceId
    logs: diagnosticSettingsLogsCategories
    metrics: diagnosticSettingsMetricsCategories
  }
}

@description('Output the logic app\'s resource name.')
output logicAppName string = workflowLogicApp.name
@description('Output the logic app\'s identity principal object id.')
output logicAppPrincipalId string = workflowLogicApp.identity.principalId
