@description('Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location.')
param location string = resourceGroup().location

@description('The resourcename of the SQL Server upsert.')
@minLength(1)
@maxLength(63)
param sqlServerName string

@description('If you want to enable an AAD administrator for this SQL Server, you need to pass the Azure AD Object ID of the principal in this parameter.')
@maxLength(36)
param azureActiveDirectoryAdminObjectId string = ''

@description('Login name of the server administrator.')
param azureActiveDirectoryAdminUserName string

@description('If this is enabled, SQL authentication gets disabled and you will only be able to login using Azure AD accounts.')
param azureActiveDirectoryOnlyAuthentication bool = false

@description('Principal Type of the Azure AD sever administrator.')
@allowed([
  'Application'
  'Group'
  'User'
])
param azureActiveDirectoryAdminPrincipalType string = 'User'

@description('The username for the administrator using SQL Authentication. Once created it cannot be changed.')
param sqlAuthenticationAdminUsername string = ''

@secure()
@description('The password for the administrator using SQL Authentication (required for server creation).')
param sqlAuthenticationAdminPassword string

@description('Provide an array of e-mailaddresses (strings) where the vulnerability reports should be sent to.')
param vulnerabilityScanEmails array = []

@description('The resource name of the storage account to be used for the vulnerabilityscans. This storage account should be pre-existing.')
@minLength(3)
@maxLength(24)
param vulnerabilityScanStorageAccountName string

@description('''
Array of strings containing resource id\'s of the subnets you want to whitelist on this SQL Server.

For example:
[
  '/subscriptions/$(SubscriptionId)/resourceGroups/$(ResourceGroupName)/providers/Microsoft.Network/virtualNetworks/$(VirtualNetworkName)/subnets/$(SubnetName)'
  '/subscriptions/$(SubscriptionId)/resourceGroups/$(ResourceGroupName)/providers/Microsoft.Network/virtualNetworks/$(VirtualNetworkName)/subnets/$(SubnetName)'
]
''')
param subnetResourceIdsToWhitelist array = []

@description('The identity running this SQL server. This is a managed identity. Defaults to a system assigned managed identity. For object formatting & options, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.sql/servers?pivots=deployment-language-bicep#resourceidentity.')
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

// TODO: Lots of hardcoded stuff
@description('Upsert the SQL Server, vnet whitelisting rules, security assessments, alertpolicies, auditsettings & vulnerability scans with the passed parameters')
resource sqlServer 'Microsoft.Sql/servers@2021-11-01-preview' = {
  name: sqlServerName
  location: location
  tags: tags
  properties: {
    administratorLogin: sqlAuthenticationAdminUsername
    administratorLoginPassword: sqlAuthenticationAdminPassword
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
    restrictOutboundNetworkAccess: 'Disabled'
    administrators: {
      administratorType: 'ActiveDirectory'
      tenantId: subscription().tenantId
      principalType: azureActiveDirectoryAdminPrincipalType
      azureADOnlyAuthentication: azureActiveDirectoryOnlyAuthentication
      login: azureActiveDirectoryAdminUserName
      sid: azureActiveDirectoryAdminObjectId
    }
  }
  identity: identity

  resource sqlVnetRules 'virtualNetworkRules@2021-11-01-preview' = [for subnetId in subnetResourceIdsToWhitelist: if (!empty(subnetResourceIdsToWhitelist)) {
    name: 'allowsubnet-${subnetId}'
    properties: {
      ignoreMissingVnetServiceEndpoint: false
      virtualNetworkSubnetId: subnetId
    }
  }]

  resource sqlServerAdvancedSecurityAssessment 'securityAlertPolicies@2021-08-01-preview' = {
    name: 'advancedSecurityAssessment'
    properties: {
      state: 'Enabled'
    }
  }

  resource sqlAudit 'auditingSettings@2021-08-01-preview' = {
    name: 'default'
    properties: {
      auditActionsAndGroups: [
        'BATCH_COMPLETED_GROUP'
        'SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP'
        'FAILED_DATABASE_AUTHENTICATION_GROUP'
      ]
      isAzureMonitorTargetEnabled: true
      state: 'Enabled'
    }
  }

  resource sqlVulnerability 'vulnerabilityAssessments@2021-08-01-preview' = {
    name: 'default'
    properties: {
      recurringScans: {
        emails: vulnerabilityScanEmails
        isEnabled: true
      }
      storageContainerPath: '${vulnerabilityScanStorageAccount.properties.primaryEndpoints.blob}${vulnerabilityScanStorageAccount::vulnerabilityScanStorageAccountBlobService::vulnerabilityScanStorageAccountBlobContainer.name}'
    }

    dependsOn: [
      sqlServerAdvancedSecurityAssessment
    ]
  }
}

@description('Upsert the storageaccount & blob container with the given parameters.')
resource vulnerabilityScanStorageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: vulnerabilityScanStorageAccountName
  kind: 'StorageV2'
  location: location
  tags: tags
  sku: {
    name: 'Standard_LRS'
  }

  resource vulnerabilityScanStorageAccountBlobService 'blobServices@2021-08-01' = {
    name: 'default'

    resource vulnerabilityScanStorageAccountBlobContainer 'containers@2021-08-01' = {
      name: 'vulnerabilityscans'
    }
  }
}

@description('Output the storage account resource name where the vulnerability scan reports are stored for this SQL Server.')
output vulnerabilityScanStorageAccountName string = vulnerabilityScanStorageAccount.name
@description('Output the name of the SQL Server.')
output sqlServerName string = sqlServer.name
@description('Output the resource ID of the SQL Server.')
output sqlServerResourceId string = sqlServer.id
@description('Output the principal id for the identity of this SQL Server.')
output sqlServerIdentityPrincipalId string = sqlServer.identity.principalId
