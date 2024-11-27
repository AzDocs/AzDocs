/*
.SYNOPSIS
Creating Azure Key Vault and optionally secrets.
.DESCRIPTION
This module is used for creating Azure Key Vault and optionally secrets.
.EXAMPLE
<pre>
module keyVault 'br:contosoregistry.azurecr.io/keyvault/vaults:latest' = {
  name: '${take(deployment().name, 57)}-kv'
  params:{
    keyVaultName: keyVaultName
    enableRbacAuthorization: true
    softDeleteRetentionInDays: 30
    location: location
    skuName: 'standard'
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: true
    keyVaultnetworkAclsBypass: 'AzureServices'
    publicNetworkAccess: 'Enabled'
  }
}
</pre>
.LINKS
- [Bicep Microsoft.KeyVault Vaults](https://learn.microsoft.com/en-us/azure/templates/microsoft.keyvault/vaults?pivots=deployment-language-bicep)
*/

// ================================================= Parameters =================================================
@description('''
The name of the KeyVault to upsert
Keyvault name restrictions:
- Keyvault names must be between 3 and 24 alphanumeric characters in length. The name must begin with a letter, end with a letter or digit, and not contain consecutive hyphens
- Your keyVaultName must be unique within Azure.
''')
@minLength(3)
@maxLength(24)
param keyVaultName string

@description('Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location.')
param location string = resourceGroup().location

@description('Specifies whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the key vault.')
param enabledForDeployment bool = false

@description('Specifies whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys.')
param enabledForDiskEncryption bool = false

@description('Specifies whether Azure Resource Manager is permitted to retrieve secrets from the key vault.')
param enabledForTemplateDeployment bool = false

@description('''
Property that controls how data actions are authorized. When true, the key vault will use Role Based Access Control (RBAC) for authorization of data actions, 
and the access policies specified in vault properties will be ignored. 
When false, the key vault will use the access policies specified in vault properties, and any policy stored on Azure Resource Manager will be ignored. 
If null or not specified, the vault is created with the default value of false.
''')
param enableRbacAuthorization bool = false

@description('Specifies the Azure Active Directory tenant ID that should be used for authenticating requests to the key vault. Get it by using Get-AzSubscription cmdlet. Defaults to the current subscription\'s tenant.')
param tenantId string = subscription().tenantId

@description('Specifies whether the key vault is a standard vault or a premium vault.')
@allowed([
  'standard'
  'premium'
])
param skuName string = 'standard'

@description('''
Specifies all secrets {"secretName":"","secretValue":""} wrapped in a secure object.
Example:
param secrets array = [
  {
    attributesEnabled: true
    attributesExp: dateTimeToEpoch(dateTimeAdd(utcNow('u'), 'P1Y'))
    attributesNbf: dateTimeToEpoch(utcNow('u'))
    secretName: 'ClientSecret21'
    secretValue: 'VeryDifficultPassword'
    contentType: 'password'
  }
]
''')
param secrets array = []

@description('Specifies if you need to recover a Keyvault. This is mandatory whenever a deleted keyvault with the same name already existed in your subscription.')
param recoverKeyvault bool = false

@description('Specifies the Resource ID\'s of the subnet(s) you want to whitelist on the KeyVault')
param subnetIdsToWhitelist array = []

@description('The soft-delete retention for keeping items after deleting them.')
@minValue(7)
@maxValue(90)
param softDeleteRetentionInDays int

@description('Property to specify whether the vault will accept traffic from public internet. If set to \'disabled\' all traffic except private endpoint traffic and that that originates from trusted services will be blocked.')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Enabled'

@description('Defines if you want to default allow & deny traffic coming from non-whitelisted sources. Defaults to deny for security reasons.')
param networkAclDefaultAction string = 'Deny'

@description('Define a bypass for AzureServices. Defaults to \'None\'')
@allowed([
  'AzureServices'
  'None'
])
param keyVaultnetworkAclsBypass string = 'None'

@description('Define a whitelist of public IP addresses which are granted from the service firewall')
param allowedIpAddresses array = []

@description('The name of the diagnostics. This defaults to `AzurePlatformCentralizedLogging`.')
@minLength(1)
@maxLength(260)
param diagnosticsName string = 'AzurePlatformCentralizedLogging'

@description('The azure resource id of the log analytics workspace to log the diagnostics to. If you set this to an empty string, logging & diagnostics will be disabled.')
@minLength(0)
param logAnalyticsWorkspaceResourceId string = ''

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
param tags object?

@description('Translate the passed parameter to actual usable subnet objects.')
var virtualNetworkRules = [
  for subnetId in subnetIdsToWhitelist: {
    id: subnetId
    ignoreMissingVnetServiceEndpoint: false
  }
]

@description('Translate the ip rules to the correct format, so it can be used within the resource')
var ipRules = [
  for ipRule in allowedIpAddresses: {
    value: ipRule
  }
]

@description('Upsert the Keyvault')
resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: keyVaultName
  tags: tags
  location: location
  properties: {
    enabledForDeployment: enabledForDeployment // VMs can retrieve certificates
    enabledForTemplateDeployment: enabledForTemplateDeployment // ARM can retrieve values
    enabledForDiskEncryption: enabledForDiskEncryption
    enableRbacAuthorization: enableRbacAuthorization
    tenantId: tenantId
    sku: {
      name: skuName
      family: 'A'
    }
    accessPolicies: []
    networkAcls: {
      defaultAction: networkAclDefaultAction
      bypass: keyVaultnetworkAclsBypass
      ipRules: ipRules
      virtualNetworkRules: virtualNetworkRules
    }
    enablePurgeProtection: true // Not allowing to purge key vault or its objects after deletion
    enableSoftDelete: true
    softDeleteRetentionInDays: softDeleteRetentionInDays
    createMode: recoverKeyvault ? 'recover' : 'default'
    publicNetworkAccess: publicNetworkAccess
  }
}

@description('Upsert the diagnostics for this keyvault.')
resource keyvaultDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceResourceId)) {
  name: diagnosticsName
  scope: keyVault
  properties: {
    workspaceId: logAnalyticsWorkspaceResourceId
    logs: diagnosticSettingsLogsCategories
    metrics: diagnosticSettingsMetricsCategories
  }
}

@description('Upsert the secrets defined in the parameters')
resource secretsRef 'Microsoft.KeyVault/vaults/secrets@2021-10-01' = [
  for secret in secrets: {
    name: replace(replace(replace(replace(secret.secretName, '-', '--'), '.', '-'), '_', '-'), ' ', '-')
    parent: keyVault
    tags: tags
    properties: {
      value: secret.secretValue
      contentType: secret.?contentType ?? ''
      attributes: {
        enabled: secret.?attributesEnabled ?? true
        exp: secret.?attributesExp ?? null
        nbf: secret.?attributesNbf ?? null
      }
    }
  }
]

@description('The keyvault name.')
output keyVaultName string = keyVault.name
@description('The keyvault resource id.')
output keyVaultId string = keyVault.id
@description('An array of secrets which were added to keyvault. Each object contains id & name parameters.')
output keyvaultSecrets array = [
  for i in range(0, length(secrets)): {
    id: secretsRef[i].id
    name: secretsRef[i].name
  }
]
