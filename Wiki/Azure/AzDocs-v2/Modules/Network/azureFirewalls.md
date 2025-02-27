﻿# azureFirewalls

Target Scope: resourceGroup

## Synopsis
Azure Firewall module for Bicep.

## Description
Add an Azure Firewall to the resource group. The firewall policy is optional and when left out, it will create a classic firewall.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Location for all resources. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| azureFirewallName | string | <input type="checkbox" checked> | None | <pre></pre> | The name for the Azure Firewall. |
| firewallPolicyName | string | <input type="checkbox"> | None | <pre>''</pre> | The name of the existing firewall policy. |
| azureFirewallIpConfigurations | array | <input type="checkbox"> | None | <pre>[]</pre> | The ipconfigurations in the Azure Firewall based on one or more Public Ips and a subnet. |
| networkRuleCollections | array | <input type="checkbox"> | None | <pre>[]</pre> | The network rule collections in the Azure Firewall. |
| applicationRuleCollections | array | <input type="checkbox"> | None | <pre>[]</pre> | The application rule collections in the Azure Firewall. |
| natRuleCollections | array | <input type="checkbox"> | None | <pre>[]</pre> | The nat rule collections in the Azure Firewall. |
| availabilityZones | array | <input type="checkbox"> | None | <pre>[]</pre> | The availability zones for the Azure Firewall. |
| AzureFirewallSkuName | string | <input type="checkbox"> | `'AZFW_Hub'` or `'AZFW_VNet'` | <pre>'AZFW_VNet'</pre> | The name of the Azure Firewall SKU. |
| AzureFirewallSkuTier | string | <input type="checkbox"> | `'Basic'` or `'Premium'` or `'Standard'` | <pre>'Standard'</pre> | The tier of the Azure Firewall. |
| threatIntelMode | string | <input type="checkbox"> | `'Alert'` or `'Deny'` or `'Off'` | <pre>'Alert'</pre> | The operation mode for Threat Intelligence. |
| diagnosticsName | string | <input type="checkbox"> | Length between 1-260 | <pre>'AzurePlatformCentralizedLogging'</pre> | The name of the diagnostics. This defaults to `AzurePlatformCentralizedLogging`. |
| logAnalyticsWorkspaceResourceId | string | <input type="checkbox"> | Length between 0-* | <pre>''</pre> | The azure resource id of the log analytics workspace to log the diagnostics to. If you set this to an empty string, logging & diagnostics will be disabled. |
| diagnosticSettingsLogsCategories | array | <input type="checkbox"> | None | <pre>[<br>  {<br>    categoryGroup: 'allLogs'<br>    enabled: true<br>  }<br>]</pre> | Which log categories to enable; This defaults to `allLogs`. For array/object format, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep#logsettings. |
| diagnosticSettingsMetricsCategories | array | <input type="checkbox"> | None | <pre>[<br>  {<br>    categoryGroup: 'AllMetrics'<br>    enabled: true<br>  }<br>]</pre> | Which Metrics categories to enable; This defaults to `AllMetrics`. For array/object format, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep&pivots=deployment-language-bicep#metricsettings |
| firewallPolicyResourceGroupName | string | <input type="checkbox"> | None | <pre>resourceGroup().name</pre> | The resourcegroup name where the Azure Firewall Policy resource can be found. By default it can be found in the same resource group as the Azure Firewall. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| azureFirewallId | string | The id of the Azure Firewall. |
| azureFirewallName | string | The name of the Azure Firewall. |

## Examples
<pre>
module azurefirewall 'br:contosoregistry.azurecr.io/network/azurefirewalls.bicep' = {
  name: format('{0}-{1}', take('${deployment().name}', 59), 'azfw')
  params: {
    location: location
    azureFirewallName: azureFirewallName
    azureFirewallIpConfigurations: azureFirewallIpConfigurations
    networkRuleCollections: networkRuleCollection
    applicationRuleCollections: applicationRuleCollection
  }
  dependsOn: [publicip]
}
</pre>
<p>Creates a Firewall with the name of the parameter azureFirewallName.</p>
