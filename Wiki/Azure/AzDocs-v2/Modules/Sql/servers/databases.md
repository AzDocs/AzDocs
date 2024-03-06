# databases

Target Scope: resourceGroup

## Synopsis
Creating a database in an existing SQL server

## Description
Creating a database in an existing SQL server with the given specs.

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
| licenseType | string | <input type="checkbox"> | `'BasePrice'` or `'LicenseIncluded'` | <pre>'BasePrice'</pre> | The license type to apply for this database. LicenseIncluded if you need a license, or BasePrice if you have a license and are eligible for the Azure Hybrid Benefit. |
| requestedBackupStorageRedundancy | string | <input type="checkbox"> | `'Geo'` or `'GeoZone'` or `'Local'` or `'Zone'` | <pre>'Zone'</pre> | The storage account type to be used to store backups for this database. |
| diagnosticSettingsLogsCategories | array | <input type="checkbox"> | None | <pre>[<br>  {<br>    categoryGroup: 'allLogs'<br>    enabled: true<br>  }<br>]</pre> | Which log categories to enable; This defaults to `allLogs`. For array/object format, please refer to [docs](https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep#logsettings). |
| diagnosticSettingsMetricsCategories | array | <input type="checkbox"> | None | <pre>[<br>  {<br>    categoryGroup: 'AllMetrics'<br>    enabled: true<br>  }<br>]</pre> | Which Metrics categories to enable; This defaults to `AllMetrics`. For array/object format, please refer to [docs](https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep&pivots=deployment-language-bicep#metricsettings). |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| createDatabaseUserAssignedManagedIdentity | bool | <input type="checkbox"> | None | <pre>false</pre> | Determines if a user assigned managed identity should be created for this SQL database. |
| userAssignedManagedIdentityName | string | <input type="checkbox"> | None | <pre>'id-&#36;{sqlDatabaseName}'</pre> | The name of the user assigned managed identity to create for this SQL server. |
| databaseZoneRedundant | bool | <input type="checkbox"> | None | <pre>false</pre> | Whether or not this database is zone redundant, which means the replicas of this database will be spread across multiple availability zones. |
| maxSizeBytes | int | <input type="checkbox"> | None | <pre>32 * 1024 * 1024 * 1024 // 32GB</pre> | The max size of the database expressed in bytes |
| autoPauseDelay | int | <input type="checkbox"> | None | <pre>-1</pre> | For the serverless database model, ignored for the provisioned model.Time in minutes after which database is automatically paused. A value of -1 means that automatic pause is disabled |
| minCapacity | string | <input type="checkbox"> | None | <pre>'0.5'</pre> | Minimal capacity that database will always have allocated, if not paused. To specify a decimal (0.5 0.75 ß1) value, use the json() function. |
| backupRetention | object | <input type="checkbox"> | None | <pre>{<br>  weeklyRetention: 'P4W'<br>}</pre> | The retention object for the long term backup retention policy. See for values the [docs](https://learn.microsoft.com/en-us/azure/azure-sql/database/long-term-retention-overview?view=azuresql).<br>Example:<br>W=0, M=3, Y=0<br>'The first full backup of each month is kept for three months.' |
| diffBackupIntervalInHours | int | <input type="checkbox"> | `12` or `24` | <pre>12</pre> | The differential backup interval in hours. This is how many interval hours between each differential backup will be supported. This is only applicable to live databases but not dropped databases.<br>See [docs](https://learn.microsoft.com/en-us/azure/azure-sql/database/automated-backups-overview?view=azuresql) |
| retentionDays | int | <input type="checkbox"> | None | <pre>7</pre> | The backup retention period in days. This is how many days Point-in-Time Restore will be supported. |
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
