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
    postgresServerName: postgresServerName
    azureActiveDirectoryOnlyAuthentication: azureActiveDirectoryOnlyAuthentication
    createMode: createMode
    location: location
    tags: tags
    postgresSqlDatabaseName: postgresSqlDatabaseName
    activeDirectoryAuth: activeDirectoryAuth
    postgresServerVersion: postgresServerVersion
    publicNetworkAccess: publicNetworkAccess
    retentionDays: retentionDays
    storageAutoGrow: storageAutoGrow
    storageSizeGB: storageSizeGB
    storageTier: storageTier
    skuName: skuName
    skuTier: skuTier
    userAssignedManagedIdentityName: userAssignedManagedIdentityName
    createPostgresUserAssignedManagedIdentity: createPostgresUserAssignedManagedIdentity
    tenantId: tenantId
    geoRedundantBackup: geoRedundantBackup
    highAvailabilityMode: highAvailabilityMode
    customWindow: customWindow
  }
}
</pre>
.LINKS
- [Bicep Microsoft.DBforPostgreSQL flexibleServers](https://learn.microsoft.com/en-us/azure/templates/microsoft.dbforpostgresql/2024-08-01/flexibleservers?pivots=deployment-language-bicep)
- [Bicep Microsoft.DBforPostgreSQL flexibleServers/databases](https://learn.microsoft.com/en-us/azure/templates/microsoft.dbforpostgresql/2024-08-01/flexibleservers/databases?pivots=deployment-language-bicep)
*/

// ================================================= Parameters =================================================
@description('Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location.')
param location string = resourceGroup().location

@description('The resourcename of the Postgres Server upsert.')
@minLength(3)
@maxLength(63)
param postgresServerName string

@description('Enable Azure Active Directory only authentication.')
type activeDirectoryAuthType = 'Enabled' | 'Disabled'
param activeDirectoryAuth activeDirectoryAuthType = 'Enabled'

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
type postgresVersion = '11' | '12' | '13' | '14' | '15' | '16'
param postgresServerVersion postgresVersion = '16'

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

@description('The types of identities associated with this resource; currently restricted to None and UserAssigned')
type userAssignedIdentity = 'None' | 'UserAssigned'
param userAssignedIdentityType userAssignedIdentity = createPostgresUserAssignedManagedIdentity
  ? 'UserAssigned'
  : 'None'

@description('The Database name of the postgres sql database')
@minLength(1)
param postgresSqlDatabaseName string

@description('The public network access for the Postgres server.')
type publicNetworkAccessType = 'Enabled' | 'Disabled'
param publicNetworkAccess publicNetworkAccessType = 'Disabled'

@description('The availability zone.')
type geoRedundantBackupType = 'Enabled' | 'Disabled'
param geoRedundantBackup geoRedundantBackupType

@description('The high availability mode.')
type highAvailabilityModeType = 'Disabled' | 'SameZone' | 'ZeroRedundant'
param highAvailabilityMode highAvailabilityModeType

@description('The custom maintenance window.')
type customWindowType = 'Disabled' | 'Enabled'
param customWindow customWindowType = 'Disabled'

@description('The day of the week.')
param dayOfWeek int

@description('The start hour.')
param startHour int

@description('The start minute.')
param startMinute int

@minLength(36)
@maxLength(36)
@description('The tenant id of active directory for the Postgres server.')
param tenantId string

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
resource postgresServer 'Microsoft.DBforPostgreSQL/flexibleServers@2024-08-01' = {
  identity: {
    type: userAssignedIdentityType
    userAssignedIdentities: userAssignedIdentityObject
  }
  location: location
  name: postgresServerName
  properties: {
    authConfig: {
      activeDirectoryAuth: activeDirectoryAuth
      passwordAuth: 'Disabled'
      tenantId: tenantId
    }
    backup: {
      backupRetentionDays: retentionDays
      geoRedundantBackup: geoRedundantBackup
    }
    createMode: createMode
    highAvailability: {
      mode: highAvailabilityMode
    }
    maintenanceWindow: {
      customWindow: customWindow
      dayOfWeek: dayOfWeek
      startHour: startHour
      startMinute: startMinute
    }
    network: {
      publicNetworkAccess: publicNetworkAccess
    }
    storage: {
      autoGrow: storageAutoGrow
      storageSizeGB: storageSizeGB
      tier: storageTier
    }
    version: postgresServerVersion
  }
  sku: {
    name: skuName
    tier: skuTier
  }
  tags: tags
}

@description('Create the Postgres database under the Postgres server')
resource Database 'Microsoft.DBforPostgreSQL/flexibleServers/databases@2024-08-01' = {
  name: postgresSqlDatabaseName
  parent: postgresServer
}

@description('Output the postgres server Id')
output postgresServerId string = postgresServer.id
@description('Output the postgres server name')
output postgresServerName string = postgresServer.name
