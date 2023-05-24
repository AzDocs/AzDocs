# profiles

Target Scope: resourceGroup

## Synopsis
Creating a FrontDoor Cdn profile

## Description
Creating a FrontDoor Cdn profile. This creates an Azure FrontDoor Standard or Premium. It cannot not create a FrontDoor Classic, this is in a different namespace.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| frontDoorName | string | <input type="checkbox" checked> | Length between 1-260 | <pre></pre> | The name of the Front Door profile to create. This must be globally unique. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| identity | object | <input type="checkbox"> | None | <pre>{<br>  type: 'SystemAssigned'<br>}</pre> | Sets the identity property for the frontdoor profile<br>Examples:<br><details><br>&nbsp;&nbsp;&nbsp;<summary>Click to show example</summary><br>{<br>&nbsp;&nbsp;&nbsp;type: 'UserAssigned'<br>&nbsp;&nbsp;&nbsp;userAssignedIdentities: {}<br>},<br>{<br>&nbsp;&nbsp;&nbsp;type: 'SystemAssigned'<br>}<br></details> |
| skuName | string | <input type="checkbox"> | `'Standard_AzureFrontDoor'` or `'Premium_AzureFrontDoor'` | <pre>'Standard_AzureFrontDoor'</pre> | The name of the SKU to use when creating the Front Door profile. |
| frontDoorProfileOriginResponseTimeoutSeconds | int | <input type="checkbox"> | None | <pre>60</pre> | The origin response timeout in seconds. Valid values are 1-86400. |
| diagnosticsName | string | <input type="checkbox"> | Length between 1-260 | <pre>'AzurePlatformCentralizedLogging'</pre> | The name of the diagnostics. This defaults to `AzurePlatformCentralizedLogging`. |
| logAnalyticsWorkspaceResourceId | string | <input type="checkbox"> | Length between 0-* | <pre>''</pre> | The azure resource id of the log analytics workspace to log the diagnostics to. If you set this to an empty string, logging & diagnostics will be disabled. |
| diagnosticSettingsLogsCategories | array | <input type="checkbox"> | None | <pre>[<br>  {<br>    categoryGroup: 'allLogs'<br>    enabled: true<br>  }<br>]</pre> | Which log categories to enable; This defaults to `allLogs`. For array/object format, please refer to [the docs](https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep#logsettings.) |
| diagnosticSettingsMetricsCategories | array | <input type="checkbox"> | None | <pre>[<br>  {<br>    categoryGroup: 'AllMetrics'<br>    enabled: true<br>  }<br>]</pre> | Which Metrics categories to enable; This defaults to `AllMetrics`. For array/object format, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep&pivots=deployment-language-bicep#metricsettings |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| frontDoorName | string | Output the frontdoor profile\'s name. |
| frontDoorProfileResourceId | string | Output the frontdoor profile\'s resource id. |
| frontDoorPrincipalId | string | Output the logic app\'s identity principal object id. |
## Examples
<pre>
module frontDoorProfile 'br:contosoregistry.azurecr.io/cdn/profiles:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 51), 'fdoorprofile')
  params: {
    frontDoorName: frontDoorName
    skuName: 'Premium_AzureFrontDoor'
  }
}
</pre>
<p>Creates a Frontdoor Cdn Profile with the name cdnp-frontdoorname and a Premium sku.</p>

## Links
- [Bicep Microsoft.Cdn profiles](https://learn.microsoft.com/en-us/azure/templates/microsoft.cdn/profiles?pivots=deployment-language-bicep)


