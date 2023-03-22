# storageAccounts

Target Scope: resourceGroup

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| storageAccountName | string | <input type="checkbox" checked> | Length between 3-24 | <pre></pre> | The name of the storage account to create.<br>Storage account name restrictions:<br>- Storage account names must be between 3 and 24 characters in length and may contain numbers and lowercase letters only.<br>- Your storage account name must be unique within Azure. No two storage accounts can have the same name. |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location. |
| subnetIdsToWhitelist | array | <input type="checkbox"> | None | <pre>[]</pre> | Array of strings containing resource id\'s of the subnets you want to whitelist on this storage account.<br><br>For example:<br>[<br>&nbsp;&nbsp;&nbsp;'/subscriptions/&#36;(SubscriptionId)/resourceGroups/&#36;(ResourceGroupName)/providers/Microsoft.Network/virtualNetworks/&#36;(VirtualNetworkName)/subnets/&#36;(SubnetName)'<br>&nbsp;&nbsp;&nbsp;'/subscriptions/&#36;(SubscriptionId)/resourceGroups/&#36;(ResourceGroupName)/providers/Microsoft.Network/virtualNetworks/&#36;(VirtualNetworkName)/subnets/&#36;(SubnetName)'<br>] |
| publicIpsToWhitelist | array | <input type="checkbox"> | None | <pre>[]</pre> | Array of strings containing value of the Public IP you want to whitelist on this storage account. Specifies the IP or IP range in CIDR format. Only IPV4 address is allowed. |
| logAnalyticsWorkspaceResourceId | string | <input type="checkbox" checked> | Length between 0-* | <pre></pre> | The azure resource id of the log analytics workspace to log the diagnostics to. If you set this to an empty string, logging & diagnostics will be disabled. |
| storageAccountSku | string | <input type="checkbox" checked> | `'Premium_LRS'` or  `'Premium_ZRS'` or  `'Standard_GRS'` or  `'Standard_GZRS'` or  `'Standard_LRS'` or  `'Standard_RAGRS'` or  `'Standard_RAGZRS'` or  `'Standard_ZRS'` | <pre></pre> | The SKU name to use for this storage account. |
| storageAccountKind | string | <input type="checkbox" checked> | `'BlobStorage'` or  `'BlockBlobStorage'` or  `'FileStorage'` or  `'Storage'` or  `'StorageV2'` | <pre></pre> | Indicates the type of storage account. |
| defaultBlobAccessTier | string | <input type="checkbox"> | `'Cool'` or  `'Hot'` or  `'Premium'` | <pre>'Hot'</pre> | Required for storage accounts where kind = BlobStorage.<br>The access tier is used for billing. The 'Premium' access tier is the default value for premium block blobs storage account type and it cannot be changed for the premium block blobs storage account type. |
| allowBlobPublicAccess | bool | <input type="checkbox"> | None | <pre>false</pre> | Allow or disallow public access to all blobs or containers in the storage account. The default interpretation is true for this property. |
| storageAccountMinimumTlsVersion | string | <input type="checkbox"> | `'TLS1_0'` or  `'TLS1_1'` or  `'TLS1_2'` | <pre>'TLS1_2'</pre> | Set the minimum TLS version to be permitted on requests to storage. |
| diagnosticsName | string | <input type="checkbox"> | Length between 1-260 | <pre>'AzurePlatformCentralizedLogging'</pre> | The name of the diagnostics. This defaults to `AzurePlatformCentralizedLogging`. |
| diagnosticSettingsMetricsCategories | array | <input type="checkbox"> | None | <pre>[<br>  {<br>    categoryGroup: 'AllMetrics'<br>    enabled: true<br>  }<br>]</pre> | Which Metrics categories to enable; This defaults to `AllMetrics`. For array/object format, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep&pivots=deployment-language-bicep#metricsettings |
| publicNetworkAccess | string | <input type="checkbox"> | `'Disabled'` or  `'Enabled'` | <pre>'Enabled'</pre> | Allow or disallow public network access to Storage Account. Value is optional but if passed in, must be `Enabled` or `Disabled`. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| storageAccountName | string | Output the resource name for this storage account. |
| storageAccountResourceId | string | Output the resource id of this storage account. |
| storageAccountPrimaryEndpoint | object | Output the primary endpoint for this storage account. |
| storageAccountApiVersion | string | Output the API Version for this storage account. |
| storageAccountKey | string | The Storage Account keys (outputing this so it can be used when creating function apps). |

