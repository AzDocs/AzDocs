# servers

Target Scope: resourceGroup

## Synopsis
Creating a base Azure SQL server

## Description
Creates a SQL server with only base requirements.

This module intentionally excludes coupled resources such as vulnerability assessment storage, auditing resources, and role assignments. Those concerns should be deployed through dedicated modules so you can compose only what you need.

Use these dedicated modules for optional features:
- `sql/servers/securityAlertPolicies.bicep`
- `sql/servers/auditingSettings.bicep`
- `sql/servers/vulnerabilityAssessmentStorage.bicep`
- `sql/servers/vulnerabilityAssessments.bicep`

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location. |
| sqlServerName | string | <input type="checkbox" checked> | Length between 1-63 | <pre></pre> | The resourcename of the SQL Server upsert. |
| sqlServerAdministratorType | string | <input type="checkbox"> | 'ActiveDirectory' | <pre>'ActiveDirectory'</pre> | Type of the server administrator. |
| useAzureActiveDirectoryAuthentication | bool | <input type="checkbox"> | None | <pre>false</pre> | Enables Entra ID administrator configuration in addition to SQL authentication. |
| azureActiveDirectoryAdminObjectId | string | <input type="checkbox"> | Length is 36 | <pre>'00000000-0000-0000-0000-000000000000'</pre> | Object ID of the Entra ID administrator principal. |
| azureActiveDirectoryAdminUserName | string | <input type="checkbox"> | None | <pre>azureActiveDirectoryAdminObjectId</pre> | Login name for the Entra ID administrator. |
| azureActiveDirectoryOnlyAuthentication | bool | <input type="checkbox"> | None | <pre>false</pre> | If true, SQL authentication is disabled and Entra ID authentication is required. |
| azureActiveDirectoryAdminPrincipalType | string | <input type="checkbox"> | 'Application' or 'Group' or 'User' | <pre>'User'</pre> | Principal type for the Entra ID administrator. |
| sqlAuthenticationAdminUsername | string | <input type="checkbox"> | None | <pre>''</pre> | Username for SQL authentication administrator. Leave empty when Entra ID only authentication is enabled. |
| sqlAuthenticationAdminPassword | string | <input type="checkbox"> | None | <pre>''</pre> | Password for SQL authentication administrator. Leave empty when Entra ID only authentication is enabled. |
| subnetResourceIdsToWhitelist | array | <input type="checkbox"> | None | <pre>[]</pre> | Array of subnet resource IDs to allow through SQL virtual network rules. |
| ignoreMissingVnetServiceEndpoint | bool | <input type="checkbox"> | None | <pre>false</pre> | Create virtual network rules before service endpoints are enabled on the subnet. |
| createSqlUserAssignedManagedIdentity | bool | <input type="checkbox"> | None | <pre>false</pre> | Determines if a user assigned managed identity should be created for this SQL server. |
| userAssignedManagedIdentityName | string | <input type="checkbox"> | None | <pre>'id-${sqlServerName}'</pre> | Name of the user assigned managed identity to create. |
| sqlServerprimaryUserAssignedIdentityId | string | <input type="checkbox"> | None | <pre>(createSqlUserAssignedManagedIdentity)</pre> | Optional primary user-assigned managed identity resource ID. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | Tags to apply to this resource. |
| sqlServerMinimalTlsVersion | string | <input type="checkbox"> | '1.0' or '1.1' or '1.2' | <pre>'1.2'</pre> | Minimum TLS version for the SQL server. |
| sqlServerPublicNetworkAccess | string | <input type="checkbox"> | 'Enabled' or 'Disabled' | <pre>'Enabled'</pre> | Whether public endpoint access is allowed for this server. |
| sqlServerRestrictOutboundNetworkAccess | string | <input type="checkbox"> | 'Enabled' or 'Disabled' | <pre>'Disabled'</pre> | Whether outbound network access is restricted for this server. |
| sqlServerVersion | string | <input type="checkbox"> | None | <pre>'12.0'</pre> | SQL server version. |
| sqlServerFirewallRules | array | <input type="checkbox"> | None | <pre>[]</pre> | Optional array of firewall rules in { name, start, end } format. |
| sqlServerEncryptionKeyKeyvaultUri | string | <input type="checkbox"> | None | <pre>''</pre> | Optional CMK URI for server encryption. |

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
  name: format('{0}-{1}', take('${deployment().name}', 57), 'sqlserver')
  params: {
    tags: tags
    location: location
    sqlAuthenticationAdminPassword: 'SuperSecretPassword123!'
    sqlServerName: sqlServerName
    sqlAuthenticationAdminUsername: 'dbaisdba'
  }
}
</pre>
<p>Creates a base SQL server with SQL authentication.</p>

<pre>
module sqlserver 'br:contosoregistry.azurecr.io/sql/servers.bicep:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 60), 'sql')
  params: {
    sqlAuthenticationAdminPassword: ''
    location: location
    sqlAuthenticationAdminUsername: ''
    sqlServerName: sqlServerName
    useAzureActiveDirectoryAuthentication: true
    azureActiveDirectoryAdminObjectId: 'a348f815-0d14-4a85-b2fe-d3b36519e4fg'
    azureActiveDirectoryAdminUserName: 'admin@contoso.com'
    azureActiveDirectoryOnlyAuthentication: true
  }
}
</pre>
<p>Creates a base SQL server with Entra ID authentication only.</p>

## Links
- [Bicep Microsoft.SQL servers](https://learn.microsoft.com/en-us/azure/templates/microsoft.sql/servers?pivots=deployment-language-bicep)<br>
- [Bicep Microsoft SQL Azure Active Directory Authentication](https://learn.microsoft.com/en-us/azure/templates/microsoft.sql/servers?pivots=deployment-language-bicep#serverexternaladministrator)
