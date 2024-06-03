# configurationStores

Target Scope: resourceGroup

## Synopsis
Creating Azure App Configuration

## Description
This module is used for creating Azure App Configuration

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| configurationStoreName | string | <input type="checkbox" checked> | Length between 5-50 | <pre></pre> | The name of the App Configuration store to upsert<br>Restrictions:<br>- Name must be between 5 and 50 characters and may only contain alphanumeric characters and -<br>- Name may not contain the sequence: --- |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location. |
| skuName | 'Free' | 'Standard' | <input type="checkbox"> | None | <pre>'Standard'</pre> | Specifies whether the SKU for the configuration store. |
| identity | { | <input type="checkbox" checked> | None | <pre></pre> | Managed service identity to use for this configuration store. Defaults to a system assigned managed identity. For object format, refer to [documentation](https://docs.microsoft.com/en-us/azure/templates/microsoft.web/sites?tabs=bicep#managedserviceidentity). |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| publicNetworkAccess | 'Enabled' | 'Disabled' | <input type="checkbox"> | None | <pre>'Disabled'</pre> | Property to specify whether the store will accept traffic from public internet. If set to \'Disabled\' all traffic except private endpoint traffic will be blocked. |
| disableLocalAuth | bool | <input type="checkbox"> | None | <pre>true</pre> | Indicates whether requests using non-AAD authentication are blocked. |
| enablePurgeProtection | bool | <input type="checkbox"> | None | <pre>true</pre> | Indicates whether purge protection should be enabled. |
| softDeleteRetentionInDays | int | <input type="checkbox"> | Value between 1-7 | <pre>7</pre> | The soft-delete retention for keeping items after deleting them. |
| configurationValues | { | <input type="checkbox" checked> | None | <pre></pre> | The configuration values to add to the App Configuration store. Provide an empty string for the \'label\' property if a label is not required. |

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
    identity 'SystemAssigned'
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
