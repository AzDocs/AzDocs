/*
.SYNOPSIS
Creating a Azure Container Registry.
.DESCRIPTION
Creating an Azure Container Registry with the given specs.
.EXAMPLE
<pre>
module acr '../../AzDocs/src-bicep/ContainerRegistry/registries.bicep' = {
  name: format('{0}-{1}', take('${deployment().name}', 48), 'acrDeploy')
  params: {
    tags: tags
    anonymousPullEnabled: true
    containerRegistryName: containerRegistryName
    logAnalyticsWorkspaceResourceId: logAnalyticsWorkspaceResourceId
    location: location
    skuName: 'Premium'
    publicNetworkAccess: true
    policies: {
      azureADAuthenticationAsArmPolicy: {
        status: 'enabled'
      }
      quarantinePolicy: {
        status: 'disabled'
      }
      retentionPolicy: {
        days: 30
        status: 'enabled'
      }
      trustPolicy: {
        status: 'enabled'
        type: 'Notary'
      }

    }
  }
}
</pre>
<p>Creates an acr with the name containerRegistryName</p>
.LINKS
- [Bicep Microsoft.ContainerRegistry registries](https://learn.microsoft.com/en-us/azure/templates/microsoft.containerregistry/registries?pivots=deployment-language-bicep)
- [azureADAuthenticationAsArmPolicy](https://www.azadvertizer.net/azpolicyadvertizer/42781ec6-6127-4c30-bdfa-fb423a0047d3.html)
- [quarantinePolicy](https://github.com/Azure/acr/tree/main/docs/preview/quarantine)
- [quarantinePolicy](https://samcogan.com/image-quarantine-in-azure-container-registry/)
- [retentionPolicy](https://learn.microsoft.com/en-us/azure/container-registry/container-registry-retention-policy)
- [trustPolicy](https://learn.microsoft.com/en-us/azure/container-registry/container-registry-content-trust)
*/

// ================================================= Parameters =================================================

@description('''
The name of the Azure Container Registry to be upserted.
''')
@minLength(5)
@maxLength(50)
param containerRegistryName string

@description('Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location.')
param location string = resourceGroup().location

@description('The name of the diagnostics. This defaults to `AzurePlatformCentralizedLogging`.')
@minLength(1)
@maxLength(260)
param diagnosticsName string = 'AzurePlatformCentralizedLogging'

@description('The azure resource id of the log analytics workspace to log the diagnostics to. If you set this to an empty string, logging & diagnostics will be disabled.')
@minLength(0)
param logAnalyticsWorkspaceResourceId string

@description('Which log categories to enable; This defaults to `allLogs`. For array/object format, please refer to the [specifications](https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep#logsettings).')
param diagnosticSettingsLogsCategories array = [
  {
    categoryGroup: 'allLogs'
    enabled: true
  }
]

@description('Which Metrics categories to enable; This defaults to `AllMetrics`. For array/object format, please refer to the [specifications](https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep&pivots=deployment-language-bicep#metricsettings)')
param diagnosticSettingsMetricsCategories array = [
  {
    categoryGroup: 'AllMetrics'
    enabled: true
  }
]

@description('''
Sets the identity property for the container registry
Example:
{
  type: 'UserAssigned'
  userAssignedIdentities: userAssignedIdentities
}'
''')
param identity object = {
  type: 'SystemAssigned'
}

@description('''
The tags to apply to this resource. This is an object with key/value pairs.
Example:
{
  FirstTag: myvalue
  SecondTag: another value
}
''')
param tags object = {}

@allowed([
  'Basic'
  'Classic'
  'Premium'
  'Standard'
])
@description('The sku of this Azure Container Registry.')
param skuName string = 'Premium'

@description('Enable the admin user to login with a username & password to this ACR.')
param adminUserEnabled bool = false

@description('Allow pulling without being authenticated against this Azure Container Registry.')
param anonymousPullEnabled bool = false

@description('If you want to allow trusted azure services to bypass your network settings, enable this.')
param allowAzureServicesNetworkBypass bool = false

@description('''
The default network action for this Azure Container Registry.
Disabling public network access is not allowed for SKU Basic and SKU Standard.''')
param publicNetworkAccess bool = false

@description('An array of IP Rules to apply to this Azure Container Registry. For object structure, please refer to the [specification](https://learn.microsoft.com/en-us/azure/templates/microsoft.containerregistry/registries?pivots=deployment-language-bicep#iprule).')
param ipRules array = []

@description('The policies to apply on this ACR. For object structure, please refer to the [specifications](https://learn.microsoft.com/en-us/azure/templates/microsoft.containerregistry/registries?pivots=deployment-language-bicep#policies).')
param policies object = {}

@description('Enable zone redundancy for this ACR.')
@allowed([
  'Enabled'
  'Disabled'
])
param zoneRedundancy string = 'Disabled'

@description('Setting up the networkRuleSet and add ip rules if any are defined.')
param networkRuleSet object = empty(ipRules) ? {} : {
  defaultAction: 'Deny'
  ipRules: ipRules
}

@description('Upsert the azure container registry instance.')
resource registry 'Microsoft.ContainerRegistry/registries@2022-02-01-preview' = {
  name: containerRegistryName
  location: location
  tags: tags
  identity: identity
  sku: {
    name: skuName
  }
  properties: {
    adminUserEnabled: adminUserEnabled
    anonymousPullEnabled: anonymousPullEnabled
    networkRuleBypassOptions: allowAzureServicesNetworkBypass ? 'AzureServices' : 'None'
    publicNetworkAccess: publicNetworkAccess ? 'Enabled' : 'Disabled'
    policies: policies
    networkRuleSet: networkRuleSet
    zoneRedundancy: zoneRedundancy
  }
}

@description('Upsert the diagnostics for this acr.')
resource acrDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceResourceId)) {
  name: diagnosticsName
  scope: registry
  properties: {
    workspaceId: logAnalyticsWorkspaceResourceId
    logs: diagnosticSettingsLogsCategories
    metrics: diagnosticSettingsMetricsCategories
  }
}

@description('Output the login server property for later use.')
output acrRegistryLoginServer string = registry.properties.loginServer
@description('Output the resourceId of the azure container registry')
output acrRegistryId string = registry.id
@description('Output the name of the azure container registry.')
output acrRegistryName string = registry.name
