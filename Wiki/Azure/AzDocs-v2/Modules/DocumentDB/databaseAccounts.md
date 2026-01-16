# databaseAccounts

Target Scope: resourceGroup

## User Defined Types
| Name | Type | Discriminator | Description
| -- |  -- | -- | -- |
| <a id="Subnet">Subnet</a>  | <pre>{</pre> |  |  | 

## Synopsis
Creating a document db account with the given specs.

## Description
This module creates a document db account with the given specs.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| documentDbName | string | <input type="checkbox" checked> | Length between 3-44 | <pre></pre> | The name of the DocumentDB account. |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | The location of the DocumentDB account. Defaults to the resourcegroups location. |
| locations | array | <input type="checkbox"> | None | <pre>[<br>  {<br>    locationName: 'westeurope'<br>    isZoneRedundant: false<br>  }<br>]</pre> | The locations for the DocumentDB account. Defaults to one location (westeurope) without zone redundancy. |
| documentDbKind | string | <input type="checkbox"> | `'GlobalDocumentDB'` or `'MongoDB'` or `'Parse'` | <pre>'GlobalDocumentDB'</pre> | The kind of the DocumentDB account. Defaults to GlobalDocumentDB. |
| mongoDbServerVersion | string | <input type="checkbox"> | `'3.2'` or `'3.6'` or `'4.0'` or `'4.2'` or `'5.0'` or `'6.0'` or `'7.0'` | <pre>'7.0'</pre> | MongoDB server version. Only applicable when documentDbKind is MongoDB. Defaults to 7.0. |
| continuousBackupTier | string | <input type="checkbox"> | `'Continuous7Days'` or `'Continuous30Days'` | <pre>'Continuous7Days'</pre> | The continuous backup tier for this DocumentDB. Defaults to Continuous7Days. |
| backupPolicy | object | <input type="checkbox"> | None | <pre>{<br>  type: 'Continuous'<br>  continuousModeProperties: {<br>    tier: continuousBackupTier<br>  }<br>}</pre> | The backup policy for this DocumentDB. Defaults to continuous backup with the specified tier. |
| consistencyPolicy | object | <input type="checkbox"> | None | <pre>{<br>  defaultConsistencyLevel: 'Session'<br>  maxIntervalInSeconds: 5<br>  maxStalenessPrefix: 100<br>}</pre> | The consistency policy for this DocumentDB. Defaults to Session. |
| identity | object | <input type="checkbox"> | None | <pre>{<br>  type: 'SystemAssigned'<br>}</pre> | The identity for this DocumentDB. Defaults to SystemAssigned. |
| ipsToWhitelist | array | <input type="checkbox"> | None | <pre>[]</pre> | The IPs to whitelist for this DocumentDB. Defaults to empty.<br>Make sure to pass an array of objects with the following properties:<br>- ipAddressOrRange: The CIDR notation for the IP to whitelist (you are allowed to omit the suffix if its a /32.). Examples: 123.123.123.123 or 123.123.123.123/24 |
| subnetsToWhitelist | Subnet[] | <input type="checkbox"> | None | <pre>[]</pre> | The subnets to whitelist for this DocumentDB. Defaults to empty.<br>Make sure to pass an array of objects with the following properties:<br>- resourceGroupName: The name of the resourcegroup the vnet is in.<br>- vnetName: The name of the vnet.<br>- subnetName: The name of the subnet.<br>- subscriptionId: The subscription id of the vnet. (optional) |
| minimalTlsVersion | string | <input type="checkbox"> | `'Tls'` or `'Tls11'` or `'Tls12'` | <pre>'Tls12'</pre> |  |
| logAnalyticsWorkspaceResourceId | string | <input type="checkbox" checked> | None | <pre></pre> | The resource id of the Log Analytics workspace to send diagnostics data to. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;The tag object.<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;For example (in YAML):<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ApplicationID: 1234<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ApplicationName: MyCmdbAppName<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ApplicationOwner: myproductowner@company.com<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;AppTechOwner: myteam@company.com<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;BillingIdentifier: 123456<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;BusinessUnit: MyBusinessUnit<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;CostType: Application<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;EnvironmentType: dev<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;PipelineBuildNumber: 2022.08.02-main<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;PipelineRunUrl: https://dev.azure.com/org/TeamProject/_build/results?buildId=1234&view=results |
| publicNetworkAccess | string | <input type="checkbox"> | `'Enabled'` or `'Disabled'` or `'SecuredByPerimeter'` | <pre>'Enabled'</pre> |  |
| totalThroughputLimit | int | <input type="checkbox"> | None | <pre>1000</pre> | The capacity for the DocumentDB account. Defaults to totallimit 1000 RU/s. |
| enableFreeTier | bool | <input type="checkbox"> | None | <pre>false</pre> | Enable free tier for the DocumentDB account. Defaults to false. |
| enableBurstCapacity | bool | <input type="checkbox"> | None | <pre>false</pre> | Enable burst capacity for the DocumentDB account. Defaults to false. |
| enablePartitionMerge | bool | <input type="checkbox"> | None | <pre>false</pre> | Enable partition merge for the DocumentDB account. Defaults to false. |
| enablePerRegionPerPartitionAutoscale | bool | <input type="checkbox"> | None | <pre>false</pre> | Enable per-region per-partition autoscale for the DocumentDB account. Defaults to false. |
| diagnosticsName | string | <input type="checkbox"> | Length between 1-260 | <pre>'AzurePlatformCentralizedLogging'</pre> | The name of the diagnostics. This defaults to `AzurePlatformCentralizedLogging`. |
| diagnosticSettingsLogsCategories | array | <input type="checkbox"> | None | <pre>[<br>  {<br>    categoryGroup: 'allLogs'<br>    enabled: true<br>  }<br>]</pre> | Which log categories to enable; This defaults to `allLogs`. For array/object format, please refer to [the docs](https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep#logsettings). |
| diagnosticSettingsMetricsCategories | array | <input type="checkbox"> | None | <pre>[<br>  {<br>    categoryGroup: 'AllMetrics'<br>    enabled: true<br>  }<br>]</pre> | Which Metrics categories to enable; This defaults to `AllMetrics`. For array/object format, please refer to [the docs](https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep&pivots=deployment-language-bicep#metricsettings). |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| documentEndpoint | string | Outputting the documentendpoint of the DocumentDB account. |
| resourceId | string | Outputting the resource ID of the DocumentDB account. |

## Examples
<pre>
module documentDb 'br:contosoregistry.azurecr.io/documentdb/databaseaccounts:latest' = {
  name: 'Creating_a_document_db_account'
  scope: resourceGroup
  params: {
    documentDbName: 'MyFirstDocumentDb'
    locations: [
      {
        locationName: 'westeurope'
        isZoneRedundant: false
      }
    ]
    subnetsToWhitelist: [
      {
        resourceGroupName: 'MyFirstResourceGroup'
        vnetName: 'MyFirstVnet'
        subnetName: 'MyFirstSubnet'
      }
    ]
    logAnalyticsWorkspaceResourceId: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/MyFirstResourceGroup/providers/Microsoft.OperationalInsights/workspaces/MyFirstLogAnalytics'
    tags: {
      environment: 'dev'
    }
  }
}
</pre>
<p>Creates a documentdb with the given specs</p>

## Links
- [Bicep Microsoft.DocumentDB databaseAccounts](https://learn.microsoft.com/en-us/azure/templates/microsoft.documentdb/2025-04-15/databaseaccounts)
