/*
.SYNOPSIS
Adds or configures an Azure Database for MySQL Flexible Server EntraId (Active Directory) administrator.
.DESCRIPTION
This file declares the administrator resource for a MySQL flexible server. It can be used
to create or update an EntraId (Azure AD) administrator on an existing flexible server.
The server must exist already; this module targets the `administrators` child resource.
.PARAMETER mySqlFlexibleServerName
Name of the existing MySQL flexible server to which the administrator will be added.
.PARAMETER administrators
Array of administrator objects to configure on the flexible server. 
Each object may include properties such as name, login, sid, tenantId, identityResourceId, and administratorType.
Administrator object shape: expected keys:
- name (optional): resource name for the admin child resource
- administratorType (optional): e.g. 'ActiveDirectory'
- login (required): admin login (user or service principal, usually UPN.)
- sid (required): object id (GUID) of the Azure AD principal
- tenantId (optional): tenant GUID, defaults to tenant().tenantId
- identityResourceId (optional): full resourceId of a user-assigned managed identity
.EXAMPLE
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
.LINKS
- https://learn.microsoft.com/azure/mysql/flexible-server/
- https://learn.microsoft.com/azure/mysql/flexible-server/how-to-azure-ad#grant-permissions-to-user-assigned-managed-identity
.NOTES
- The managed identity used must have directory permissions such as `User.Read.All`,
  `GroupMember.Read.All`, and `Application.Read.All` as applicable.
- You may need to grant admin consent for these Graph permissions in Entra ID.
*/
@description('Server Name for the existing Azure MySQL flexible server to which the administrator will be added.')
param mySqlFlexibleServerName string

@description('Administrator type. Must be "ActiveDirectory" for Entra ID administrators.')
param administratorType string = 'ActiveDirectory'

@description('The resourceId of the existing user-assigned managed identity that will perform directory operations.')
param userAssignedIdentityResourceId string

@description('Optional. The tenant ID of the Entra ID (Azure AD) tenant.')
param tenantId string = tenant().tenantId

@description('The login name of the Entra ID (Azure AD) administrator (user principal name or service principal name).')
param entraIdAdminLogin string

@description('The object ID (SID) of the Entra ID (Azure AD) administrator (user or service principal).')
param entraIdAdminSid string


resource mySqlFlexibleServer 'Microsoft.DBforMySQL/flexibleServers@2024-12-30' existing = {
  name: mySqlFlexibleServerName
}

resource mySqlAdministrator 'Microsoft.DBforMySQL/flexibleServers/administrators@2025-06-01-preview' = {
  parent: mySqlFlexibleServer
  name: 'ActiveDirectory'
  properties: {
    administratorType: administratorType
    identityResourceId: userAssignedIdentityResourceId
    login: entraIdAdminLogin
    sid: entraIdAdminSid
    tenantId: tenantId ?? ''
  }
}
