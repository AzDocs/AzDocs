/*
.SYNOPSIS
Creating a SQL server
.DESCRIPTION
Creating a SQL server with the given specs.
.EXAMPLE
<pre>
module sql 'br:contosoregistry.azurecr.io/sql/servers.bicep:latest' = {
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

@description('''
Switch if you want to use Azure Active Directory Authentication (next to SQL authentication).
When set to true, you need to fill the param azureActiveDirectoryLogin below with all correct values.
Explanation is with the single params within this param.
''')
param useAzureActiveDirectoryAuthentication bool = false

@description('If you want to enable an AAD administrator for this SQL Server, you need to pass the Azure AD Object ID of the principal in this parameter.')
@minLength(36)
@maxLength(36)
param azureActiveDirectoryAdminObjectId string = '00000000-0000-0000-0000-000000000000'

@description('A name for the EntraID login when choosing Azure Active Directory authentication.')
param azureActiveDirectoryAdminUserName string = azureActiveDirectoryAdminObjectId

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
If you want to use Azure Active Directory authentication, you need to completely fill this object with correct values.
See the [docs](https://learn.microsoft.com/en-us/azure/templates/microsoft.sql/servers?pivots=deployment-language-bicep#serverexternaladministrator) for what to fill in. Make sure to combine it with the param userAADLogin to true.
''')
var azureActiveDirectoryLogin = {
  administratorType: sqlServerAdministratorType
  tenantId: subscription().tenantId
  principalType: azureActiveDirectoryAdminPrincipalType
  azureADOnlyAuthentication: azureActiveDirectoryOnlyAuthentication
  login: azureActiveDirectoryAdminUserName
  sid: azureActiveDirectoryAdminObjectId
}

@description('''
The username for the administrator using SQL Authentication. Once created it cannot be changed.
If you opted for EntraID only authentication, this param can be given an empty ('') value.
You can choose for EntraID only authentication by setting the param azureActiveDirectoryOnlyAuthentication to true.
''')
param sqlAuthenticationAdminUsername string

@secure()
@description('''
The password for the administrator using SQL Authentication (required for server creation).
Azure SQL enforces [password complexity](https://learn.microsoft.com/en-us/sql/relational-databases/security/password-policy?view=sql-server-ver16#password-complexity).
''')
param sqlAuthenticationAdminPassword string

@description('Provide an array of e-mailaddresses (strings) where the vulnerability reports should be sent to.')
param vulnerabilityScanEmails array = []

@description('The resource name of the storage account to be used for the vulnerabilityscans.')
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

@description('Determines if a user assigned managed identity should be created for this SQL server.')
param createSqlUserAssignedManagedIdentity bool = false

@description('The name of the user assigned managed identity to create for this SQL server.')
param userAssignedManagedIdentityName string = 'id-${sqlServerName}'

@description('''
If you are using more that one user assigned managed identity, you can choose which one will be the primary user assigned managed identity.
Example
'${subscription().id}/resourceGroups/${resourceGroup().name}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/${userAssignedManagedIdentityName}'
''')
param sqlServerprimaryUserAssignedIdentityId string = (createSqlUserAssignedManagedIdentity) ? '${subscription().id}/resourceGroups/${resourceGroup().name}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/${userAssignedManagedIdentityName}' : ''

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
param sqlServerFirewallRules array = []

@description('A CMK URI of the key to use for encryption.')
param sqlServerEncryptionKeyKeyvaultUri string = ''

@description('Specifies whether audit events are sent to Azure Monitor.')
param auditingSettingsIsAzureMonitorTargetEnabled bool = true

@description('''
One or more managed identities running this SQL server. Defaults to a system assigned managed identity. 
When one or more user-assigned managed identities are assigned to the server, designate one of those as the primary or default identity for the server.
''')
var identity = (createSqlUserAssignedManagedIdentity) ? {
  type: 'SystemAssigned,UserAssigned'
  userAssignedIdentities: {
    '${sqlServerUserAssignedManagedIdentity.id}': {}
  }
} : { type: 'SystemAssigned' }


// ================================================= Resources =================================================
resource sqlServerUserAssignedManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = if (createSqlUserAssignedManagedIdentity) {
  name: userAssignedManagedIdentityName
  location: location
}

@description('Upsert the SQL Server, vnet whitelisting rules, security assessments, alertpolicies, auditsettings & vulnerability scans with the passed parameters')
resource sqlServer 'Microsoft.Sql/servers@2023-05-01-preview' = {
  name: sqlServerName
  location: location
  tags: tags
  identity: identity
  properties: {
    administratorLogin: azureActiveDirectoryOnlyAuthentication ? null : sqlAuthenticationAdminUsername
    administratorLoginPassword: azureActiveDirectoryOnlyAuthentication ? null : sqlAuthenticationAdminPassword
    minimalTlsVersion: sqlServerMinimalTlsVersion
    publicNetworkAccess: sqlServerPublicNetworkAccess
    restrictOutboundNetworkAccess: sqlServerRestrictOutboundNetworkAccess
    version: sqlServerVersion
    administrators: useAzureActiveDirectoryAuthentication ? azureActiveDirectoryLogin : {}
    primaryUserAssignedIdentityId: sqlServerprimaryUserAssignedIdentityId
    keyId: !empty(sqlServerEncryptionKeyKeyvaultUri) ? sqlServerEncryptionKeyKeyvaultUri : null
  }

  resource sqlVnetRules 'virtualNetworkRules@2023-05-01-preview' = [for (subnetId, i) in subnetResourceIdsToWhitelist: if (!empty(subnetResourceIdsToWhitelist)) {
    name: 'subnet-${i}'
    properties: {
      ignoreMissingVnetServiceEndpoint: ignoreMissingVnetServiceEndpoint
      virtualNetworkSubnetId: subnetId
    }
  }]

  resource SqlServerAllowFirewall 'firewallRules@2023-05-01-preview' = [for rule in sqlServerFirewallRules: if (!empty(sqlServerFirewallRules)) {
    name: rule.name
    properties: {
      startIpAddress: rule.start
      endIpAddress: rule.end
    }
  }]

  resource sqlServerAdvancedSecurityAssessment 'securityAlertPolicies@2023-05-01-preview' = {
    name: 'advancedSecurityAssessment'
    properties: {
      state: 'Enabled'
    }
  }

  resource sqlServerAuditingSettings 'auditingSettings@2023-05-01-preview' = {
    name: 'default'
    properties: {
      auditActionsAndGroups: [
        'BATCH_COMPLETED_GROUP'
        'SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP'
        'FAILED_DATABASE_AUTHENTICATION_GROUP'
      ]
      state: 'Enabled'
      isAzureMonitorTargetEnabled: auditingSettingsIsAzureMonitorTargetEnabled
      storageEndpoint: vulnerabilityScanStorageAccount.properties.primaryEndpoints.blob
    }
  }

  resource devOpsAuditingSettings 'devOpsAuditingSettings@2023-05-01-preview' = {
    name: 'default'
    properties: {
      state: 'Enabled'
      isAzureMonitorTargetEnabled: auditingSettingsIsAzureMonitorTargetEnabled
      isManagedIdentityInUse: true
      storageEndpoint: vulnerabilityScanStorageAccount.properties.primaryEndpoints.blob
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
resource vulnerabilityScanStorageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: vulnerabilityScanStorageAccountName
  kind: 'StorageV2'
  location: location
  tags: tags
  sku: {
    name: 'Standard_LRS'
  }

  resource vulnerabilityScanStorageAccountBlobService 'blobServices@2023-01-01' = {
    name: 'default'

    resource vulnerabilityScanStorageAccountBlobContainer 'containers@2023-01-01' = {
      name: 'vulnerabilityscans'
    }
  }
}

module storageBlobDataContributorRoleAssignment '../Authorization/roleAssignmentsStorage.bicep' = {
  name: format('{0}-{1}', take('${deployment().name}', 51), 'roleassidstg')
  params: {
    storageAccountName: vulnerabilityScanStorageAccount.name
    roleDefinitionId: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe' //Storage Blob Data Contributor
    principalId: createSqlUserAssignedManagedIdentity ? sqlServer.identity.userAssignedIdentities[sqlServerUserAssignedManagedIdentity.id].principalId : sqlServer.identity.principalId
  }
}

@description('Output the storage account resource name where the vulnerability scan reports are stored for this SQL Server.')
output vulnerabilityScanStorageAccountName string = !empty(vulnerabilityScanStorageAccountName) ? vulnerabilityScanStorageAccount.name : ''
@description('Output the name of the SQL Server.')
output sqlServerName string = sqlServer.name
@description('Output the resource ID of the SQL Server.')
output sqlServerResourceId string = sqlServer.id
@description('Output the principal id for the identity of this SQL Server.')
output sqlServerIdentityPrincipalId string = sqlServer.identity.principalId
