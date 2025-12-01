# administrators

Target Scope: resourceGroup

## Synopsis
Adds or configures an Azure Database for MySQL Flexible Server EntraId (Active Directory) administrator.

## Description
This file declares the administrator resource for a MySQL flexible server. It can be used<br>
to create or update an EntraId (Azure AD) administrator on an existing flexible server.<br>
The server must exist already; this module targets the `administrators` child resource.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| mySqlFlexibleServerName | string | <input type="checkbox" checked> | None | <pre></pre> | Server Name for the existing Azure MySQL flexible server to which the administrator will be added. |
| administratorType | string | <input type="checkbox"> | None | <pre>'ActiveDirectory'</pre> | Administrator type. Must be "ActiveDirectory" for Entra ID administrators. |
| userAssignedIdentityResourceId | string | <input type="checkbox" checked> | None | <pre></pre> | The resourceId of the existing user-assigned managed identity that will perform directory operations. |
| tenantId | string | <input type="checkbox"> | None | <pre>tenant().tenantId</pre> | Optional. The tenant ID of the Entra ID (Azure AD) tenant. |
| entraIdAdminLogin | string | <input type="checkbox" checked> | None | <pre></pre> | The login name of the Entra ID (Azure AD) administrator (user principal name or service principal name). |
| entraIdAdminSid | string | <input type="checkbox" checked> | None | <pre></pre> | The object ID (SID) of the Entra ID (Azure AD) administrator (user or service principal). |

## Examples
<pre>
module mysqlServer 'br:contosoregistry.azurecr.io/dbformysql/flexibleservers/administrators:latest' = {
  name: '${deployment().name}-mysql'
  params: {
    serverName: 'my-mysql-server'
    administratorType: 'ActiveDirectory'
    login: 'admin@contoso.com'
    sid: 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'
    tenantId: subscription().tenantId
    identityResourceId: identityResourceId
  }
}
</pre>
Example usage with an existing server and user-assigned identity:

## Links
- https://learn.microsoft.com/azure/mysql/flexible-server/<br>
- https://learn.microsoft.com/azure/mysql/flexible-server/how-to-azure-ad#grant-permissions-to-user-assigned-managed-identity
