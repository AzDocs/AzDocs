# servers

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
| azureActiveDirectoryAdminObjectId | string | <input type="checkbox"> | Length is 36 | <pre>'00000000-0000-0000-0000-000000000000'</pre> | If you want to enable an AAD administrator for this SQL Server, you need to pass the Azure AD Object ID of the principal in this parameter. |
| azureActiveDirectoryAdminUserName | string | <input type="checkbox"> | None | <pre>''</pre> | Login name of the server administrator when using optionally Azure Active Directory authentication. |
| azureActiveDirectoryOnlyAuthentication | bool | <input type="checkbox"> | None | <pre>false</pre> | If this is enabled, SQL authentication gets disabled and you will only be able to login using Azure AD accounts. |
| azureActiveDirectoryAdminPrincipalType | string | <input type="checkbox"> | `'Application'` or  `'Group'` or  `'User'` | <pre>'User'</pre> | Principal Type of the Azure AD server administrator. |
| useAADLogin | bool | <input type="checkbox"> | None | <pre>false</pre> | Switch if you want to use Azure Active Directory Authentication (next to SQL authentication).<br>When set to true, you need to fill the param azureActiveDirectoryLogin below with all correct values.<br>Explanation is with the single params within this param. |
| sqlAuthenticationAdminUsername | string | <input type="checkbox" checked> | None | <pre></pre> | The username for the administrator using SQL Authentication. Once created it cannot be changed. |
| sqlAuthenticationAdminPassword | string | <input type="checkbox" checked> | None | <pre></pre> | The password for the administrator using SQL Authentication (required for server creation). |
| vulnerabilityScanEmails | array | <input type="checkbox"> | None | <pre>[]</pre> | Provide an array of e-mailaddresses (strings) where the vulnerability reports should be sent to. |
| vulnerabilityScanStorageAccountName | string | <input type="checkbox" checked> | Length between 3-24 | <pre></pre> | The resource name of the storage account to be used for the vulnerabilityscans. This storage account should be pre-existing. |
| subnetResourceIdsToWhitelist | array | <input type="checkbox"> | None | <pre>[]</pre> | Array of strings containing resource id\'s of the subnets you want to whitelist on this SQL Server.<br><br>For example:<br>[<br>&nbsp;&nbsp;&nbsp;'/subscriptions/az.subscription().subscriptionId/resourceGroups/az.resourceGroup().name/providers/Microsoft.Network/virtualNetworks/myfirstvnet/subnets/mysubnetname'<br>&nbsp;&nbsp;&nbsp;'/subscriptions/az.subscription().subscriptionId/resourceGroups/az.resourceGroup().name/providers/Microsoft.Network/virtualNetworks/myfirstvnet/subnets/mysubnetname'<br>] |
| ignoreMissingVnetServiceEndpoint | bool | <input type="checkbox"> | None | <pre>false</pre> | If you want to create the firewall rule before the virtual network has vnet service endpoint enabled towards sql. |
| identity | object | <input type="checkbox"> | None | <pre>{<br>  type: 'SystemAssigned'<br>}</pre> | The identity running this SQL server. This is a managed identity. Defaults to a system assigned managed identity.<br>When one or more user-assigned managed identities are assigned to the server, designate one of those as the primary or default identity for the server.<br>When you use a user-assigned managed identity and are using vulnerabilityscans, make sure the identity has sufficient permissions on the storage account.<br>For object formatting & options, please refer to [the docs](https://learn.microsoft.com/en-us/azure/templates/microsoft.sql/servers?pivots=deployment-language-bicep#resourceidentity). |
| sqlServerprimaryUserAssignedIdentityId | string | <input type="checkbox"> | None | <pre>''</pre> | If you are using a user assigned managed identity, you need to choose which one will be the primary user assigned managed identity.<br>Example<br>'&#36;{subscription().id}/resourcegroups/az.resourceGroup().name/providers/Microsoft.ManagedIdentity/userAssignedIdentities/usermanidexample' |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| sqlServerMinimalTlsVersion | string | <input type="checkbox"> | `'1.0'` or  `'1.1'` or  `'1.2'` | <pre>'1.2'</pre> | Set the minimum TLS version to be permitted on requests to the sqlserver. |
| sqlServerPublicNetworkAccess | string | <input type="checkbox"> | `'Enabled'` or  `'Disabled'` | <pre>'Enabled'</pre> | Whether or not public endpoint access is allowed for this server. Value is optional but if passed in, must be `Enabled` or `Disabled` |
| sqlServerRestrictOutboundNetworkAccess | string | <input type="checkbox"> | `'Enabled'` or  `'Disabled'` | <pre>'Disabled'</pre> | Whether or not to restrict outbound network access for this server. Value is optional but if passed in, must be `Enabled` or `Disabled` |
| sqlServerVersion | string | <input type="checkbox"> | None | <pre>'12.0'</pre> | The version of the sql server. |
| sqlFirewallRules | array | <input type="checkbox"> | None | <pre>[]</pre> | An array of IpAddress with start and end. If you would use 0.0.0.0 as start and end ipaddress you would virtually allow every Azure resource on your sql.<br>Example<br>{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;name: 'myrulename'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;start: '12.34.56.78'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;end: '12.34.56.78'<br>&nbsp;&nbsp;&nbsp;}<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;name: 'AllowEveryAzureResource'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;start: '0.0.0.0'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;end: '0.0.0.0'<br>&nbsp;&nbsp;&nbsp;} |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| vulnerabilityScanStorageAccountName | string | Output the storage account resource name where the vulnerability scan reports are stored for this SQL Server. |
| sqlServerName | string | Output the name of the SQL Server. |
| sqlServerResourceId | string | Output the resource ID of the SQL Server. |
| sqlServerIdentityPrincipalId | string | Output the principal id for the identity of this SQL Server. |
## Examples
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

## Links
- [Bicep Microsoft.SQL servers](https://learn.microsoft.com/en-us/azure/templates/microsoft.sql/servers?pivots=deployment-language-bicep)<br>
- [Bicep Microsoft SQL Azure Active Directory Authentication](https://learn.microsoft.com/en-us/azure/templates/microsoft.sql/servers?pivots=deployment-language-bicep#serverexternaladministrator)


