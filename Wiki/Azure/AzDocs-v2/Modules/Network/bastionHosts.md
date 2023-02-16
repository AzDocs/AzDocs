# bastionHosts

Target Scope: resourceGroup

## Synopsis
Creating a Bastion Host.

## Description
Creating a Bastion Host with the given specs.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location. |
| bastionHostName | string | <input type="checkbox" checked> | Length between 1-80 | <pre></pre> | Specifies the name of the Azure Bastion resource. |
| bastionHostDisableCopyPaste | bool | <input type="checkbox"> | None | <pre>false</pre> | Enable/Disable Copy/Paste feature of the Bastion Host resource. |
| bastionHostEnableFileCopy | bool | <input type="checkbox"> | None | <pre>false</pre> | Enable/Disable File Copy (between Host & Client) feature of the Bastion Host resource. |
| bastionHostEnableIpConnect | bool | <input type="checkbox"> | None | <pre>false</pre> | Enable/Disable IP Connect feature of the Bastion Host resource. This will allow you to connect to VM\'s (either azure or non-azure) using the VM\'s private IP address through Bastion. |
| bastionHostEnableShareableLink | bool | <input type="checkbox"> | None | <pre>false</pre> | Enable/Disable Shareable Link of the Bastion Host resource which is a URL to the bastion remote to the VM. |
| bastionHostEnableTunneling | bool | <input type="checkbox"> | None | <pre>false</pre> | Enable/Disable Tunneling feature of the Bastion Host resource.<br>SSH tunneling is a method of transporting arbitrary networking data over an encrypted SSH connection. It can be used to add encryption to legacy applications. It can also be used to implement VPNs (Virtual Private Networks) and access intranet services across firewalls. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| bastionSubnetName | string | <input type="checkbox"> | Length between 1-80 | <pre>'AzureBastionSubnet'</pre> | Name of the Azure Bastion subnet. This is probably going to have to be `AzureBastionSubnet` due to Azure restrictions. |
| bastionPublicIpAddressName | string | <input type="checkbox"> | Length between 1-80 | <pre>'pip-&#36;{bastionHostName}'</pre> | The resource name of the Public IP for this Azure Bastion host. |
| vnetName | string | <input type="checkbox"> | Length between 2-64 | <pre>''</pre> | The VNet name to onboard this Azure Bastion Host into. |
| bastionHostSku | string | <input type="checkbox"> | `'Basic'` or  `'Standard'` | <pre>'Standard'</pre> | The sku for the Bastion host. |
| bastionVirtualNetworkResourceGroupName | string | <input type="checkbox" checked> | None | <pre></pre> | The resource group of the virtual network the bastion subnet is in. |
| diagnosticsName | string | <input type="checkbox"> | Length between 1-260 | <pre>'AzurePlatformCentralizedLogging'</pre> | The name of the diagnostics. This defaults to `AzurePlatformCentralizedLogging`. |
| logAnalyticsWorkspaceResourceId | string | <input type="checkbox" checked> | Length between 0-* | <pre></pre> | The azure resource id of the log analytics workspace to log the diagnostics to. If you set this to an empty string, logging & diagnostics will be disabled. |
| diagnosticSettingsLogsCategories | array | <input type="checkbox"> | None | <pre>[<br>  {<br>    categoryGroup: 'allLogs'<br>    enabled: true<br>  }<br>]</pre> | Which log categories to enable; This defaults to `allLogs`. For array/object format, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep#logsettings. |
| diagnosticSettingsMetricsCategories | array | <input type="checkbox"> | None | <pre>[<br>  {<br>    categoryGroup: 'AllMetrics'<br>    enabled: true<br>  }<br>]</pre> | Which Metrics categories to enable; This defaults to `AllMetrics`. For array/object format, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep&pivots=deployment-language-bicep#metricsettings |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| bastionHostName | string | Outputs the name of the created Bastion Host. |
## Examples
<pre>
module bastion '../../AzDocs/src-bicep/Network/bastionHosts.bicep' = {
  name: '${deployment().name}-bastion'
  params: {
    bastionHostName: bastionHostName
    location: location
    vnetName: vnetExisting.name
    bastionHostEnableFileCopy: true
    bastionHostEnableTunneling: true
  }
}
</pre>
<p>Creates a Bastion Host with the name bastionHostName that has native client support and allows copy and paste.</p>

## Links
- [Bicep Microsoft.Network bastionHosts](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/bastionhosts?pivots=deployment-language-bicep)<br>
- [Bastion and NSGs](https://learn.microsoft.com/en-gb/azure/bastion/bastion-nsg)


