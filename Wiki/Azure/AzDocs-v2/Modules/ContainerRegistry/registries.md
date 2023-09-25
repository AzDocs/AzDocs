# registries

Target Scope: resourceGroup

## Synopsis
Creating a Azure Container Registry.

## Description
Creating an Azure Container Registry with the given specs.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| containerRegistryName | string | <input type="checkbox" checked> | Length between 5-50 | <pre></pre> | The name of the Azure Container Registry to be upserted. |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location. |
| diagnosticsName | string | <input type="checkbox"> | Length between 1-260 | <pre>'AzurePlatformCentralizedLogging'</pre> | The name of the diagnostics. This defaults to `AzurePlatformCentralizedLogging`. |
| logAnalyticsWorkspaceResourceId | string | <input type="checkbox" checked> | Length between 0-* | <pre></pre> | The azure resource id of the log analytics workspace to log the diagnostics to. If you set this to an empty string, logging & diagnostics will be disabled. |
| diagnosticSettingsLogsCategories | array | <input type="checkbox"> | None | <pre>[<br>  {<br>    categoryGroup: 'allLogs'<br>    enabled: true<br>  }<br>]</pre> | Which log categories to enable; This defaults to `allLogs`. For array/object format, please refer to the [specifications](https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep#logsettings). |
| diagnosticSettingsMetricsCategories | array | <input type="checkbox"> | None | <pre>[<br>  {<br>    categoryGroup: 'AllMetrics'<br>    enabled: true<br>  }<br>]</pre> | Which Metrics categories to enable; This defaults to `AllMetrics`. For array/object format, please refer to the [specifications](https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep&pivots=deployment-language-bicep#metricsettings) |
| identity | object | <input type="checkbox"> | None | <pre>{<br>  type: 'SystemAssigned'<br>}</pre> | Sets the identity property for the container registry<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;type: 'UserAssigned'<br>&nbsp;&nbsp;&nbsp;userAssignedIdentities: userAssignedIdentities<br>}' |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| skuName | string | <input type="checkbox"> | `'Basic'` or `'Classic'` or `'Premium'` or `'Standard'` | <pre>'Premium'</pre> | The sku of this Azure Container Registry. |
| adminUserEnabled | bool | <input type="checkbox"> | None | <pre>false</pre> | Enable the admin user to login with a username & password to this ACR. |
| anonymousPullEnabled | bool | <input type="checkbox"> | None | <pre>false</pre> | Allow pulling without being authenticated against this Azure Container Registry. |
| allowAzureServicesNetworkBypass | bool | <input type="checkbox"> | None | <pre>false</pre> | If you want to allow trusted azure services to bypass your network settings, enable this. |
| publicNetworkAccess | bool | <input type="checkbox"> | None | <pre>false</pre> | The default network action for this Azure Container Registry. |
| ipRules | array | <input type="checkbox"> | None | <pre>[]</pre> | An array of IP Rules to apply to this Azure Container Registry. For object structure, please refer to the [specification](https://learn.microsoft.com/en-us/azure/templates/microsoft.containerregistry/registries?pivots=deployment-language-bicep#iprule). |
| policies | object | <input type="checkbox"> | None | <pre>{}</pre> | The policies to apply on this ACR. For object structure, please refer to the [specifications](https://learn.microsoft.com/en-us/azure/templates/microsoft.containerregistry/registries?pivots=deployment-language-bicep#policies). |
| zoneRedundancy | string | <input type="checkbox"> | `'Enabled'` or `'Disabled'` | <pre>'Disabled'</pre> | Enable zone redundancy for this ACR. |
| dataEndpointEnabled | bool | <input type="checkbox"> | None | <pre>false</pre> | Enable data endpoint for this ACR. |
| networkRuleSet | object | <input type="checkbox"> | None | <pre>empty(ipRules) ? {</pre> | Setting up the networkRuleSet and add ip rules if any are defined. |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| acrRegistryLoginServer | string | Output the login server property for later use. |
| acrRegistryId | string | Output the resourceId of the azure container registry |
| acrRegistryName | string | Output the name of the azure container registry. |
## Examples
<pre>
module acr '../../AzDocs/src-bicep/ContainerRegistry/registries.bicep' = {
  name: format('{0}-{1}', take('${deployment().name}', 48), 'acrDeploy')
  params: {
    tags: tags
    anonymousPullEnabled: true
    containerRegistryName: containerRegistryName
    logAnalyticsWorkspaceResourceId: logAnalyticsWorkspaceResourceId
    location: location
    skuName: 'Premium'
    publicNetworkAccess: true
    policies: {
      azureADAuthenticationAsArmPolicy: {
        status: 'enabled'
      }
      quarantinePolicy: {
        status: 'disabled'
      }
      retentionPolicy: {
        days: 30
        status: 'enabled'
      }
      trustPolicy: {
        status: 'enabled'
        type: 'Notary'
      }

    }
  }
}
</pre>
<p>Creates an acr with the name containerRegistryName</p>

## Links
- [Bicep Microsoft.ContainerRegistry registries](https://learn.microsoft.com/en-us/azure/templates/microsoft.containerregistry/registries?pivots=deployment-language-bicep)<br>
- [azureADAuthenticationAsArmPolicy](https://www.azadvertizer.net/azpolicyadvertizer/42781ec6-6127-4c30-bdfa-fb423a0047d3.html)<br>
- [quarantinePolicy](https://github.com/Azure/acr/tree/main/docs/preview/quarantine)<br>
- [quarantinePolicy](https://samcogan.com/image-quarantine-in-azure-container-registry/)<br>
- [retentionPolicy](https://learn.microsoft.com/en-us/azure/container-registry/container-registry-retention-policy)<br>
- [trustPolicy](https://learn.microsoft.com/en-us/azure/container-registry/container-registry-content-trust)


