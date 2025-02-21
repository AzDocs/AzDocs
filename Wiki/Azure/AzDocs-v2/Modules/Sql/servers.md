﻿# servers

Target Scope: resourceGroup

## Synopsis
Creating a SQL server

## Description
Creating a SQL server with the given specs.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location. |
| sqlServerName | string | <input type="checkbox" checked> | Length between 1-63 | <pre></pre> | The resourcename of the SQL Server upsert. |
| sqlServerAdministratorType | string | <input type="checkbox"> | `'ActiveDirectory'` | <pre>'ActiveDirectory'</pre> | Type of the server administrator. |
| useAzureActiveDirectoryAuthentication | bool | <input type="checkbox"> | None | <pre>false</pre> | Switch if you want to use Azure Active Directory Authentication (next to SQL authentication).<br>When set to true, you need to fill the param azureActiveDirectoryLogin below with all correct values.<br>Explanation is with the single params within this param. |
| azureActiveDirectoryAdminObjectId | string | <input type="checkbox"> | Length is 36 | <pre>'00000000-0000-0000-0000-000000000000'</pre> | If you want to enable an AAD administrator for this SQL Server, you need to pass the Azure AD Object ID of the principal in this parameter. |
| azureActiveDirectoryAdminUserName | string | <input type="checkbox"> | None | <pre>azureActiveDirectoryAdminObjectId</pre> | A name for the EntraID login when choosing Azure Active Directory authentication. |
| azureActiveDirectoryOnlyAuthentication | bool | <input type="checkbox"> | None | <pre>false</pre> | If this is enabled, SQL authentication gets disabled and you will only be able to login using Azure AD accounts. |
| azureActiveDirectoryAdminPrincipalType | string | <input type="checkbox"> | `'Application'` or `'Group'` or `'User'` | <pre>'User'</pre> | Principal Type of the Azure AD server administrator. |
| sqlAuthenticationAdminUsername | string | <input type="checkbox" checked> | None | <pre></pre> | The username for the administrator using SQL Authentication. Once created it cannot be changed.<br>If you opted for EntraID only authentication, this param can be given an empty ('') value.<br>You can choose for EntraID only authentication by setting the param azureActiveDirectoryOnlyAuthentication to true. |
| sqlAuthenticationAdminPassword | string | <input type="checkbox" checked> | None | <pre></pre> | The password for the administrator using SQL Authentication (required for server creation).<br>Azure SQL enforces [password complexity](https://learn.microsoft.com/en-us/sql/relational-databases/security/password-policy?view=sql-server-ver16#password-complexity). |
| vulnerabilityScanEmails | array | <input type="checkbox"> | None | <pre>[]</pre> | Provide an array of e-mailaddresses (strings) where the vulnerability reports should be sent to. |
| enableVulnerabilityAssessment | bool | <input type="checkbox"> | None | <pre>true</pre> | Enable Vulnerability Assessment on this SQL Server. |
| vulnerabilityScanStorageAccountName | string | <input type="checkbox" checked> | Length between 3-24 | <pre></pre> | The resource name of the storage account to be used for the vulnerabilityscans. |
| subnetResourceIdsToWhitelist | array | <input type="checkbox"> | None | <pre>[]</pre> | Array of strings containing resource id\'s of the subnets you want to whitelist on this SQL Server.<br>For example:<br>[<br>&nbsp;&nbsp;&nbsp;'/subscriptions/az.subscription().subscriptionId/resourceGroups/az.resourceGroup().name/providers/Microsoft.Network/virtualNetworks/myfirstvnet/subnets/mysubnetname'<br>&nbsp;&nbsp;&nbsp;'/subscriptions/az.subscription().subscriptionId/resourceGroups/az.resourceGroup().name/providers/Microsoft.Network/virtualNetworks/myfirstvnet/subnets/mysubnetname'<br>] |
| ignoreMissingVnetServiceEndpoint | bool | <input type="checkbox"> | None | <pre>false</pre> | If you want to create the firewall rule before the virtual network has vnet service endpoint enabled towards sql. |
| createSqlUserAssignedManagedIdentity | bool | <input type="checkbox"> | None | <pre>false</pre> | Determines if a user assigned managed identity should be created for this SQL server. |
| userAssignedManagedIdentityName | string | <input type="checkbox"> | None | <pre>'id-&#36;{sqlServerName}'</pre> | The name of the user assigned managed identity to create for this SQL server. |
| sqlServerprimaryUserAssignedIdentityId | string | <input type="checkbox"> | None | <pre>(createSqlUserAssignedManagedIdentity)</pre> | If you are using more that one user assigned managed identity, you can choose which one will be the primary user assigned managed identity.<br>Example<br>'&#36;{subscription().id}/resourceGroups/&#36;{resourceGroup().name}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/&#36;{userAssignedManagedIdentityName}' |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| sqlServerMinimalTlsVersion | string | <input type="checkbox"> | `'1.0'` or `'1.1'` or `'1.2'` | <pre>'1.2'</pre> | Set the minimum TLS version to be permitted on requests to the sqlserver. |
| sqlServerPublicNetworkAccess | string | <input type="checkbox"> | `'Enabled'` or `'Disabled'` | <pre>'Enabled'</pre> | Whether or not public endpoint access is allowed for this server. Value is optional but if passed in, must be `Enabled` or `Disabled` |
| sqlServerRestrictOutboundNetworkAccess | string | <input type="checkbox"> | `'Enabled'` or `'Disabled'` | <pre>'Disabled'</pre> | Whether or not to restrict outbound network access for this server. Value is optional but if passed in, must be `Enabled` or `Disabled` |
| sqlServerVersion | string | <input type="checkbox"> | None | <pre>'12.0'</pre> | The version of the sql server. |
| sqlServerFirewallRules | array | <input type="checkbox"> | None | <pre>[]</pre> | An array of IpAddress with start and end. If you would use 0.0.0.0 as start and end ipaddress you would virtually allow every Azure resource on your sql.<br>Example<br>{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;name: 'myrulename'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;start: '12.34.56.78'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;end: '12.34.56.78'<br>&nbsp;&nbsp;&nbsp;}<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;name: 'AllowEveryAzureResource'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;start: '0.0.0.0'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;end: '0.0.0.0'<br>&nbsp;&nbsp;&nbsp;} |
| sqlServerEncryptionKeyKeyvaultUri | string | <input type="checkbox"> | None | <pre>''</pre> | A CMK URI of the key to use for encryption. |
| auditingSettingsIsAzureMonitorTargetEnabled | bool | <input type="checkbox"> | None | <pre>true</pre> | Specifies whether audit events are sent to Azure Monitor. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| vulnerabilityScanStorageAccountName | string | Output the storage account resource name where the vulnerability scan reports are stored for this SQL Server. |
| sqlServerName | string | Output the name of the SQL Server. |
| sqlServerResourceId | string | Output the resource ID of the SQL Server. |
| sqlServerIdentityPrincipalId | string | Output the principal id for the identity of this SQL Server. |
| fullyQualifiedDomainName | string | Output the fully qualified domain name of the SQL Server. |

## Examples
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
<pre>
module sqlserver 'br:contosoregistry.azurecr.io/sql/servers.bicep:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 60), 'sql')
  params: {
    sqlAuthenticationAdminPassword: ''
    location: location
    sqlAuthenticationAdminUsername: ''
    sqlServerName: sqlServerName
    useAzureActiveDirectoryAuthentication: true
    vulnerabilityScanStorageAccountName: vulnerabilityScanStorageAccountName
    azureActiveDirectoryAdminObjectId: 'a348f815-0d14-4a85-b2fe-d3b36519e4fg'
    azureActiveDirectoryOnlyAuthentication: true
    createSqlUserAssignedManagedIdentity: true
  }
}
</pre>
<p>Creates a Sql server with EntraID authentication only.</p>

## Links
- [Bicep Microsoft.SQL servers](https://learn.microsoft.com/en-us/azure/templates/microsoft.sql/servers?pivots=deployment-language-bicep)<br>
- [Bicep Microsoft SQL Azure Active Directory Authentication](https://learn.microsoft.com/en-us/azure/templates/microsoft.sql/servers?pivots=deployment-language-bicep#serverexternaladministrator)
