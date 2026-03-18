# defenderForStorageSettings

Target Scope: resourceGroup

## Synopsis
Configuring Defender for Storage settings on a Storage Account

## Description
Configures Microsoft Defender for Storage settings on a specific Storage Account.<br>
Can be used to override subscription-level Defender for Storage settings for individual storage accounts,<br>
for example to disable malware scanning on storage accounts that do not require it.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| storageAccountName | string | <input type="checkbox" checked> | Length between 3-24 | <pre></pre> | The name of the storage account to configure Defender for Storage settings on. |
| isEnabled | bool | <input type="checkbox" checked> | None | <pre></pre> | Whether Defender for Storage is enabled on this storage account. |
| malwareScanningOnUploadEnabled | bool | <input type="checkbox"> | None | <pre>true</pre> | Whether on-upload malware scanning is enabled. Only applicable when isEnabled is true. |
| malwareScanningOnUploadCapGBPerMonth | int | <input type="checkbox"> | None | <pre>10000</pre> | The monthly cap in GB for on-upload malware scanning per storage account.<br>Use -1 for unlimited scanning. Default is 10000 GB.<br>Only applicable when malware scanning is enabled. |
| sensitiveDataDiscoveryEnabled | bool | <input type="checkbox"> | None | <pre>true</pre> | Whether sensitive data discovery is enabled. Only applicable when isEnabled is true. |
| overrideSubscriptionLevelSettings | bool | <input type="checkbox"> | None | <pre>true</pre> | Whether to override subscription-level Defender for Storage settings. Must be true when configuring per-account settings. |

## Examples
<pre>
module defenderForStorageSettings 'Security/defenderForStorageSettings.bicep' = {
  name: 'defenderForStorageSettings'
  params: {
    storageAccountName: 'mystorageaccount'
    isEnabled: false
    overrideSubscriptionLevelSettings: true
  }
}
</pre>
<p>Disables Defender for Storage on a specific storage account, overriding subscription-level settings.</p>
<pre>
module defenderForStorageSettings 'Security/defenderForStorageSettings.bicep' = {
  name: 'defenderForStorageSettings'
  params: {
    storageAccountName: 'mystorageaccount'
    isEnabled: true
    malwareScanningOnUploadEnabled: true
    malwareScanningOnUploadCapGBPerMonth: 5000
    sensitiveDataDiscoveryEnabled: true
    overrideSubscriptionLevelSettings: true
  }
}
</pre>
<p>Enables Defender for Storage on a specific storage account with custom malware scanning cap.</p>

## Links
- [Microsoft.Security/DefenderForStorageSettings API](https://learn.microsoft.com/en-us/rest/api/defenderforcloud-composite/defender-for-storage/create)<br>
- [Override subscription-level settings](https://learn.microsoft.com/en-us/azure/defender-for-cloud/advanced-configurations-for-malware-scanning#override-defender-for-storage-subscription-level-settings)<br>
- [Defender for Storage IaC enablement](https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-storage-infrastructure-as-code-enablement)
