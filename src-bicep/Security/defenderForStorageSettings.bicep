/*
.SYNOPSIS
Configuring Defender for Storage settings on a Storage Account
.DESCRIPTION
Configures Microsoft Defender for Storage settings on a specific Storage Account.
Can be used to override subscription-level Defender for Storage settings for individual storage accounts,
for example to disable malware scanning on storage accounts that do not require it.
.EXAMPLE
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
.EXAMPLE
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
.LINKS
- [Microsoft.Security/DefenderForStorageSettings API](https://learn.microsoft.com/en-us/rest/api/defenderforcloud-composite/defender-for-storage/create)
- [Override subscription-level settings](https://learn.microsoft.com/en-us/azure/defender-for-cloud/advanced-configurations-for-malware-scanning#override-defender-for-storage-subscription-level-settings)
- [Defender for Storage IaC enablement](https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-storage-infrastructure-as-code-enablement)
*/

// ================================================= Parameters =================================================

@description('The name of the storage account to configure Defender for Storage settings on.')
@minLength(3)
@maxLength(24)
param storageAccountName string

@description('Whether Defender for Storage is enabled on this storage account.')
param isEnabled bool

@description('Whether on-upload malware scanning is enabled. Only applicable when isEnabled is true.')
param malwareScanningOnUploadEnabled bool = true

@description('''
The monthly cap in GB for on-upload malware scanning per storage account.
Use -1 for unlimited scanning. Default is 10000 GB.
Only applicable when malware scanning is enabled.
''')
param malwareScanningOnUploadCapGBPerMonth int = 10000

@description('Whether sensitive data discovery is enabled. Only applicable when isEnabled is true.')
param sensitiveDataDiscoveryEnabled bool = true

@description('Whether to override subscription-level Defender for Storage settings. Must be true when configuring per-account settings.')
param overrideSubscriptionLevelSettings bool = true

// ================================================= Resources =================================================

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' existing = {
  name: storageAccountName
}

resource defenderForStorageSettings 'Microsoft.Security/defenderForStorageSettings@2022-12-01-preview' = {
  scope: storageAccount
  name: 'current'
  properties: {
    isEnabled: isEnabled
    malwareScanning: {
      onUpload: {
        isEnabled: isEnabled && malwareScanningOnUploadEnabled
        capGBPerMonth: malwareScanningOnUploadCapGBPerMonth
      }
    }
    sensitiveDataDiscovery: {
      isEnabled: isEnabled && sensitiveDataDiscoveryEnabled
    }
    overrideSubscriptionLevelSettings: overrideSubscriptionLevelSettings
  }
}
