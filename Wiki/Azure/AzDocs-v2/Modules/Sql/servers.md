# servers

Target Scope: resourceGroup

## User Defined Types
| Name | Type | Discriminator | Description
| -- |  -- | -- | -- |
| <a id="sqlServerFirewallRuleType">sqlServerFirewallRuleType</a>  | <pre>{<br>&nbsp;&nbsp;&nbsp;@description('The name of the firewall rule.')<br>&nbsp;&nbsp;&nbsp;name: string<br><br>&nbsp;&nbsp;&nbsp;@description('The starting IPv4 address for the firewall rule.')<br>&nbsp;&nbsp;&nbsp;start: string<br><br>&nbsp;&nbsp;&nbsp;@description('The ending IPv4 address for the firewall rule.')<br>&nbsp;&nbsp;&nbsp;end: string<br>}<br></pre> |  | An array of IpAddress with start and end.  If you would use 0.0.0.0 as start and end ipaddress you would allow every Azure services and resources on your sql server (also from other Azure subscriptions). Example {     name: 'myrulename'     start: '12.34.56.78'     end: '12.34.56.78'   }   {     name: 'AllowAzureServices'     start: '0.0.0.0'     end: '0.0.0.0'   } | 

## Synopsis
Creating a base Azure SQL server

## Description
Creating a SQL server with only base requirements. Advanced capabilities can be deployed with dedicated modules in a main.bicep.<br>
A hidden SQL Database resource called master is automatically created.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location. |
| sqlServerName | string | <input type="checkbox" checked> | Length between 1-63 | <pre></pre> | The resourcename of the SQL Server upsert. |
| useAzureActiveDirectoryAuthentication | bool | <input type="checkbox"> | None | <pre>false</pre> | Switch if you want to use Azure Active Directory Authentication (next to SQL authentication).<br>When set to true, fill the related Entra ID parameters below. |
| azureActiveDirectoryAdminObjectId | string | <input type="checkbox"> | Length is 36 | <pre>'00000000-0000-0000-0000-000000000000'</pre> | If you want to enable an AAD administrator for this SQL Server, you need to pass the Azure AD Object ID of the principal in this parameter. |
| azureActiveDirectoryAdminUserName | string | <input type="checkbox"> | None | <pre>azureActiveDirectoryAdminObjectId</pre> | A name for the EntraID login when choosing Azure Active Directory authentication. |
| azureActiveDirectoryOnlyAuthentication | bool | <input type="checkbox"> | None | <pre>false</pre> | If this is enabled, SQL authentication gets disabled and you will only be able to login using Azure AD accounts. |
| azureActiveDirectoryAdminPrincipalType | string | <input type="checkbox"> | `'Application'` or `'Group'` or `'User'` | <pre>'User'</pre> | Principal Type of the Azure AD server administrator. |
| sqlAuthenticationAdminUsername | string | <input type="checkbox"> | None | <pre>''</pre> | The username for the SQL authentication administrator. Once created it cannot be changed. Pass an empty string when using Entra ID only authentication. |
| sqlAuthenticationAdminPassword | string | <input type="checkbox"> | None | <pre>''</pre> | The password for the SQL authentication administrator. Pass an empty string when using Entra ID only authentication. Azure SQL enforces [password complexity](https://learn.microsoft.com/en-us/sql/relational-databases/security/password-policy?view=sql-server-ver16#password-complexity). |
| subnetResourceIdsToWhitelist | array | <input type="checkbox"> | None | <pre>[]</pre> | Array of strings containing resource id\'s of the subnets you want to whitelist on this SQL Server.<br>For example:<br>[<br>&nbsp;&nbsp;&nbsp;'/subscriptions/az.subscription().subscriptionId/resourceGroups/az.resourceGroup().name/providers/Microsoft.Network/virtualNetworks/myfirstvnet/subnets/mysubnetname'<br>&nbsp;&nbsp;&nbsp;'/subscriptions/az.subscription().subscriptionId/resourceGroups/az.resourceGroup().name/providers/Microsoft.Network/virtualNetworks/myfirstvnet/subnets/mysubnetname'<br>] |
| ignoreMissingVnetServiceEndpoint | bool | <input type="checkbox"> | None | <pre>false</pre> | If you want to create the firewall rule before the virtual network has vnet service endpoint enabled towards sql. |
| existingUserAssignedManagedIdentityResourceId | string | <input type="checkbox"> | None | <pre>''</pre> | Optional resource ID of an existing user assigned managed identity to attach to this SQL server. |
| sqlServerprimaryUserAssignedIdentityId | string | <input type="checkbox"> | None | <pre>existingUserAssignedManagedIdentityResourceId</pre> | Optional resource ID of the primary user assigned managed identity. Defaults to the existing UAMI resource ID when one is provided. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| sqlServerMinimalTlsVersion | string | <input type="checkbox"> | `'None'` or `'1.0'` or `'1.1'` or `'1.2'` or `'1.3'` | <pre>'1.2'</pre> | Set the minimum TLS version to be permitted on requests to the sqlserver. Use `None` to allow all versions. |
| sqlServerPublicNetworkAccess | string | <input type="checkbox"> | `'Enabled'` or `'Disabled'` or `'SecuredByPerimeter'` | <pre>'Enabled'</pre> | Whether or not public endpoint access is allowed for this server. Value is optional but if passed in, must be `Enabled`, `Disabled`, or `SecuredByPerimeter`. |
| sqlServerRestrictOutboundNetworkAccess | string | <input type="checkbox"> | `'Enabled'` or `'Disabled'` | <pre>'Disabled'</pre> | Whether or not to restrict outbound network access for this server. Value is optional but if passed in, must be `Enabled` or `Disabled` |
| sqlServerVersion | string | <input type="checkbox"> | None | <pre>'12.0'</pre> | The version of the sql server. |
| sqlServerFirewallRules | [sqlServerFirewallRuleType](#sqlServerFirewallRuleType)[] | <input type="checkbox"> | None | <pre>[]</pre> |  |
| sqlServerEncryptionKeyKeyvaultUri | string | <input type="checkbox"> | None | <pre>''</pre> | A CMK URI of the key to use for encryption. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| sqlServerName | string | Output the name of the SQL Server. |
| sqlServerResourceId | string | Output the resource ID of the SQL Server. |
| sqlServerIdentityPrincipalId | string | Output the principal id for the identity of this SQL Server. |
| fullyQualifiedDomainName | string | Output the fully qualified domain name of the SQL Server. |

## Examples
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

## Links
- [Bicep Microsoft.SQL servers](https://learn.microsoft.com/en-us/azure/templates/microsoft.sql/servers?pivots=deployment-language-bicep)<br>
- [Bicep Microsoft SQL Azure Active Directory Authentication](https://learn.microsoft.com/en-us/azure/templates/microsoft.sql/servers?pivots=deployment-language-bicep#serverexternaladministrator)
