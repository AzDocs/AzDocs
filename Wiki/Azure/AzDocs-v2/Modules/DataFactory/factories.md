# factories

Target Scope: resourceGroup

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the key vault should be created. |
| dataFactoryName | string | <input type="checkbox" checked> | Length between 3-63 | <pre></pre> | The resource name of this Data Factory. |
| systemAssignedIdentity | bool | <input type="checkbox"> | None | <pre>true</pre> | Enables system assigned managed identity on the resource |
| userAssignedIdentities | object | <input type="checkbox"> | None | <pre>{}</pre> | The user assigned ID(s) to assign to the resource. For formatting, please refer to: https://docs.microsoft.com/en-us/azure/templates/microsoft.datafactory/factories?pivots=deployment-language-bicep#factoryidentity. |
| publicNetworkAccess | string | <input type="checkbox"> | `'Disabled'` or `'Enabled'` | <pre>'Disabled'</pre> | Enable or disable public network access. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| repoConfiguration | object | <input type="checkbox"> | None | <pre>{}</pre> | Configure Azure Data Factory to store the pipelines, datasets, data flows, and so on in a GIT repository. This allows you to automate your workflow using (for example) Azure DevOps pipelines or GitHub actions. For more information, refer to https://docs.microsoft.com/en-us/azure/data-factory/continuous-integration-delivery. |
| logAnalyticsWorkspaceResourceId | string | <input type="checkbox" checked> | Length between 0-* | <pre></pre> | The azure resource id of the log analytics workspace to log the diagnostics to. If you set this to an empty string, logging & diagnostics will be disabled. |
| diagnosticsName | string | <input type="checkbox"> | Length between 1-260 | <pre>'AzurePlatformCentralizedLogging'</pre> | The name of the diagnostics. This defaults to `AzurePlatformCentralizedLogging`. |
| diagnosticSettingsLogsCategories | array | <input type="checkbox"> | None | <pre>[<br>  {<br>    categoryGroup: 'allLogs'<br>    enabled: true<br>  }<br>]</pre> | Which log categories to enable; This defaults to `allLogs`. For array/object format, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep#logsettings. |
| diagnosticSettingsMetricsCategories | array | <input type="checkbox"> | None | <pre>[<br>  {<br>    categoryGroup: 'AllMetrics'<br>    enabled: true<br>  }<br>]</pre> | Which Metrics categories to enable; This defaults to `AllMetrics`. For array/object format, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep&pivots=deployment-language-bicep#metricsettings |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| dataFactoryName | string | Output the resource name of the Azure Data Factory. |

