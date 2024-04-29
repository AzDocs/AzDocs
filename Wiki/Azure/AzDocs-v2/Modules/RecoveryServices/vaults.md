# vaults

Target Scope: resourceGroup

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| recoveryServicesVaultName | string | <input type="checkbox" checked> | Length between 2-50 | <pre></pre> | The name of the recovery services vault to create.<br>The Azure Recovery Services vault includes Azure Backup and Site Recovery, two services that let you to secure your data outside of your own data center. |
| recoveryServicesVaultSku | object | <input type="checkbox"> | None | <pre>{<br>  name: 'RS0'<br>  tier: 'Standard'<br>}</pre> | Define the sku you want to use for this Recovery Services vault. For formatting & options, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.recoveryservices/vaults?pivots=deployment-language-bicep.<br>Quick examples:<br>Among others, options are:<br>`capacity`: capacity for the recovery vault services sku.<br>`family`: family for the recovery vault services.<br>`name`: name for the recovery vault services sku.<br>`size`: size for the recovery vault services sku.<br>`tier`: tier for the recovery vault services sku. |
| identity | object | <input type="checkbox"> | None | <pre>{<br>  type: 'SystemAssigned'<br>}</pre> | Sets the identity property for the vault<br>Examples:<br>{<br>&nbsp;&nbsp;&nbsp;type: 'UserAssigned'<br>&nbsp;&nbsp;&nbsp;userAssignedIdentities: {}<br>}<br>{<br>&nbsp;&nbsp;&nbsp;type: enableSystemIdentity ? 'SystemAssigned' : 'None'<br>} |
| diagnosticSettingsMetricsCategories | array | <input type="checkbox"> | None | <pre>[<br>  {<br>    categoryGroup: 'AllMetrics'<br>    enabled: true<br>  }<br>]</pre> | Which Metrics categories to enable; This defaults to `AllMetrics`. For array/object format, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep&pivots=deployment-language-bicep#metricsettings |
| logAnalyticsWorkspaceResourceId | string | <input type="checkbox"> | None | <pre>''</pre> | The azure resource id of the log analytics workspace to log the diagnostics to. |
| diagnosticsName | string | <input type="checkbox"> | Length between 1-260 | <pre>'AzurePlatformCentralizedLogging'</pre> | The name of the diagnostics. This defaults to `AzurePlatformCentralizedLogging`. |
| diagnosticSettingsLogsCategories | array | <input type="checkbox"> | None | <pre>[<br>  {<br>    categoryGroup: 'allLogs'<br>    enabled: true<br>  }<br>]</pre> | Which log categories to enable; This defaults to `allLogs`. For array/object format, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep#logsettings. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| vaultResourceName | string | Output the resource name for this Recovery Services Vault. |
| vaultResourceId | string | Output the resource id for this Recovery Services Vault. |
| vaultIdentityPrincipalId | string | Output the system assigned managed identity for this Recovery Services Vault. |
