metadata name = 'SQL Servers'
metadata description = 'This module deploys a base Azure SQL server.'

/*
.SYNOPSIS
Creating a base Azure SQL server
.DESCRIPTION
Creating a SQL server with only base requirements. Advanced capabilities can be deployed with dedicated modules in a main.bicep.
A hidden SQL Database resource called master is automatically created.
.EXAMPLE
<pre>
module sql 'br:contosoregistry.azurecr.io/sql/servers.bicep:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 54), 'sqlserver')
  params: {
    sqlAuthenticationAdminPassword: <<password>>
    sqlServerName: 'sqlServerName01'
    sqlAuthenticationAdminUsername: 'dbaisdba'
  }
}
</pre>
<p>Creates a base SQL server with SQL authentication with public network access closed and a system assigned identity.</p>
<pre>
module sql 'br:contosoregistry.azurecr.io/sql/servers.bicep:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 54), 'sqlserver')
  params: {
    location: 'swedencentral'
    sqlAuthenticationAdminPassword: <<password>>
    sqlServerName: 'sqlServerName01'
    sqlAuthenticationAdminUsername: 'dbaisdba'
    sqlServerFirewallRules: [
      {
        name: 'AllowBuildAgent'
        start: '12.34.56.78'
        end: '12.34.56.78'
      }
    ]
  }
}
</pre>
<p>Creates a base SQL server with SQL authentication and optional firewall rules.</p>
<pre>
module sqlserver 'br:contosoregistry.azurecr.io/sql/servers.bicep:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 60), 'sql')
  params: {
    location: 'westeurope'
    sqlServerName: 'sqlServerName01'
    useAzureActiveDirectoryAuthentication: true
    azureActiveDirectoryAdminObjectId: 'a348f815-0d14-4a85-b2fe-d3b36519e4fg'
    azureActiveDirectoryOnlyAuthentication: true
  }
}
</pre>
<p>Creates a base SQL server with Entra ID authentication only.</p>
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

@description('''
Switch if you want to use Azure Active Directory Authentication (next to SQL authentication).
When set to true, fill the related Entra ID parameters below.
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

@description('Entra ID administrator configuration object, applied to the server when useAzureActiveDirectoryAuthentication is true.')
var azureActiveDirectoryLogin = {
  administratorType: 'ActiveDirectory'
  tenantId: subscription().tenantId
  principalType: azureActiveDirectoryAdminPrincipalType
  azureADOnlyAuthentication: azureActiveDirectoryOnlyAuthentication
  login: azureActiveDirectoryAdminUserName
  sid: azureActiveDirectoryAdminObjectId
}

@description('The username for the SQL authentication administrator. Once created it cannot be changed. Pass an empty string when using Entra ID only authentication.')
param sqlAuthenticationAdminUsername string = ''

@description('The password for the SQL authentication administrator. Pass an empty string when using Entra ID only authentication. Azure SQL enforces [password complexity](https://learn.microsoft.com/en-us/sql/relational-databases/security/password-policy?view=sql-server-ver16#password-complexity).')
@secure()
param sqlAuthenticationAdminPassword string = ''

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

@description('Optional resource ID of an existing user assigned managed identity to attach to this SQL server.')
param existingUserAssignedManagedIdentityResourceId string = ''

@description('Optional resource ID of the primary user assigned managed identity. Defaults to the existing UAMI resource ID when one is provided.')
param sqlServerprimaryUserAssignedIdentityId string = existingUserAssignedManagedIdentityResourceId

@description('''
The tags to apply to this resource. This is an object with key/value pairs.
Example:
{
  FirstTag: myvalue
  SecondTag: another value
}
''')
param tags object = {}

@description('Set the minimum TLS version to be permitted on requests to the sqlserver. Use `None` to allow all versions.')
@allowed([
  'None'
  '1.0'
  '1.1'
  '1.2'
  '1.3'
])
param sqlServerMinimalTlsVersion string = '1.2'

@description('Whether or not public endpoint access is allowed for this server. Value is optional but if passed in, must be `Enabled`, `Disabled`, or `SecuredByPerimeter`.')
@allowed([
  'Enabled'
  'Disabled'
  'SecuredByPerimeter'
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
An array of IpAddress with start and end. 
If you would use 0.0.0.0 as start and end ipaddress you would allow every Azure services and resources on your sql server (also from other Azure subscriptions).
Example
{
    name: 'myrulename'
    start: '12.34.56.78'
    end: '12.34.56.78'
  }
  {
    name: 'AllowAzureServices'
    start: '0.0.0.0'
    end: '0.0.0.0'
  }
''')
param sqlServerFirewallRules array = []

@description('A CMK URI of the key to use for encryption.')
param sqlServerEncryptionKeyKeyvaultUri string = ''

@description('One or more managed identities for this SQL server. Attaches an existing user assigned managed identity when provided, otherwise defaults to system assigned only.')
var identity = !empty(existingUserAssignedManagedIdentityResourceId)
  ? {
      type: 'SystemAssigned,UserAssigned'
      userAssignedIdentities: {
        '${existingUserAssignedManagedIdentityResourceId}': {}
      }
    }
  : { type: 'SystemAssigned' }

// ================================================= Resources =================================================
@description('Upsert the SQL Server with base settings and optional network rules.')
resource sqlServer 'Microsoft.Sql/servers@2025-01-01' = {
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
    administrators: useAzureActiveDirectoryAuthentication ? azureActiveDirectoryLogin : null
    primaryUserAssignedIdentityId: !empty(sqlServerprimaryUserAssignedIdentityId) ? sqlServerprimaryUserAssignedIdentityId : null
    keyId: !empty(sqlServerEncryptionKeyKeyvaultUri) ? sqlServerEncryptionKeyKeyvaultUri : null
  }

  resource sqlVnetRules 'virtualNetworkRules@2025-01-01' = [
    for (subnetId, i) in subnetResourceIdsToWhitelist: if (!empty(subnetResourceIdsToWhitelist)) {
      name: 'subnet-${i}'
      properties: {
        ignoreMissingVnetServiceEndpoint: ignoreMissingVnetServiceEndpoint
        virtualNetworkSubnetId: subnetId
      }
    }
  ]

  resource SqlServerAllowFirewall 'firewallRules@2025-01-01' = [
    for rule in sqlServerFirewallRules: if (!empty(sqlServerFirewallRules)) {
      name: rule.name
      properties: {
        startIpAddress: rule.start
        endIpAddress: rule.end
      }
    }
  ]
}
@description('Output the name of the SQL Server.')
output sqlServerName string = sqlServer.name
@description('Output the resource ID of the SQL Server.')
output sqlServerResourceId string = sqlServer.id
@description('Output the principal id for the identity of this SQL Server.')
output sqlServerIdentityPrincipalId string = sqlServer.identity.principalId
@description('Output the fully qualified domain name of the SQL Server.')
output fullyQualifiedDomainName string = sqlServer.properties.fullyQualifiedDomainName
