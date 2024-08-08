/*
.SYNOPSIS
Creating a Postgres server
.DESCRIPTION
Creating a Postgres server with the given specs.
.EXAMPLE
<pre>
module postgres 'br:contosoregistry.azurecr.io/sql/postgres:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 57), 'postgresserver')
  params: {
    postgresAuthenticationAdminPassword: postgresAuthenticationAdminPassword
    postgresAuthenticationAdminUsername: postgresAuthenticationAdminUsername
    postgresServerName: postgresServerName
    azureActiveDirectoryOnlyAuthentication: azureActiveDirectoryOnlyAuthentication
    createMode: createMode
    location: location
    tags: tags
    postgresSqlDatabaseName: postgresSqlDatabaseName
  }
}
</pre>
.LINKS
- [Bicep Microsoft.Postgres servers](https://learn.microsoft.com/en-us/azure/templates/microsoft.dbforpostgresql/flexibleservers?pivots=deployment-language-bicepp)
*/

// ================================================= Parameters =================================================
@description('Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location.')
param location string = resourceGroup().location

@description('The resourcename of the Postgres Server upsert.')
@minLength(3)
@maxLength(63)
param postgresServerName string

@description('If this is enabled, Postgres authentication gets disabled and you will only be able to login using Azure AD accounts.')
param azureActiveDirectoryOnlyAuthentication bool = true

@description('''
The username for the administrator using Postgres Authentication. Once created it cannot be changed.
If you opted for EntraID only authentication, this param can be given an empty ('') value.
You can choose for EntraID only authentication by setting the param azureActiveDirectoryOnlyAuthentication to true.
''')
param postgresAuthenticationAdminUsername string = ''

@secure()
@description('''
The password for the administrator using Postgres Authentication (required for server creation).
Azure Postgres enforces [password complexity](https://learn.microsoft.com/en-us/Postgres/relational-databases/security/password-policy?view=Postgres-server-ver16#password-complexity).
''')
param postgresAuthenticationAdminPassword string = ''

@description('Determines if a user assigned managed identity should be created for this Postgres server.')
param createPostgresUserAssignedManagedIdentity bool = false

@description('The name of the user assigned managed identity to create for this Postgres server.')
param userAssignedManagedIdentityName string = 'id-${postgresServerName}'

@description('''
The tags to apply to this resource. This is an object with key/value pairs.
Example:
{
  FirstTag: myvalue
  SecondTag: another value
}
''')
param tags object = {}

@description('The version of the sql server.')
type postgresVersion = '11' | '12' | '13' | '14' | '15'
param postgresServerVersion postgresVersion = '15'

@description('The backup retention period in days. This is how many days Point-in-Time Restore will be supported.')
param retentionDays int = 7

@description('Create mode the mode to create a new PostgresPostgres Server.')
type postgresCreateMode =
  | 'Create'
  | 'Default'
  | 'GeoRestore'
  | 'PointInTimeRestore'
  | 'Replica'
  | 'ReviveDropped'
  | 'Update'
param createMode postgresCreateMode = 'Default'

@description('Storage autogrow flag to enable / disable storage auto grow for flexible server.')
type postgresStorageAutoGrow = 'Disabled' | 'Enabled'
param storageAutoGrow postgresStorageAutoGrow = 'Enabled'

@description('Storage size in GB: Max storage allowed for a server.')
param storageSizeGB int = 256

@description('Storage tier for IOPS.')
type postgresStorageTier =
  | 'P1'
  | 'P10'
  | 'P15'
  | 'P2'
  | 'P20'
  | 'P3'
  | 'P30'
  | 'P4'
  | 'P40'
  | 'P50'
  | 'P6'
  | 'P60'
  | 'P70'
  | 'P80'
param storageTier postgresStorageTier = 'P1'

@description('The name of the sku, typically, tier + family + cores, e.g. Standard_D4s_v3.')
param skuName string = 'Standard_D4s_v5'

@description('The tier of the particular SKU, e.g. Burstable.')
type postgresSkuTier = 'Burstable' | 'GeneralPurpose' | 'MemoryOptimized'
param skuTier postgresSkuTier = 'GeneralPurpose'

@description('	the types of identities associated with this resource; currently restricted to None and UserAssigned')
type userAssignedIdentity = 'None' | 'UserAssigned'
param userAssignedIdentityType userAssignedIdentity = createPostgresUserAssignedManagedIdentity
  ? 'UserAssigned'
  : 'None'

@description('The Database name of the postgres sql database')
@minLength(1)
param postgresSqlDatabaseName string

// ================================================= Resources =================================================
resource postgresServerUserAssignedManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = if (createPostgresUserAssignedManagedIdentity) {
  name: userAssignedManagedIdentityName
  location: location
}

@description('Create the user assigned managed identity object for the Postgres server')
var userAssignedIdentityObject = createPostgresUserAssignedManagedIdentity
  ? {
      userIdentity: {
        principalId: postgresServerUserAssignedManagedIdentity.id
        clientId: postgresServerUserAssignedManagedIdentity.id
      }
    }
  : null

@description('Upsert the Postgres Server, vnet whitelisting rules, security assessments, alertpolicies, auditsettings & vulnerability scans with the passed parameters')
resource Server 'Microsoft.DBforPostgreSQL/flexibleServers@2023-03-01-preview' = {
  name: postgresServerName
  location: location
  tags: tags
  sku: {
    name: skuName
    tier: skuTier
  }
  identity: {
    type: userAssignedIdentityType
    userAssignedIdentities: userAssignedIdentityObject
  }
  properties: {
    version: postgresServerVersion
    createMode: createMode
    administratorLogin: azureActiveDirectoryOnlyAuthentication ? null : postgresAuthenticationAdminUsername
    administratorLoginPassword: azureActiveDirectoryOnlyAuthentication ? null : postgresAuthenticationAdminPassword
    storage: {
      storageSizeGB: storageSizeGB
      tier: storageTier
      autoGrow: storageAutoGrow
    }
    backup: {
      backupRetentionDays: retentionDays
    }
  }
}

resource Database 'Microsoft.DBforPostgreSQL/flexibleServers/databases@2023-03-01-preview' = {
  name: postgresSqlDatabaseName
  parent: Server
}

@description('Output the postgres server Id')
output postgresServerId string = Server.id
@description('Output the postgres server name')
output postgresServerName string = Server.name
