# configurationStores

Target Scope: resourceGroup

## User Defined Types
| Name | Type | Discriminator | Description
| -- |  -- | -- | -- |
| <a id="IdentityType">IdentityType</a>  | <pre>&nbsp;&nbsp;&nbsp;&#124; {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;type: 'SystemAssigned'<br>&nbsp;&nbsp;&nbsp;}<br>&nbsp;&nbsp;&nbsp;&#124; {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;type: 'UserAssigned'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;userAssignedIdentities: {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;*: {}<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br>&nbsp;&nbsp;&nbsp;}<br>&nbsp;&nbsp;&nbsp;&#124; {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;type: 'None'<br>&nbsp;&nbsp;&nbsp;}<br></pre> | type |  | 
| <a id="ConfigurationValue">ConfigurationValue</a>  | <pre>{<br>&nbsp;&nbsp;&nbsp;key: string<br>&nbsp;&nbsp;&nbsp;value: string<br>&nbsp;&nbsp;&nbsp;label: string?<br>&nbsp;&nbsp;&nbsp;contentType: string?<br>}<br></pre> |  |  | 
| <a id="FeatureFlag">FeatureFlag</a>  | <pre>{<br>&nbsp;&nbsp;&nbsp;name: string<br>&nbsp;&nbsp;&nbsp;label: string?<br>&nbsp;&nbsp;&nbsp;value: {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;id: string<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;description: string<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;enabled: bool<br>&nbsp;&nbsp;&nbsp;}<br>}<br></pre> |  |  | 

## Synopsis
Creating Azure App Configuration

## Description
This module is used for creating Azure App Configuration

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| configurationStoreName | string | <input type="checkbox" checked> | Length between 5-50 | <pre></pre> | The name of the App Configuration store to upsert<br>Restrictions:<br>- Name must be between 5 and 50 characters and may only contain alphanumeric characters and -<br>- Name may not contain the sequence: --- |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location. |
| skuName | string | <input type="checkbox"> | `'Free'` or `'Standard'` | <pre>'Standard'</pre> | Specifies whether the SKU for the configuration store. |
| identity | [IdentityType](#IdentityType) | <input type="checkbox"> | None | <pre>{<br>  type: 'SystemAssigned'<br>}</pre> | Managed service identity to use for this configuration store. Defaults to a system assigned managed identity. For object format, refer to [documentation](https://docs.microsoft.com/en-us/azure/templates/microsoft.web/sites?tabs=bicep#managedserviceidentity). |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| publicNetworkAccess | string | <input type="checkbox"> | `'Enabled'` or `'Disabled'` | <pre>'Disabled'</pre> | Property to specify whether the store will accept traffic from public internet. If set to \'Disabled\' all traffic except private endpoint traffic will be blocked. |
| disableLocalAuth | bool | <input type="checkbox"> | None | <pre>true</pre> | Indicates whether requests using non-AAD authentication are blocked. |
| enablePurgeProtection | bool | <input type="checkbox"> | None | <pre>true</pre> | Indicates whether purge protection should be enabled. |
| softDeleteRetentionInDays | int | <input type="checkbox"> | Value between 1-7 | <pre>7</pre> | The soft-delete retention for keeping items after deleting them. |
| configurationValues | [ConfigurationValue](#ConfigurationValue)[] | <input type="checkbox"> | None | <pre>[]</pre> | The configuration values to add to the App Configuration store. |
| featureFlags | [FeatureFlag](#FeatureFlag)[] | <input type="checkbox"> | None | <pre>[]</pre> | The feature flags to add to the App Configuration store. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| configurationStoreName | string | The configuration store name. |
| configurationStoreId | string | The configuration store resource ID. |
| configurationStorePrincipalId | string | The system assigned identity principal ID. |

## Examples
<pre>
module configurationStore 'br:contosoregistry.azurecr.io/appconfiguration/configurationStores:latest' = {
  name: '${take(deployment().name, 57)}-acs'
  params:{
    configurationStoreName: configurationStoreName
    location: location
    skuName: 'Standard'
    identity: {
      type: 'SystemAssigned'
    }
    publicNetworkAccess: 'Disabled'
    disableLocalAuth: true
    enablePurgeProtection: true
    softDeleteRetentionInDays: 7
    configurationValues: [
      {
        key: 'EmailAddress'
        value: 'dev@example.com'
        label: 'Development'
      }
      {
        key: 'EmailAddress'
        value: 'prd@example.com'
        label: 'Production'
      }
    ]
  }
}
</pre>

## Links
- [Bicep Microsoft.AppConfiguration configurationStores](https://learn.microsoft.com/en-us/azure/templates/microsoft.appconfiguration/configurationstores?pivots=deployment-language-bicep)
