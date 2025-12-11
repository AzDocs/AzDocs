import { PrincipalType } from '../Common/authorizationTypes.bicep'
/*
.SYNOPSIS
Configuring role assignment for Azure Database for PostgreSQL.
.DESCRIPTION
This module is used for creating role assignments for existing Azure Databases for PostgreSQL.
.EXAMPLE
<pre>
module rolePostgreSql 'br:contosoregistry.azurecr.io/authorization/roleassignments:latest' = {
  name: guid(postgresServerName, principalId, roleDefinitionId)
  properties: {
    principalId: principalId
    roleDefinitionId: roleDefinition.id
    principalType: principalType
  }
}
</pre>
.LINKS
- [Bicep Microsoft.authorization roleassignments](https://learn.microsoft.com/en-us/azure/templates/microsoft.authorization/roleassignments?pivots=deployment-language-bicep)
*/

// ================================================= Parameters =================================================
@description('The roledefinition ID you want to assign.')
@minLength(36)
@maxLength(36)
param roleDefinitionId string

@description('The AAD Object ID of the pricipal you want to assign the role to.')
@minLength(36)
@maxLength(36)
param principalId string

@description('The type of principal you want to assign the role to.')
param principalType PrincipalType

@description('''
Character limit: 3-63

Valid characters:
Alphanumerics and hyphens.

Start with letter and end with alphanumeric.

Resource name must be unique across Azure.
''')
@minLength(3)
@maxLength(63)
param postgresServerName string

@description('Fetch the role based on the given roleDefinitionId. See https://docs.microsoft.com/azure/role-based-access-control/built-in-roles')
resource roleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: resourceGroup()
  name: roleDefinitionId
}

resource postgresServer 'Microsoft.DBforPostgreSQL/flexibleServers@2024-08-01' existing = {
  name: postgresServerName
}

@description('Upsert the role with the given parameters')
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(postgresServer.id, principalId, roleDefinitionId)
  scope: postgresServer
  properties: {
    principalId: principalId
    roleDefinitionId: roleDefinition.id
    principalType: principalType
  }
}
