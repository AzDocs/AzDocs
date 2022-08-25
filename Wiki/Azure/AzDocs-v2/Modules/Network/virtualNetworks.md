# virtualNetworks

Target Scope: resourceGroup

## Synopsis
Creating a Vnet

## Description
Creating a virtual network with the proper settings

## Security Default
- applied nsg

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| virtualNetworkName | string | <input type="checkbox" checked> | Length between 2-64 | <pre></pre> | The name for the Virtual Network to upsert. |
| virtualNetworkAddressPrefixes | array | <input type="checkbox"> | Length between 1-* | <pre>[ '10.0.0.0/16' ]</pre> | A list of address prefixes for the VNet (CIDR notation). This can be IPv4 and IPv6 mixed.<br>For example:<br>[<br>&nbsp;&nbsp;&nbsp;'10.0.0.0/16'<br>&nbsp;&nbsp;&nbsp;'fdfd:fdfd::/110'<br>] |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location. |
| subnets | array | <input type="checkbox"> | None | <pre>[]</pre> | The subnets to upsert in this VNet. NOTE: Subnets which are present in your existing VNet and are not in this list, will be removed. For array/object format please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.network/virtualnetworks?tabs=bicep#subnet. |
| dnsServers | array | <input type="checkbox"> | None | <pre>[]</pre> | DNS Servers to apply to this virtual network. Format is an array/list of IP\'s |
| logAnalyticsWorkspaceResourceId | string | <input type="checkbox" checked> | Length between 0-* | <pre></pre> | The azure resource id of the log analytics workspace to log the diagnostics to. If you set this to an empty string, logging & diagnostics will be disabled. |
| diagnosticsName | string | <input type="checkbox"> | Length between 1-260 | <pre>'AzurePlatformCentralizedLogging'</pre> | The name of the diagnostics. This defaults to `AzurePlatformCentralizedLogging`. |
| diagnosticSettingsLogsCategories | array | <input type="checkbox"> | None | <pre>[<br>  {<br>    categoryGroup: 'allLogs'<br>    enabled: true<br>  }<br>]</pre> | Which log categories to enable; This defaults to `allLogs`. For array/object format, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep#logsettings. |
| diagnosticSettingsMetricsCategories | array | <input type="checkbox"> | None | <pre>[<br>  {<br>    categoryGroup: 'AllMetrics'<br>    enabled: true<br>  }<br>]</pre> | Which Metrics categories to enable; This defaults to `AllMetrics`. For array/object format, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep&pivots=deployment-language-bicep#metricsettings |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| virtualNetworkName | string | Outputs the Virtual Network resourcename. |
## Examples
<pre>
module vnet '../../AzDocs/src-bicep/Network/virtualNetworks.bicep' = {
  name: 'Creating_vnet_MyFirstVnet'
  scope: resourceGroup
  params: {
    vnetName: 'MyFirstVnet'
    logAnalyticsWorkspaceResourceId: logAnalyticsWorkspaceResourceId
  }
}
</pre>
<p>Creates a virtual network</p>

## Links
- [Bicep Vnet documentation](https://docs.microsoft.com/en-us/azure/templates/microsoft.network/2022-01-01/virtualnetworks?pivots=deployment-language-bicep)


