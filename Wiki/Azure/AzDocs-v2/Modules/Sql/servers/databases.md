# databases

Target Scope: resourceGroup

## Synopsis
Creating a database in an existing SQL server

## Description
Creating a database in an existing SQL server with the given specs.

This module provisions the SQL database resource and its diagnostic settings. Backup retention policies are intentionally composed separately by the caller. Use the dedicated module:
- `sql/servers/databases/backupPolicies.bicep`

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location. |
| sqlServerName | string | <input type="checkbox" checked> | Length between 1-63 | <pre></pre> | The resourcename of the SQL Server to use (should be pre-existing). |
| sqlDatabaseName | string | <input type="checkbox" checked> | Length between 1-128 | <pre></pre> | The name of the SQL Database to upsert. |
| logAnalyticsWorkspaceResourceId | string | <input type="checkbox"> | Length between 0-* | <pre>''</pre> | The azure resource id of the log analytics workspace to log the diagnostics to. If you set this to an empty string, logging & diagnostics will be disabled. |
| diagnosticsName | string | <input type="checkbox"> | Length between 1-260 | <pre>'AzurePlatformCentralizedLogging'</pre> | The name of the diagnostics. This defaults to `AzurePlatformCentralizedLogging`. |
| sku | object | <input type="checkbox"> | None | <pre>{<br>  name: 'GP_Gen5'<br>  tier: 'GeneralPurpose'<br>  family: 'Gen5'<br>  capacity: 2<br>}</pre> | The SKU object to use for this SQL Database. Defaults to a provisioned Compute tier GP_Gen5 with capacity 2 sku. <br>For the object format, refer to [sku](https://docs.microsoft.com/en-us/azure/templates/microsoft.sql/servers/databases?tabs=bicep#sku).<br>Example<br>param sku object = {<br>&nbsp;&nbsp;&nbsp;name: 'ElasticPool'<br>&nbsp;&nbsp;&nbsp;tier: 'Standard'<br>&nbsp;&nbsp;&nbsp;capacity: 0<br>} |
| collation | string | <input type="checkbox"> | None | <pre>'SQL_Latin1_General_CP1_CI_AS'</pre> | The collation of the database. Defaults to `SQL_Latin1_General_CP1_CI_AS`. For options, please refer to [collation](https://docs.microsoft.com/en-us/sql/relational-databases/collations/collation-and-unicode-support?view=sql-server-ver16#Server-level-collations). |
| catalogCollation | string | <input type="checkbox"> | `''` or `'DATABASE_DEFAULT'` or `'SQL_Latin1_General_CP1_CI_AS'` | <pre>''</pre> | Collation of the metadata catalog. Leave empty to use service defaults. |
| createMode | string | <input type="checkbox"> | `'Default'` or `'Copy'` or `'Secondary'` or `'PointInTimeRestore'` or `'Recovery'` or `'Restore'` | <pre>'Default'</pre> | Specifies the mode of database creation. Use restore and copy parameters when not using Default mode. |
| sourceDatabaseId | string | <input type="checkbox"> | None | <pre>''</pre> | The resource identifier of the source database associated with copy, restore, and secondary create operations. |
| restorePointInTime | string | <input type="checkbox"> | None | <pre>''</pre> | Specifies the point in time (ISO8601 format) for PointInTimeRestore create mode. |
| recoverableDatabaseId | string | <input type="checkbox"> | None | <pre>''</pre> | The resource identifier of the recoverable database associated with Recovery create mode. |
| restorableDroppedDatabaseId | string | <input type="checkbox"> | None | <pre>''</pre> | The resource identifier of the restorable dropped database associated with Restore create mode. |
| sourceDatabaseDeletionDate | string | <input type="checkbox"> | None | <pre>''</pre> | Specifies the time that the source database was deleted, for restore operations that require it. |
| sourceResourceId | string | <input type="checkbox"> | None | <pre>''</pre> | The resource identifier of the source associated with restore operations across subscriptions, where supported. |
| licenseType | string | <input type="checkbox"> | `'BasePrice'` or `'LicenseIncluded'` | <pre>'BasePrice'</pre> | The license type to apply for this database. LicenseIncluded if you need a license, or BasePrice if you have a license and are eligible for the Azure Hybrid Benefit. |
| requestedBackupStorageRedundancy | string | <input type="checkbox"> | `'Geo'` or `'GeoZone'` or `'Local'` or `'Zone'` | <pre>'Zone'</pre> | The storage account type to be used to store backups for this database. |
| diagnosticSettingsLogsCategories | array | <input type="checkbox"> | None | <pre>[<br>  {<br>    categoryGroup: 'allLogs'<br>    enabled: true<br>  }<br>]</pre> | Which log categories to enable; This defaults to `allLogs`. For array/object format, please refer to [docs](https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep#logsettings). |
| diagnosticSettingsMetricsCategories | array | <input type="checkbox"> | None | <pre>[<br>  {<br>    categoryGroup: 'AllMetrics'<br>    enabled: true<br>  }<br>]</pre> | Which Metrics categories to enable; This defaults to `AllMetrics`. For array/object format, please refer to [docs](https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep&pivots=deployment-language-bicep#metricsettings). |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| databaseZoneRedundant | bool | <input type="checkbox"> | None | <pre>false</pre> | Whether or not this database is zone redundant, which means the replicas of this database will be spread across multiple availability zones. |
| maxSizeBytes | int | <input type="checkbox"> | None | <pre>32 * 1024 * 1024 * 1024 // 32GB</pre> | The max size of the database expressed in bytes |
| autoPauseDelay | int | <input type="checkbox"> | None | <pre>-1</pre> | For the serverless database model, ignored for the provisioned model.Time in minutes after which database is automatically paused. A value of -1 means that automatic pause is disabled |
| minCapacity | string | <input type="checkbox"> | None | <pre>'0.5'</pre> | Minimal capacity that database will always have allocated, if not paused. To specify a decimal (0.5 0.75 ß1) value, use the json() function. |
| sampleName | string | <input type="checkbox"> | `''` or `'AdventureWorksLT'` or `'WideWorldImportersStd'` or `'WideWorldImportersFull'` | <pre>''</pre> | The sample name of the database to create. |
| readScaleOut | string | <input type="checkbox"> | `'Enabled'` or `'Disabled'` | <pre>'Disabled'</pre> | The state of read-only routing. If enabled, connections that have application intent set to readonly in their connection string may be routed to a readonly secondary replica in the same region. <br>Not applicable to a Hyperscale database within an elastic pool. |
| elasticPoolId | string | <input type="checkbox"> | None | <pre>''</pre> | The resource identifier of the elastic pool, this should be pre-existing. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| sqlDatabase | string | Output the SQL Database resource name. |

## Examples
<pre>
module sql 'br:contosoregistry.azurecr.io/sql/servers/databases.bicep:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 61), 'db')
  params: {
    sqlServerName:sqlserver.outputs.sqlServerName
    location: location
    sqlDatabaseName: 'sqlDatabaseName'
  }
}
</pre>
<p>Creates a database called sqlDatabaseName in an existing Sql server with the name sqlServerName</p>

## Links
- [Bicep Microsoft.SQL servers](https://learn.microsoft.com/en-us/azure/templates/microsoft.sql/servers/databases?pivots=deployment-language-bicep)
