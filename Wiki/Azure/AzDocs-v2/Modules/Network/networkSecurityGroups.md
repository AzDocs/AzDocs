# networkSecurityGroups

Target Scope: resourceGroup

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| networkSecurityGroupName | string | <input type="checkbox" checked> | Length between 1-80 | <pre></pre> | The name of the network security group. Preferably identical or similar/retracable to the subnet name where it gets applied to. |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location. |
| securityRules | array | <input type="checkbox" checked> | None | <pre></pre> | A collection of security rules of the network security group. For array/object structure, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.network/networksecuritygroups?tabs=bicep#securityrule. |
| diagnosticsName | string | <input type="checkbox"> | Length between 1-260 | <pre>'AzurePlatformCentralizedLogging'</pre> | The name of the diagnostics. This defaults to `AzurePlatformCentralizedLogging`. |
| logAnalyticsWorkspaceResourceId | string | <input type="checkbox"> | Length between 0-* | <pre>''</pre> | The azure resource id of the log analytics workspace to log the diagnostics to. If you set this to an empty string, logging & diagnostics will be disabled. |
| networkWatcherName | string | <input type="checkbox" checked> | Length between 1-80 | <pre></pre> | The name of the networkwatcher for this Virtual Network. This should be pre-existing. |
| networkWatcherResourceGroupName | string | <input type="checkbox"> | Length between 1-90 | <pre>az.resourceGroup().name</pre> | The name of the resourcegroup where the networkwatcher (for the Virtual Network) resides in. This should be pre-existing. |
| nsgFlowLogResourceName | string | <input type="checkbox"> | Length between 3-45 | <pre>'nfl-<networkSecurityGroupName>'</pre> | The name of the NSG flow log (dianostics).<br>You can use the following placeholders which will be replaced by their respective values:<br>&nbsp;&nbsp;&nbsp;- <networkSecurityGroupName> will be translated in the value you use for the `networkSecurityGroupName` parameter. |
| nsgFlowLogStorageAccountResourceId | string | <input type="checkbox" checked> | None | <pre></pre> | The resourceid for the storage account to log the NSG flow logs to. This should be pre-existing. |
| diagnosticSettingsLogsCategories | array | <input type="checkbox"> | None | <pre>[<br>  {<br>    categoryGroup: 'allLogs'<br>    enabled: true<br>  }<br>]</pre> | Which log categories to enable; This defaults to `allLogs`. For array/object format, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep#logsettings. |
| flowLogTrafficAnalyticsInterval | int | <input type="checkbox"> | None | <pre>10</pre> | The interval in minutes which would decide how frequently TA service should do flow analytics. |
| flowLogRetentionPolicy | object | <input type="checkbox"> | None | <pre>{<br>  days: 0<br>  enabled: true<br>}</pre> | Parameters that define the retention policy for flow log. See the [documentation](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/2021-08-01/networkwatchers/flowlogs?pivots=deployment-language-bicep#retentionpolicyparameters).<br>days: Number of days to retain flow log records.<br>enabled:	Flag to enable/disable retention. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| trafficAnalyticsLogAnalyticsWorkspaceResourceId | string | <input type="checkbox" checked> | Length between 0-* | <pre></pre> | The azure resource id of the log analytics workspace to log the flowlogs to. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| nsgName | string | Output the Network Security Group\'s resource name |
| nsgResourceId | string | Output the Network Security Group\'s resource id |
