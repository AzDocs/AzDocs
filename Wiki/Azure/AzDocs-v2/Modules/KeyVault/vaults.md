# vaults

Target Scope: resourceGroup

## Synopsis
Creating Azure Key Vault

## Description
This module is used for creating Azure Key Vault

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| keyVaultName | string | <input type="checkbox" checked> | Length between 3-24 | <pre></pre> | The name of the KeyVault to upsert<br>Keyvault name restrictions:<br>- Keyvault names must be between 3 and 24 alphanumeric characters in length. The name must begin with a letter, end with a letter or digit, and not contain consecutive hyphens<br>- Your keyVaultName must be unique within Azure. |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location. |
| enabledForDeployment | bool | <input type="checkbox"> | None | <pre>false</pre> | Specifies whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the key vault. |
| enabledForDiskEncryption | bool | <input type="checkbox"> | None | <pre>false</pre> | Specifies whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys. |
| enabledForTemplateDeployment | bool | <input type="checkbox"> | None | <pre>false</pre> | Specifies whether Azure Resource Manager is permitted to retrieve secrets from the key vault. |
| enableRbacAuthorization | bool | <input type="checkbox"> | None | <pre>false</pre> | Property that controls how data actions are authorized. When true, the key vault will use Role Based Access Control (RBAC) for authorization of data actions, <br>and the access policies specified in vault properties will be ignored. <br>When false, the key vault will use the access policies specified in vault properties, and any policy stored on Azure Resource Manager will be ignored. <br>If null or not specified, the vault is created with the default value of false. |
| tenantId | string | <input type="checkbox"> | None | <pre>subscription().tenantId</pre> | Specifies the Azure Active Directory tenant ID that should be used for authenticating requests to the key vault. Get it by using Get-AzSubscription cmdlet. Defaults to the current subscription\'s tenant. |
| skuName | string | <input type="checkbox"> | `'standard'` or `'premium'` | <pre>'standard'</pre> | Specifies whether the key vault is a standard vault or a premium vault. |
| secrets | array | <input type="checkbox"> | None | <pre>[]</pre> | Specifies all secrets {"secretName":"","secretValue":""} wrapped in a secure object. |
| recoverKeyvault | bool | <input type="checkbox"> | None | <pre>false</pre> | Specifies if you need to recover a Keyvault. This is mandatory whenever a deleted keyvault with the same name already existed in your subscription. |
| subnetIdsToWhitelist | array | <input type="checkbox"> | None | <pre>[]</pre> | Specifies the Resource ID\'s of the subnet(s) you want to whitelist on the KeyVault |
| softDeleteRetentionInDays | int | <input type="checkbox" checked> | Value between 7-90 | <pre></pre> | The soft-delete retention for keeping items after deleting them. |
| publicNetworkAccess | string | <input type="checkbox"> | `'enabled'` or `'disabled'` | <pre>'enabled'</pre> | Property to specify whether the vault will accept traffic from public internet. If set to \'disabled\' all traffic except private endpoint traffic and that that originates from trusted services will be blocked. |
| networkAclDefaultAction | string | <input type="checkbox"> | None | <pre>'Deny'</pre> | Defines if you want to default allow & deny traffic coming from non-whitelisted sources. Defaults to deny for security reasons. |
| keyVaultnetworkAclsBypass | string | <input type="checkbox"> | `'AzureServices'` or `'None'` | <pre>'None'</pre> | Define a bypass for AzureServices. Defaults to \'None\' |
| diagnosticsName | string | <input type="checkbox"> | Length between 1-260 | <pre>'AzurePlatformCentralizedLogging'</pre> | The name of the diagnostics. This defaults to `AzurePlatformCentralizedLogging`. |
| logAnalyticsWorkspaceResourceId | string | <input type="checkbox" checked> | Length between 0-* | <pre></pre> | The azure resource id of the log analytics workspace to log the diagnostics to. If you set this to an empty string, logging & diagnostics will be disabled. |
| diagnosticSettingsLogsCategories | array | <input type="checkbox"> | None | <pre>[<br>  {<br>    categoryGroup: 'allLogs'<br>    enabled: true<br>  }<br>]</pre> | Which log categories to enable; This defaults to `allLogs`. For array/object format, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep#logsettings. |
| diagnosticSettingsMetricsCategories | array | <input type="checkbox"> | None | <pre>[<br>  {<br>    categoryGroup: 'AllMetrics'<br>    enabled: true<br>  }<br>]</pre> | Which Metrics categories to enable; This defaults to `AllMetrics`. For array/object format, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep&pivots=deployment-language-bicep#metricsettings |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| keyVaultName | string | The keyvault name. |
| keyVaultId | string | The keyvault resource id. |
| keyvaultSecrets | array | An array of secrets which were added to keyvault. Each object contains id & name parameters. |
## Examples
<pre>
module keyVault 'br:contosoregistry.azurecr.io/keyvault/vaults:latest' = {
  name: '${take(deployment().name, 57)}-kv'
  params:{
    keyVaultName: keyVaultName
    logAnalyticsWorkspaceResourceId: logAnalyticsWorkspaceResourceId
    softDeleteRetentionInDays: 30
    location: location
    skuName: 'standard'
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: true
    keyVaultnetworkAclsBypass: 'AzureServices'
    publicNetworkAccess: 'enabled'
  }
}
</pre>

## Links
- [Bicep Microsoft.KeyVault Vaults](https://learn.microsoft.com/en-us/azure/templates/microsoft.keyvault/vaults?pivots=deployment-language-bicep)


