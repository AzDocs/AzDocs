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
    description: 'Default deny to make sure that something isnt publicly exposed on accident.'
  }
]

@description('Application settings. For array/object format, refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.web/sites?tabs=bicep#namevaluepair.')
param appSettings array = []

@description('''
The tags to apply to this resource. This is an object with key/value pairs.
Example:
{
  FirstTag: myvalue
  SecondTag: another value
}
''')
param tags object = {}

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

@description('Fetch the storage account to be used for this logic app. This storage account should be pre-existing.')
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' existing = {
  scope: az.resourceGroup(storageAccountResourceGroupName)
  name: storageAccountName
}

@description('Fetch the app service plan to be used for this logic app. This app service plan should be pre-existing.')
resource appServicePlan 'Microsoft.Web/serverfarms@2021-03-01' existing = {
  scope: az.resourceGroup(appServicePlanResourceGroupName)
  name: appServicePlanName
}

@description('Upsert the Workflow Logic App with the given parameters.')
resource workflowLogicApp 'Microsoft.Web/sites@2021-03-01' = {
  name: logicAppName
  location: location
  kind: 'functionapp,workflowapp'
  identity: identity
  tags: tags
  properties: {
    enabled: true
    serverFarmId: appServicePlan.id
    reserved: false
    siteConfig: {
      vnetRouteAllEnabled: true
      virtualApplications: [
        {
          virtualPath: '/'
          physicalPath: 'site\\wwwroot'
          preloadEnabled: false
        }
      ]
      ipSecurityRestrictions: ipSecurityRestrictions
      ftpsState: 'Disabled'
      numberOfWorkers: 1
      scmIpSecurityRestrictionsUseMain: true
      http20Enabled: true
      appSettings: appSettingsFinal
    }
    clientAffinityEnabled: true
    httpsOnly: true
    keyVaultReferenceIdentity: 'SystemAssigned'
    clientCertEnabled: false
  }
}

@description('Output the logic app\'s resource name.')
output logicAppName string = workflowLogicApp.name
@description('Output the logic app\'s identity principal object id.')
output logicAppPrincipalId string = workflowLogicApp.identity.principalId
