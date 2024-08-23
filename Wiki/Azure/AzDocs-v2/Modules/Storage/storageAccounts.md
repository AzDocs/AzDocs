# storageAccounts

Target Scope: resourceGroup

## Synopsis
Creating a storage account.

## Description
Creating a storage account.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| storageAccountName | string | <input type="checkbox" checked> | Length between 3-24 | <pre></pre> | The name of the storage account to create.<br>Storage account name restrictions:<br>- Storage account names must be between 3 and 24 characters in length and may contain numbers and lowercase letters only.<br>- Your storage account name must be unique within Azure. No two storage accounts can have the same name. |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location. |
| subnetIdsToWhitelist | array | <input type="checkbox"> | None | <pre>[]</pre> | Array of strings containing resource id\'s of the subnets you want to whitelist on this storage account.<br><br>For example:<br>[<br>&nbsp;&nbsp;&nbsp;'/subscriptions/&#36;(SubscriptionId)/resourceGroups/&#36;(ResourceGroupName)/providers/Microsoft.Network/virtualNetworks/&#36;(VirtualNetworkName)/subnets/&#36;(SubnetName)'<br>&nbsp;&nbsp;&nbsp;'/subscriptions/&#36;(SubscriptionId)/resourceGroups/&#36;(ResourceGroupName)/providers/Microsoft.Network/virtualNetworks/&#36;(VirtualNetworkName)/subnets/&#36;(SubnetName)'<br>] |
| publicIpsToWhitelist | array | <input type="checkbox"> | None | <pre>[]</pre> | Array of strings containing value of the Public IP you want to whitelist on this storage account. Specifies the IP or IP range in CIDR format. Only IPV4 address is allowed. |
| logAnalyticsWorkspaceResourceId | string | <input type="checkbox"> | None | <pre>''</pre> | The azure resource id of the log analytics workspace to log the diagnostics to. If you set this to an empty string, logging & diagnostics will be disabled. |
| storageAccountSku | string | <input type="checkbox" checked> | `'Premium_LRS'` or `'Premium_ZRS'` or `'Standard_GRS'` or `'Standard_GZRS'` or `'Standard_LRS'` or `'Standard_RAGRS'` or `'Standard_RAGZRS'` or `'Standard_ZRS'` | <pre></pre> | The SKU name to use for this storage account. |
| storageAccountKind | string | <input type="checkbox" checked> | `'BlobStorage'` or `'BlockBlobStorage'` or `'FileStorage'` or `'Storage'` or `'StorageV2'` | <pre></pre> | Indicates the type of storage account. |
| defaultBlobAccessTier | string | <input type="checkbox"> | `'Cool'` or `'Hot'` or `'Premium'` | <pre>'Hot'</pre> | Required for storage accounts where kind = BlobStorage.<br>The access tier is used for billing. The 'Premium' access tier is the default value for premium block blobs storage account type and it cannot be changed for the premium block blobs storage account type. |
| allowBlobPublicAccess | bool | <input type="checkbox"> | None | <pre>false</pre> | Allow or disallow public access to all blobs or containers in the storage account. The default interpretation is true for this property. |
| allowSharedKeyAccess | bool | <input type="checkbox"> | None | <pre>false</pre> | Allow or disallow shared key access to the storage account. The default interpretation is false for this property. |
| storageAccountMinimumTlsVersion | string | <input type="checkbox"> | `'TLS1_0'` or `'TLS1_1'` or `'TLS1_2'` | <pre>'TLS1_2'</pre> | Set the minimum TLS version to be permitted on requests to storage. |
| diagnosticsName | string | <input type="checkbox"> | Length between 1-260 | <pre>'AzurePlatformCentralizedLogging'</pre> | The name of the diagnostics. This defaults to `AzurePlatformCentralizedLogging`. |
| diagnosticSettingsMetricsCategories | array | <input type="checkbox"> | None | <pre>[<br>  {<br>    categoryGroup: 'AllMetrics'<br>    enabled: true<br>  }<br>]</pre> | Which Metrics categories to enable; This defaults to `AllMetrics`. For array/object format, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep&pivots=deployment-language-bicep#metricsettings |
| publicNetworkAccess | string | <input type="checkbox"> | `'Disabled'` or `'Enabled'` | <pre>'Enabled'</pre> | Allow or disallow public network access to Storage Account. Value is optional but if passed in, must be `Enabled` or `Disabled`. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| azureFilesIdentityBasedAuthentication | object | <input type="checkbox"> | None | <pre>{}</pre> | Optional. Provides the identity based authentication settings for Azure Files.<br><details><br>&nbsp;&nbsp;&nbsp;<summary>Click to show example</summary><br><pre><br>param azureFilesIdentityBasedAuthentication object = {<br>&nbsp;&nbsp;&nbsp;directoryServiceOptions: 'AD'<br>&nbsp;&nbsp;&nbsp;activeDirectoryProperties: {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;domainName: 'Contoso.com' //Global.DomainName<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;netBiosDomainName: 'Contoso' //first(split(Global.DomainName, '.'))<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;forestName: 'Contoso.com' // Global.DomainName<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;domainGuid: '7bdbf663-36ad-43e2-9148-c142ace6ae24'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;domainSid: 'S-1-5-21-4189862783-2073351504-2099725206'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;azureStorageSid: 'S-1-5-21-4189862783-2073351504-2099725206-3101'<br>&nbsp;&nbsp;&nbsp;}<br>}<br></pre><br></details> |
| defaultToOAuthAuthentication | bool | <input type="checkbox"> | None | <pre>false</pre> | Allow or disallow OAuth authentication to the storage account. The default interpretation is false for this property. |
| enableNfsV3 | bool | <input type="checkbox"> | None | <pre>false</pre> | Optional. If true, enables NFS 3.0 support for the storage account. Requires enableHierarchicalNamespace to be true. |
| enableSftp | bool | <input type="checkbox"> | None | <pre>false</pre> | Optional. If true, enables Secure File Transfer Protocol for the storage account. Requires enableHierarchicalNamespace to be true. |
| largeFileSharesState | string | <input type="checkbox"> | `'Disabled'` or `'Enabled'` | <pre>'Disabled'</pre> | Optional. Allow large file shares if sets to \'Enabled\'. It cannot be disabled once it is enabled. Only supported on locally redundant and zone redundant file shares. It cannot be set on FileStorage storage accounts (storage accounts for premium file shares). |
| keyVaultName | string | <input type="checkbox"> | None | <pre>''</pre> | The name of the existing key vault to use for encryption and that stores the key. If this is set, the storage account will be encrypted with a key from the key vault.<br>Make sure to either grant the system assigned managed identity of the storage account or the user assigned managed identity of the storage account the correct RBAC or access policies on the Keyvault. |
| userAssignedIdentityResourceGroupName | string | <input type="checkbox"> | None | <pre>resourceGroup().name</pre> | The resource group name for the user assigned managed identity. |
| userAssignedIdentityName | string | <input type="checkbox"> | None | <pre>''</pre> | The name of the user assigned managed identity to create for this storage account. |
| keyVaultResourceGroupName | string | <input type="checkbox"> | None | <pre>resourceGroup().name</pre> | The resource group name for the user assigned managed identity. |
| keyName | string | <input type="checkbox"> | None | <pre>''</pre> | The name of the key in the key vault to use for encryption. If this is set, the storage account will be encrypted with a key from the key vault. |
| overrideNoIdentity | bool | <input type="checkbox"> | None | <pre>true</pre> | Determine that the storage account does not have an identity. If you want to use a cmk key,then you need to set this to false. Defaults to true for backwards compatibility. |
| allowBypassAcl | string | <input type="checkbox"> | `'AzureServices'` or `'None'` or `'Logging'` or `'Metrics'` or `'Logging, Metrics'` or `'Logging, Metrics, AzureServices'` | <pre>'None'</pre> | Specifies whether traffic is bypassed for Logging/Metrics/AzureServices. <br>Possible values are any combination of Logging,Metrics,AzureServices (For example, "Logging, Metrics"), or None to bypass none of those traffics. |
| isHnsEnabled | bool | <input type="checkbox"> | None | <pre>false</pre> | Account HierarchicalNamespace enabled if set to true. Can only be set at account creation time.  |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| storageAccountName | string | Output the resource name for this storage account. |
| storageAccountResourceId | string | Output the resource id of this storage account. |
| storageAccountPrimaryEndpoint | object | Output the primary endpoint for this storage account. |
| storageAccountApiVersion | string | Output the API Version for this storage account. |

## Examples
<pre>
module storageaccount 'br:contosoregistry.azurecr.io/storage/storageaccounts:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 60), 'stg')
  params: {
    storageAccountKind: 'StorageV2'
    storageAccountName: storageAccountName
    storageAccountSku: 'Standard_LRS'
    location: location
  }
}
</pre>
<p>Creates a storage account with the name storageAccountName</p>

## Links
- [Bicep Storage Account](https://learn.microsoft.com/en-us/azure/templates/microsoft.storage/storageaccounts?pivots=deployment-language-bicep)
