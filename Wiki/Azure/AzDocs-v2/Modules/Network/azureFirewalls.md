# azureFirewalls

Target Scope: resourceGroup

## User Defined Types
| Name | Type | Discriminator | Description
| -- |  -- | -- | -- |
| <a id="hubIPAddressesType">hubIPAddressesType</a>  | <pre>{</pre> |  | The type for the hub IP addresses. | 
| <a id="natRuleCollectionType">natRuleCollectionType</a>  | <pre>{</pre> |  | The type for a NAT rule collection. | 
| <a id="applicationRuleCollectionType">applicationRuleCollectionType</a>  | <pre>{</pre> |  | The type for an application rule collection. | 
| <a id="networkRuleCollectionType">networkRuleCollectionType</a>  | <pre>{</pre> |  | The type for a network rule collection. | 

## Synopsis
Azure Firewall module for Bicep - Enhanced version with backwards compatibility.<br>


## Description
Add an Azure Firewall to the resource group. The firewall policy is optional and when left out, it will create a classic firewall.<br>
This version combines the original functionality with enhanced features from v2 while maintaining full backwards compatibility.<br>
<br>
BACKWARDS COMPATIBILITY:<br>
- All existing parameters from the original template are preserved<br>
- Existing deployments will continue to work without any changes<br>
- Original parameter names (azureFirewallName, azureFirewallIpConfigurations, etc.) are maintained<br>
- Original diagnostic settings behavior is preserved<br>
<br>
ENHANCED FEATURES (V2):<br>
- Typed rule collections with enhanced validation (applicationRuleCollectionType, networkRuleCollectionType, natRuleCollectionType)<br>
- Advanced diagnostic settings supporting multiple destinations (storage, event hub, etc.)<br>
- Role assignments and resource locking capabilities<br>
- Forced tunneling support<br>
- Enhanced Public IP management<br>
- AVM-compliant telemetry and structure<br>
<br>
MIGRATION PATH:<br>
- Continue using existing parameters for current deployments<br>
- Gradually adopt new v2 parameters for enhanced features<br>
- Use typed rule collections for better validation and IntelliSense<br>
- Switch to enhanced diagnostic settings for multi-destination logging<br>


## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Location for all resources. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| azureFirewallName | string | <input type="checkbox" checked> | None | <pre></pre> | The name for the Azure Firewall. |
| name | string | <input type="checkbox"> | None | <pre>azureFirewallName</pre> | Optional. Alternative name parameter (AVM standard). If not provided, uses azureFirewallName. |
| firewallPolicyId | string | <input type="checkbox"> | None | <pre>''</pre> | Optional. Resource ID of the Firewall Policy that should be attached. |
| azureFirewallIpConfigurations | array | <input type="checkbox"> | None | <pre>[]</pre> | The ipconfigurations in the Azure Firewall based on one or more Public Ips and a subnet. |
| virtualNetworkResourceId | string | <input type="checkbox"> | None | <pre>''</pre> | Conditional. Shared services Virtual Network resource ID. The virtual network ID containing AzureFirewallSubnet. If a Public IP is not provided, then the Public IP that is created as part of this module will be applied with the subnet provided in this variable. Required if `virtualHubId` is empty. |
| publicIPResourceID | string | <input type="checkbox"> | None | <pre>''</pre> | Optional. The Public IP resource ID to associate to the AzureFirewallSubnet. If empty, then the Public IP that is created as part of this module will be applied to the AzureFirewallSubnet. |
| additionalPublicIpConfigurations | array | <input type="checkbox"> | None | <pre>[]</pre> | Optional. This is to add any additional Public IP configurations on top of the Public IP with subnet IP configuration. |
| publicIPAddressObject | object | <input type="checkbox"> | None | <pre>{}</pre> | Optional. Specifies the properties of the Public IP to create and be used by the Firewall, if no existing public IP was provided. |
| managementIPResourceID | string | <input type="checkbox"> | None | <pre>''</pre> | Optional. The Management Public IP resource ID to associate to the AzureFirewallManagementSubnet. If empty, then the Management Public IP that is created as part of this module will be applied to the AzureFirewallManagementSubnet. |
| managementIPAddressObject | object | <input type="checkbox"> | None | <pre>{}</pre> | Optional. Specifies the properties of the Management Public IP to create and be used by Azure Firewall. If it\'s not provided and managementIPResourceID is empty, a \'-mip\' suffix will be appended to the Firewall\'s name. |
| networkRuleCollections | array | <input type="checkbox"> | None | <pre>[]</pre> | The network rule collections in the Azure Firewall. |
| applicationRuleCollections | array | <input type="checkbox"> | None | <pre>[]</pre> | The application rule collections in the Azure Firewall. |
| natRuleCollections | array | <input type="checkbox"> | None | <pre>[]</pre> | The nat rule collections in the Azure Firewall. |
| applicationRuleCollectionsTyped | applicationRuleCollectionType[]? | <input type="checkbox" checked> | None | <pre></pre> | Optional. Collection of application rule collections used by Azure Firewall (typed version). |
| networkRuleCollectionsTyped | networkRuleCollectionType[]? | <input type="checkbox" checked> | None | <pre></pre> | Optional. Collection of network rule collections used by Azure Firewall (typed version). |
| natRuleCollectionsTyped | natRuleCollectionType[]? | <input type="checkbox" checked> | None | <pre></pre> | Optional. Collection of NAT rule collections used by Azure Firewall (typed version). |
| availabilityZones | array | <input type="checkbox"> | None | <pre>[]</pre> | The availability zones for the Azure Firewall. |
| zones | array | <input type="checkbox"> | None | <pre>[<br>  1<br>  2<br>  3<br>]</pre> | Optional. Zone numbers e.g. 1,2,3. |
| AzureFirewallSkuName | string | <input type="checkbox"> | `'AZFW_Hub'` or `'AZFW_VNet'` | <pre>'AZFW_VNet'</pre> | The name of the Azure Firewall SKU. |
| AzureFirewallSkuTier | string | <input type="checkbox"> | `'Basic'` or `'Premium'` or `'Standard'` | <pre>'Standard'</pre> | Optional. Tier of an Azure Firewall. |
| azureSkuTier | string | <input type="checkbox"> | `'Basic'` or `'Standard'` or `'Premium'` | <pre>AzureFirewallSkuTier</pre> | Optional. Tier of an Azure Firewall (v2 parameter name). |
| threatIntelMode | string | <input type="checkbox"> | `'Alert'` or `'Deny'` or `'Off'` | <pre>'Alert'</pre> | The operation mode for Threat Intelligence. |
| autoscaleConfiguration | object | <input type="checkbox"> | None | <pre>{<br>  maxCapacity: null<br>  minCapacity: null<br>}</pre> | Properties to provide a custom autoscale configuration to this azure firewall. Constraints: Min value for both = 2 |
| hubIPAddresses | hubIPAddressesType? | <input type="checkbox" checked> | None | <pre></pre> | Conditional. IP addresses associated with AzureFirewall. Required if `virtualHubId` is supplied. |
| virtualHubId | string | <input type="checkbox"> | None | <pre>''</pre> | Optional. The resource ID of the Virtual Hub to associate with the Azure Firewall. |
| enableForcedTunneling | bool | <input type="checkbox"> | None | <pre>false</pre> | Optional. Enable/Disable forced tunneling. |
| diagnosticSettings | diagnosticSettingFullType[]? | <input type="checkbox" checked> | None | <pre></pre> | Optional. The diagnostic settings of the service. |
| diagnosticsName | string | <input type="checkbox"> | Length between 1-260 | <pre>'AzurePlatformCentralizedLogging'</pre> | The name of the diagnostics. This defaults to `AzurePlatformCentralizedLogging`. |
| logAnalyticsWorkspaceResourceId | string | <input type="checkbox"> | Length between 0-* | <pre>''</pre> | The azure resource id of the log analytics workspace to log the diagnostics to. If you set this to an empty string, logging & diagnostics will be disabled. |
| diagnosticSettingsLogsCategories | array | <input type="checkbox"> | None | <pre>[<br>  {<br>    categoryGroup: 'allLogs'<br>    enabled: true<br>  }<br>]</pre> | Which log categories to enable; This defaults to `allLogs`. For array/object format, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep#logsettings. |
| diagnosticSettingsMetricsCategories | array | <input type="checkbox"> | None | <pre>[<br>  {<br>    categoryGroup: 'AllMetrics'<br>    enabled: true<br>  }<br>]</pre> | Which Metrics categories to enable; This defaults to `AllMetrics`. For array/object format, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep&pivots=deployment-language-bicep#metricsettings |
| lock | lockType? | <input type="checkbox" checked> | None | <pre></pre> | Optional. The lock settings of the service. |
| roleAssignments | roleAssignmentType[]? | <input type="checkbox" checked> | None | <pre></pre> | Optional. Array of role assignments to create. |
| enableTelemetry | bool | <input type="checkbox"> | None | <pre>true</pre> | Optional. Enable/Disable usage telemetry for module. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| azureFirewallId | string | The id of the Azure Firewall. |
| azureFirewallName | string | The name of the Azure Firewall. |
| resourceId | string | The resource ID of the Azure Firewall. |
| name | string | The name of the Azure Firewall. |
| resourceGroupName | string | The resource group the Azure firewall was deployed into. |
| privateIp | string | The private IP of the Azure firewall. |
| ipConfAzureFirewallSubnet | object | The Public IP configuration object for the Azure Firewall Subnet. |
| applicationRuleCollections | array | List of Application Rule Collections used by Azure Firewall. |
| networkRuleCollections | array | List of Network Rule Collections used by Azure Firewall. |
| natRuleCollections | array | List of NAT rule collections used by Azure Firewall. |
| location | string | The location the resource was deployed into. |

## Examples
<pre>
// Original usage (fully supported)
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

<pre>
// Enhanced usage with v2 features
module azurefirewall 'br:contosoregistry.azurecr.io/network/azurefirewalls.bicep' = {
  name: format('{0}-{1}', take('${deployment().name}', 59), 'azfw')
  params: {
    location: location
    azureFirewallName: azureFirewallName
    virtualNetworkResourceId: vnetId
    applicationRuleCollectionsTyped: typedAppRules
    networkRuleCollectionsTyped: typedNetworkRules
    diagnosticSettings: enhancedDiagnostics
    roleAssignments: rbacAssignments
    lock: { kind: 'CanNotDelete' }
  }
}
</pre>

