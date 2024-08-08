# postgres

Target Scope: resourceGroup

## User Defined Types
| Name | Type | Discriminator | Description
| -- |  -- | -- | -- |
| <a id="postgresVersion">postgresVersion</a>  | <pre>'11' &#124; '12' &#124; '13' &#124; '14' &#124; '15'</pre> |  | The version of the sql server. | 
| <a id="postgresCreateMode">postgresCreateMode</a>  | <pre></pre> |  | Create mode the mode to create a new PostgresPostgres Server. | 
| <a id="postgresStorageAutoGrow">postgresStorageAutoGrow</a>  | <pre>'Disabled' &#124; 'Enabled'</pre> |  | Storage autogrow flag to enable / disable storage auto grow for flexible server. | 
| <a id="postgresStorageTier">postgresStorageTier</a>  | <pre></pre> |  | Storage tier for IOPS. | 
| <a id="postgresSkuTier">postgresSkuTier</a>  | <pre>'Burstable' &#124; 'GeneralPurpose' &#124; 'MemoryOptimized'</pre> |  | The tier of the particular SKU, e.g. Burstable. | 
| <a id="userAssignedIdentity">userAssignedIdentity</a>  | <pre>'None' &#124; 'UserAssigned'</pre> |  | 	the types of identities associated with this resource; currently restricted to None and UserAssigned | 

## Synopsis
Creating a Postgres server

## Description
Creating a Postgres server with the given specs.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location. |
| postgresServerName | string | <input type="checkbox" checked> | Length between 3-63 | <pre></pre> | The resourcename of the Postgres Server upsert. |
| azureActiveDirectoryOnlyAuthentication | bool | <input type="checkbox"> | None | <pre>true</pre> | If this is enabled, Postgres authentication gets disabled and you will only be able to login using Azure AD accounts. |
| postgresAuthenticationAdminUsername | string | <input type="checkbox"> | None | <pre>''</pre> | The username for the administrator using Postgres Authentication. Once created it cannot be changed.<br>If you opted for EntraID only authentication, this param can be given an empty ('') value.<br>You can choose for EntraID only authentication by setting the param azureActiveDirectoryOnlyAuthentication to true. |
| postgresAuthenticationAdminPassword | string | <input type="checkbox"> | None | <pre>''</pre> | The password for the administrator using Postgres Authentication (required for server creation).<br>Azure Postgres enforces [password complexity](https://learn.microsoft.com/en-us/Postgres/relational-databases/security/password-policy?view=Postgres-server-ver16#password-complexity). |
| createPostgresUserAssignedManagedIdentity | bool | <input type="checkbox"> | None | <pre>false</pre> | Determines if a user assigned managed identity should be created for this Postgres server. |
| userAssignedManagedIdentityName | string | <input type="checkbox"> | None | <pre>'id-&#36;{postgresServerName}'</pre> | The name of the user assigned managed identity to create for this Postgres server. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| postgresServerVersion | postgresVersion | <input type="checkbox"> | None | <pre>'15'</pre> |  |
| retentionDays | int | <input type="checkbox"> | None | <pre>7</pre> | The backup retention period in days. This is how many days Point-in-Time Restore will be supported. |
| createMode | postgresCreateMode | <input type="checkbox"> | None | <pre>'Default'</pre> |  |
| storageAutoGrow | postgresStorageAutoGrow | <input type="checkbox"> | None | <pre>'Enabled'</pre> |  |
| storageSizeGB | int | <input type="checkbox"> | None | <pre>256</pre> | Storage size in GB: Max storage allowed for a server. |
| storageTier | postgresStorageTier | <input type="checkbox"> | None | <pre>'P1'</pre> |  |
| skuName | string | <input type="checkbox"> | None | <pre>'Standard_D4s_v5'</pre> | The name of the sku, typically, tier + family + cores, e.g. Standard_D4s_v3. |
| skuTier | postgresSkuTier | <input type="checkbox"> | None | <pre>'GeneralPurpose'</pre> |  |
| userAssignedIdentityType | userAssignedIdentity | <input type="checkbox"> | None | <pre>createPostgresUserAssignedManagedIdentity</pre> |  |
| postgresSqlDatabaseName | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | The Database name of the postgres sql database |

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

## Links
- [Bicep Microsoft.Postgres servers](https://learn.microsoft.com/en-us/azure/templates/microsoft.dbforpostgresql/flexibleservers?pivots=deployment-language-bicepp)
