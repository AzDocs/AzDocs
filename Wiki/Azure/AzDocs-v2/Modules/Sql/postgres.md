# postgres

Target Scope: resourceGroup

## User Defined Types
| Name | Type | Discriminator | Description
| -- |  -- | -- | -- |
| <a id="authTypeEnabled">authTypeEnabled</a>  | <pre>'Enabled' &#124; 'Disabled'</pre> |  | Enable Azure Active Directory authentication. | 
| <a id="postgresVersion">postgresVersion</a>  | <pre>'11' &#124; '12' &#124; '13' &#124; '14' &#124; '15' &#124; '16'</pre> |  | The version of the sql server. | 
| <a id="postgresCreateMode">postgresCreateMode</a>  | <pre></pre> |  | Create mode the mode to create a new PostgresPostgres Server. | 
| <a id="postgresStorageAutoGrow">postgresStorageAutoGrow</a>  | <pre>'Disabled' &#124; 'Enabled'</pre> |  | Storage autogrow flag to enable / disable storage auto grow for flexible server. | 
| <a id="postgresStorageTier">postgresStorageTier</a>  | <pre></pre> |  | Storage tier for IOPS. | 
| <a id="postgresSkuTier">postgresSkuTier</a>  | <pre>'Burstable' &#124; 'GeneralPurpose' &#124; 'MemoryOptimized'</pre> |  | The tier of the particular SKU, e.g. Burstable. | 
| <a id="userAssignedIdentity">userAssignedIdentity</a>  | <pre>'None' &#124; 'UserAssigned'</pre> |  | The types of identities associated with this resource; currently restricted to None and UserAssigned | 
| <a id="publicNetworkAccessType">publicNetworkAccessType</a>  | <pre>'Enabled' &#124; 'Disabled'</pre> |  | The public network access for the Postgres server. | 
| <a id="geoRedundantBackupType">geoRedundantBackupType</a>  | <pre>'Enabled' &#124; 'Disabled'</pre> |  | The availability zone. | 
| <a id="highAvailabilityModeType">highAvailabilityModeType</a>  | <pre>'Disabled' &#124; 'SameZone' &#124; 'ZeroRedundant'</pre> |  | The high availability mode. | 
| <a id="customWindowType">customWindowType</a>  | <pre>'Disabled' &#124; 'Enabled'</pre> |  | The custom maintenance window. | 
| <a id="dataEncryptionType">dataEncryptionType</a>  | <pre>'AzureKeyVault' &#124; 'SystemManaged'</pre> |  | The data encryption type for the Postgres server. | 

## Synopsis
Creating a Postgres server

## Description
Creating a Postgres server with the given specs.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location. |
| postgresServerName | string | <input type="checkbox" checked> | Length between 3-63 | <pre></pre> | The resourcename of the Postgres Server upsert. |
| activeDirectoryAuth | authTypeEnabled | <input type="checkbox"> | None | <pre>'Enabled'</pre> |  |
| administratorLoginAuthentication | authTypeEnabled | <input type="checkbox"> | None | <pre>'Disabled'</pre> | Enable administrator login authentication. |
| administratorLogin | string? | <input type="checkbox" checked> | Length between 0-128 | <pre></pre> | The administrator login name. |
| administratorLoginPassword | string? | <input type="checkbox" checked> | Length between 0-128 | <pre></pre> | The password of the administrator login. |
| createPostgresUserAssignedManagedIdentity | bool | <input type="checkbox"> | None | <pre>false</pre> | Determines if a user assigned managed identity should be created for this Postgres server. |
| userAssignedManagedIdentityName | string | <input type="checkbox"> | None | <pre>'id-&#36;{postgresServerName}'</pre> | The name of the user assigned managed identity to create for this Postgres server. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| postgresServerVersion | postgresVersion | <input type="checkbox"> | None | <pre>'16'</pre> |  |
| retentionDays | int | <input type="checkbox"> | None | <pre>7</pre> | The backup retention period in days. This is how many days Point-in-Time Restore will be supported. |
| createMode | postgresCreateMode | <input type="checkbox"> | None | <pre>'Default'</pre> |  |
| storageAutoGrow | postgresStorageAutoGrow | <input type="checkbox"> | None | <pre>'Enabled'</pre> |  |
| storageSizeGB | int | <input type="checkbox"> | None | <pre>256</pre> | Storage size in GB: Max storage allowed for a server. |
| storageTier | postgresStorageTier | <input type="checkbox"> | None | <pre>'P1'</pre> |  |
| skuName | string | <input type="checkbox"> | None | <pre>'Standard_D4s_v5'</pre> | The name of the sku, typically, tier + family + cores, e.g. Standard_D4s_v3. |
| skuTier | postgresSkuTier | <input type="checkbox"> | None | <pre>'GeneralPurpose'</pre> |  |
| userAssignedIdentityType | userAssignedIdentity | <input type="checkbox"> | None | <pre>createPostgresUserAssignedManagedIdentity</pre> |  |
| postgresSqlDatabaseName | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | The Database name of the postgres sql database |
| publicNetworkAccess | publicNetworkAccessType | <input type="checkbox"> | None | <pre>'Disabled'</pre> |  |
| geoRedundantBackup | geoRedundantBackupType | <input type="checkbox" checked> | None | <pre></pre> |  |
| highAvailabilityMode | highAvailabilityModeType | <input type="checkbox" checked> | None | <pre></pre> |  |
| customWindow | customWindowType | <input type="checkbox"> | None | <pre>'Disabled'</pre> |  |
| dayOfWeek | int | <input type="checkbox" checked> | None | <pre></pre> | The day of the week. |
| startHour | int | <input type="checkbox" checked> | None | <pre></pre> | The start hour. |
| startMinute | int | <input type="checkbox" checked> | None | <pre></pre> | The start minute. |
| tenantId | string | <input type="checkbox" checked> | Length is 36 | <pre></pre> | The tenant id of active directory for the Postgres server. |
| dataEncryption | dataEncryptionType | <input type="checkbox"> | None | <pre>'SystemManaged'</pre> |  |
| iops | int | <input type="checkbox"> | None | <pre>500</pre> | The IOPS for the Postgres server. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| postgresServerId | string | Output the postgres server Id |
| postgresServerName | string | Output the postgres server name |

## Examples
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

## Links
- [Bicep Microsoft.DBforPostgreSQL flexibleServers](https://learn.microsoft.com/en-us/azure/templates/microsoft.dbforpostgresql/2024-08-01/flexibleservers?pivots=deployment-language-bicep)<br>
- [Bicep Microsoft.DBforPostgreSQL flexibleServers/databases](https://learn.microsoft.com/en-us/azure/templates/microsoft.dbforpostgresql/2024-08-01/flexibleservers/databases?pivots=deployment-language-bicep)
