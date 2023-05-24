/*
.SYNOPSIS
Creating a FrontDoor Cdn profile
.DESCRIPTION
Creating a FrontDoor Cdn profile. This creates an Azure FrontDoor Standard or Premium. It cannot not create a FrontDoor Classic, this is in a different namespace.
.EXAMPLE
<pre>
module frontDoorProfile 'br:contosoregistry.azurecr.io/cdn/profiles:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 51), 'fdoorprofile')
  params: {
    frontDoorName: frontDoorName
    skuName: 'Premium_AzureFrontDoor'
  }
}
</pre>
<p>Creates a Frontdoor Cdn Profile with the name cdnp-frontdoorname and a Premium sku.</p>
.INFO
When you try to create a FrontDoor profile that existed before and you receive the following similar error: 'Request specified that resource '/subscriptions/<subscriptionId>/resourcegroups/<rgname>/providers/Microsoft.Cdn/profiles/<profilename>'
is new, but resource already exists. This may be due to a pending delete operation, try again later.', then you may try to fix this by registering the following feature using command:
'Register-AzProviderFeature -ProviderNamespace Microsoft.Cdn -FeatureName BypassCnameCheckForCustomDomainDeletion'.
.LINKS
- [Bicep Microsoft.Cdn profiles](https://learn.microsoft.com/en-us/azure/templates/microsoft.cdn/profiles?pivots=deployment-language-bicep)
*/
// ===================================== Parameters =====================================
@description('The name of the Front Door profile to create. This must be globally unique.')
@minLength(1)
@maxLength(260)
param frontDoorName string

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
Sets the identity property for the frontdoor profile
Examples:
<details>
  <summary>Click to show example</summary>
{
  type: 'UserAssigned'
  userAssignedIdentities: {}
},
{
  type: 'SystemAssigned'
}
</details>
''')
param identity object = {
  type: 'SystemAssigned'
}

@description('The name of the SKU to use when creating the Front Door profile.')
@allowed([
  'Standard_AzureFrontDoor'
  'Premium_AzureFrontDoor'
])
param skuName string = 'Standard_AzureFrontDoor'

@description('The origin response timeout in seconds. Valid values are 1-86400.')
param frontDoorProfileOriginResponseTimeoutSeconds int = 60

@description('The name of the diagnostics. This defaults to `AzurePlatformCentralizedLogging`.')
@minLength(1)
@maxLength(260)
param diagnosticsName string = 'AzurePlatformCentralizedLogging'

@description('The azure resource id of the log analytics workspace to log the diagnostics to. If you set this to an empty string, logging & diagnostics will be disabled.')
@minLength(0)
param logAnalyticsWorkspaceResourceId string = ''

@description('Which log categories to enable; This defaults to `allLogs`. For array/object format, please refer to [the docs](https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep#logsettings.)')
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

// ===================================== Resources =====================================
resource frontdoorprofile 'Microsoft.Cdn/profiles@2022-11-01-preview' = {
  name: frontDoorName
  location: 'Global'
  tags: tags
  sku: {
    name: skuName
  }
  identity: identity
  properties: {
    originResponseTimeoutSeconds: frontDoorProfileOriginResponseTimeoutSeconds
  }
}

@description('Upsert the diagnostics for this resource.')
resource frontdoorProfilesDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceResourceId)) {
  name: diagnosticsName
  scope: frontdoorprofile
  properties: {
    workspaceId: logAnalyticsWorkspaceResourceId
    logs: diagnosticSettingsLogsCategories
    metrics: diagnosticSettingsMetricsCategories
  }
}

@description('Output the frontdoor profile\'s name.')
output frontDoorName string = frontdoorprofile.name
@description('Output the frontdoor profile\'s resource id.')
output frontDoorProfileResourceId string = frontdoorprofile.id
@description('Output the logic app\'s identity principal object id.')
output frontDoorPrincipalId string = frontdoorprofile.identity.principalId
