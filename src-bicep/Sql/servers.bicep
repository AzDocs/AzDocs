/*
.SYNOPSIS
Creating a SQL server
.DESCRIPTION
Creating a SQL server with the given specs.
.EXAMPLE
<pre>
module sql 'br:acrazdocsprd.azurecr.io/sql/servers.bicep:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 57), 'sqlserver')
  params: {
    tags: tags
    location: location
    sqlAuthenticationAdminPassword: <<password>>
    sqlServerName: sqlServerName
    vulnerabilityScanStorageAccountName: sqlStorageAccountName
    subnetResourceIdsToWhitelist: subnetResourceIdsToWhitelist
    sqlAuthenticationAdminUsername: 'dbaisdba'
    azureActiveDirectoryAdminObjectId: '00000000-0000-0000-0000-00000000000'
    azureActiveDirectoryAdminUserName: 'name@tenant.com'
  }
}
</pre>
<p>Creates a Sql server with the name sqlServerName</p>
.LINKS
- [Bicep Microsoft.SQL servers](https://learn.microsoft.com/en-us/azure/templates/microsoft.sql/servers?pivots=deployment-language-bicep)
- [Bicep Microsoft SQL Azure Active Directory Authentication](https://learn.microsoft.com/en-us/azure/templates/microsoft.sql/servers?pivots=deployment-language-bicep#serverexternaladministrator)
*/

// ================================================= Parameters =================================================
@description('Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location.')
param location string = resourceGroup().location

@description('The resourcename of the SQL Server upsert.')
@minLength(1)
@maxLength(63)
param sqlServerName string

@description('Type of the server administrator.')
@allowed([
  'ActiveDirectory'
])
param sqlServerAdministratorType string = 'ActiveDirectory'

@description('If you want to enable an AAD administrator for this SQL Server, you need to pass the Azure AD Object ID of the principal in this parameter.')
@minLength(36)
@maxLength(36)
param azureActiveDirectoryAdminObjectId string = '00000000-0000-0000-0000-000000000000'

@description('Login name of the server administrator when using optionally Azure Active Directory authentication.')
param azureActiveDirectoryAdminUserName string = ''

@description('If this is enabled, SQL authentication gets disabled and you will only be able to login using Azure AD accounts.')
param azureActiveDirectoryOnlyAuthentication bool = false

@description('Principal Type of the Azure AD server administrator.')
@allowed([
  'Application'
  'Group'
  'User'
])
param azureActiveDirectoryAdminPrincipalType string = 'User'

@description('''
Switch if you want to use Azure Active Directory Authentication (next to SQL authentication).
When set to true, you need to fill the param azureActiveDirectoryLogin below with all correct values.
Explanation is with the single params within this param.
''')
param useAADLogin bool = false

@description('''
If you want to use Azure Active Directory authentication, you need to completely fill this object with correct values.
See the [docs](https://learn.microsoft.com/en-us/azure/templates/microsoft.sql/servers?pivots=deployment-language-bicep#serverexternaladministrator) for what to fill in. Make sure to combine it with the param userAADLogin to true.
''')
var azureActiveDirectoryLogin  = {
  administratorType: sqlServerAdministratorType
  tenantId: subscription().tenantId
  principalType: azureActiveDirectoryAdminPrincipalType
  azureADOnlyAuthentication: azureActiveDirectoryOnlyAuthentication
  login: azureActiveDirectoryAdminUserName
  sid: azureActiveDirectoryAdminObjectId
}

@description('The username for the administrator using SQL Authentication. Once created it cannot be changed.')
param sqlAuthenticationAdminUsername string

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
  '/subscriptions/az.subscription().subscriptionId/resourceGroups/az.resourceGroup().name/providers/Microsoft.Network/virtualNetworks/myfirstvnet/subnets/mysubnetname'
  '/subscriptions/az.subscription().subscriptionId/resourceGroups/az.resourceGroup().name/providers/Microsoft.Network/virtualNetworks/myfirstvnet/subnets/mysubnetname'
]
''')
param subnetResourceIdsToWhitelist array = []

@description('If you want to create the firewall rule before the virtual network has vnet service endpoint enabled towards sql.')
param ignoreMissingVnetServiceEndpoint bool = false

@description('''
The identity running this SQL server. This is a managed identity. Defaults to a system assigned managed identity.
When one or more user-assigned managed identities are assigned to the server, designate one of those as the primary or default identity for the server.
When you use a user-assigned managed identity and are using vulnerabilityscans, make sure the identity has sufficient permissions on the storage account.
For object formatting & options, please refer to [the docs](https://learn.microsoft.com/en-us/azure/templates/microsoft.sql/servers?pivots=deployment-language-bicep#resourceidentity).
''')
param identity object = {
  type: 'SystemAssigned'
}

@description('''
If you are using a user assigned managed identity, you need to choose which one will be the primary user assigned managed identity.
Example
'${subscription().id}/resourcegroups/az.resourceGroup().name/providers/Microsoft.ManagedIdentity/userAssignedIdentities/usermanidexample'
''')
param sqlServerprimaryUserAssignedIdentityId string = ''

@description('''
The tags to apply to this resource. This is an object with key/value pairs.
Example:
{
  FirstTag: myvalue
  SecondTag: another value
}
''')
param tags object = {}

@description('Set the minimum TLS version to be permitted on requests to the sqlserver.')
@allowed([
  '1.0'
  '1.1'
  '1.2'
])
param sqlServerMinimalTlsVersion string = '1.2'

@description('Whether or not public endpoint access is allowed for this server. Value is optional but if passed in, must be `Enabled` or `Disabled`')
@allowed([
  'Enabled'
  'Disabled'
])
param sqlServerPublicNetworkAccess string = 'Enabled'

@description('Whether or not to restrict outbound network access for this server. Value is optional but if passed in, must be `Enabled` or `Disabled`')
@allowed([
  'Enabled'
  'Disabled'
])
param sqlServerRestrictOutboundNetworkAccess string = 'Disabled'

@description('The version of the sql server.')
param sqlServerVersion string = '12.0'

@description('''
An array of IpAddress with start and end. If you would use 0.0.0.0 as start and end ipaddress you would virtually allow every Azure resource on your sql.
Example
{
    name: 'myrulename'
    start: '12.34.56.78'
    end: '12.34.56.78'
  }
  {
    name: 'AllowEveryAzureResource'
    start: '0.0.0.0'
    end: '0.0.0.0'
  }
''')
param sqlFirewallRules array = []

@description('Upsert the SQL Server, vnet whitelisting rules, security assessments, alertpolicies, auditsettings & vulnerability scans with the passed parameters')
resource sqlServer 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: sqlServerName
  location: location
  tags: tags
  properties: {
    administratorLogin: sqlAuthenticationAdminUsername
    administratorLoginPassword: sqlAuthenticationAdminPassword
    minimalTlsVersion: sqlServerMinimalTlsVersion
    publicNetworkAccess: sqlServerPublicNetworkAccess
    restrictOutboundNetworkAccess: sqlServerRestrictOutboundNetworkAccess
    version: sqlServerVersion
    administrators: useAADLogin ? azureActiveDirectoryLogin : {}
    primaryUserAssignedIdentityId: sqlServerprimaryUserAssignedIdentityId
  }
  identity: identity

  resource sqlVnetRules 'virtualNetworkRules@2022-05-01-preview' =  [for (subnetId, i) in subnetResourceIdsToWhitelist: if (!empty(subnetResourceIdsToWhitelist)) {
    name: 'subnet-${i}'
    properties: {
      ignoreMissingVnetServiceEndpoint: ignoreMissingVnetServiceEndpoint
      virtualNetworkSubnetId: subnetId
    }
  }]

  resource SqlServerAllowFirewall 'firewallRules@2022-05-01-preview' = [for rule in sqlFirewallRules: if (!empty(sqlFirewallRules)){
    name: rule.name
    properties: {
      startIpAddress: rule.start
      endIpAddress: rule.end
    }
  }]

  resource sqlServerAdvancedSecurityAssessment 'securityAlertPolicies@2022-05-01-preview' = {
    name: 'advancedSecurityAssessment'
    properties: {
      state: 'Enabled'
    }
  }

  resource sqlAudit 'auditingSettings@2022-05-01-preview' = {
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

  resource sqlVulnerability 'vulnerabilityAssessments@2022-05-01-preview' = {
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
resource vulnerabilityScanStorageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: vulnerabilityScanStorageAccountName
  kind: 'StorageV2'
  location: location
  tags: tags
  sku: {
    name: 'Standard_LRS'
  }

  resource vulnerabilityScanStorageAccountBlobService 'blobServices@2022-09-01' = {
    name: 'default'

    resource vulnerabilityScanStorageAccountBlobContainer 'containers@2022-09-01' = {
      name: 'vulnerabilityscans'
    }
  }
}

@description('Output the storage account resource name where the vulnerability scan reports are stored for this SQL Server.')
output vulnerabilityScanStorageAccountName string = !empty(vulnerabilityScanStorageAccountName)? vulnerabilityScanStorageAccount.name: ''
@description('Output the name of the SQL Server.')
output sqlServerName string = sqlServer.name
@description('Output the resource ID of the SQL Server.')
output sqlServerResourceId string = sqlServer.id
@description('Output the principal id for the identity of this SQL Server.')
output sqlServerIdentityPrincipalId string = sqlServer.identity.principalId
