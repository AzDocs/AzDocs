# azureFirewalls

Target Scope: resourceGroup

## User Defined Types
| Name | Type | Discriminator | Description
| -- |  -- | -- | -- |
| <a id="hubIPAddressesType">hubIPAddressesType</a>  | <pre>{<br>&nbsp;&nbsp;&nbsp;@description('Optional. Private IP Address associated with AzureFirewall.')<br>&nbsp;&nbsp;&nbsp;privateIPAddress: string?<br>&nbsp;&nbsp;&nbsp;@description('Optional. List of public IP addresses associated with AzureFirewall.')<br>&nbsp;&nbsp;&nbsp;publicIPs: {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Optional. The list of Public IP addresses associated with AzureFirewall or IP addresses to be retained.')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;addresses: [<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Optional. Public IP.')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;address: string?<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;]?<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Optional. Public IP address count.')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;count: int?<br>&nbsp;&nbsp;&nbsp;}?<br>}<br></pre> |  | The type for the hub IP addresses. | 
| <a id="natRuleCollectionType">natRuleCollectionType</a>  | <pre>{<br>&nbsp;&nbsp;&nbsp;@description('Required. Name of the NAT rule collection.')<br>&nbsp;&nbsp;&nbsp;name: string<br><br>&nbsp;&nbsp;&nbsp;@description('Required. Properties of the azure firewall NAT rule collection.')<br>&nbsp;&nbsp;&nbsp;properties: {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Required. The action type of a NAT rule collection.')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;action: {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Required. The type of action.')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;type: 'Dnat' &#124; 'Snat'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Required. Priority of the NAT rule collection.')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@minValue(100)<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@maxValue(65000)<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;priority: int<br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Required. Collection of rules used by a NAT rule collection.')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;rules: {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Required. Name of the NAT rule.')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;name: string<br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Optional. Description of the rule.')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;description: string?<br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Required. Array of AzureFirewallNetworkRuleProtocols applicable to this NAT rule.')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;protocols: ('TCP' &#124; 'UDP' &#124; 'Any' &#124; 'ICMP')[]<br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Optional. List of destination IP addresses for this rule. Supports IP ranges, prefixes, and service tags.')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;destinationAddresses: string[]?<br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Optional. List of destination ports.')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;destinationPorts: string[]?<br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Optional. List of source IP addresses for this rule.')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;sourceAddresses: string[]?<br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Optional. List of source IpGroups for this rule.')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;sourceIpGroups: string[]?<br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Optional. The translated address for this NAT rule.')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;translatedAddress: string?<br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Optional. The translated FQDN for this NAT rule.')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;translatedFqdn: string?<br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Optional. The translated port for this NAT rule.')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;translatedPort: string?<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}[]<br>&nbsp;&nbsp;&nbsp;}<br>}<br></pre> |  | The type for a NAT rule collection. | 
| <a id="applicationRuleCollectionType">applicationRuleCollectionType</a>  | <pre>{<br>&nbsp;&nbsp;&nbsp;@description('Required. Name of the application rule collection.')<br>&nbsp;&nbsp;&nbsp;name: string<br><br>&nbsp;&nbsp;&nbsp;@description('Required. Properties of the azure firewall application rule collection.')<br>&nbsp;&nbsp;&nbsp;properties: {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Required. The action type of a rule collection.')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;action: {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Required. The type of action.')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;type: 'Allow' &#124; 'Deny'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Required. Priority of the application rule collection.')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@minValue(100)<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@maxValue(65000)<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;priority: int<br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Required. Collection of rules used by a application rule collection.')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;rules: {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Required. Name of the application rule.')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;name: string<br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Optional. Description of the rule.')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;description: string?<br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Required. Array of ApplicationRuleProtocols.')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;protocols: {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Optional. Port number for the protocol.')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@maxValue(64000)<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;port: int?<br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Required. Protocol type.')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;protocolType: 'Http' &#124; 'Https' &#124; 'Mssql'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}[]<br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Optional. List of FQDN Tags for this rule.')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;fqdnTags: string[]?<br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Optional. List of FQDNs for this rule.')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;targetFqdns: string[]?<br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Optional. List of source IP addresses for this rule.')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;sourceAddresses: string[]?<br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Optional. List of source IpGroups for this rule.')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;sourceIpGroups: string[]?<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}[]<br>&nbsp;&nbsp;&nbsp;}<br>}<br></pre> |  | The type for an application rule collection. | 
| <a id="networkRuleCollectionType">networkRuleCollectionType</a>  | <pre>{<br>&nbsp;&nbsp;&nbsp;@description('Required. Name of the network rule collection.')<br>&nbsp;&nbsp;&nbsp;name: string<br><br>&nbsp;&nbsp;&nbsp;@description('Required. Properties of the azure firewall network rule collection.')<br>&nbsp;&nbsp;&nbsp;properties: {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Required. The action type of a rule collection.')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;action: {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Required. The type of action.')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;type: 'Allow' &#124; 'Deny'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Required. Priority of the network rule collection.')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@minValue(100)<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@maxValue(65000)<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;priority: int<br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Required. Collection of rules used by a network rule collection.')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;rules: {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Required. Name of the network rule.')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;name: string<br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Optional. Description of the rule.')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;description: string?<br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Required. Array of AzureFirewallNetworkRuleProtocols.')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;protocols: ('TCP' &#124; 'UDP' &#124; 'Any' &#124; 'ICMP')[]<br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Optional. List of destination IP addresses.')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;destinationAddresses: string[]?<br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Optional. List of destination FQDNs.')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;destinationFqdns: string[]?<br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Optional. List of destination IP groups for this rule.')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;destinationIpGroups: string[]?<br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Optional. List of destination ports.')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;destinationPorts: string[]?<br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Optional. List of source IP addresses for this rule.')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;sourceAddresses: string[]?<br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Optional. List of source IpGroups for this rule.')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;sourceIpGroups: string[]?<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}[]<br>&nbsp;&nbsp;&nbsp;}<br>}<br></pre> |  | The type for a network rule collection. | 
| <a id="additionalPublicIpConfigurationType">additionalPublicIpConfigurationType</a>  | <pre>{<br>&nbsp;&nbsp;&nbsp;@description('Required. Name of the IP configuration.')<br>&nbsp;&nbsp;&nbsp;name: string<br><br>&nbsp;&nbsp;&nbsp;@description('Optional. Resource ID of an existing public IP address to use.')<br>&nbsp;&nbsp;&nbsp;publicIPAddressResourceId: string?<br>}<br></pre> |  | The type for additional public IP configurations. | 

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
| additionalPublicIpConfigurations | [additionalPublicIpConfigurationType](#additionalPublicIpConfigurationType)[] | <input type="checkbox"> | None | <pre>[]</pre> | Optional. This is to add any additional Public IP configurations on top of the Public IP with subnet IP configuration. |
| publicIPAddressObject | object | <input type="checkbox"> | None | <pre>{}</pre> | Optional. Specifies the properties of the Public IP to create and be used by the Firewall, if no existing public IP was provided. |
| managementIPResourceID | string | <input type="checkbox"> | None | <pre>''</pre> | Optional. The Management Public IP resource ID to associate to the AzureFirewallManagementSubnet. If empty, then the Management Public IP that is created as part of this module will be applied to the AzureFirewallManagementSubnet. |
| managementIPAddressObject | object | <input type="checkbox"> | None | <pre>{}</pre> | Optional. Specifies the properties of the Management Public IP to create and be used by Azure Firewall. If it\'s not provided and managementIPResourceID is empty, a \'-mip\' suffix will be appended to the Firewall\'s name. |
| networkRuleCollections | array | <input type="checkbox"> | None | <pre>[]</pre> | The network rule collections in the Azure Firewall. |
| applicationRuleCollections | array | <input type="checkbox"> | None | <pre>[]</pre> | The application rule collections in the Azure Firewall. |
| natRuleCollections | array | <input type="checkbox"> | None | <pre>[]</pre> | The nat rule collections in the Azure Firewall. |
| applicationRuleCollectionsTyped | [applicationRuleCollectionType](#applicationRuleCollectionType)[]? | <input type="checkbox" checked> | None | <pre></pre> | Optional. Collection of application rule collections used by Azure Firewall (typed version). |
| networkRuleCollectionsTyped | [networkRuleCollectionType](#networkRuleCollectionType)[]? | <input type="checkbox" checked> | None | <pre></pre> | Optional. Collection of network rule collections used by Azure Firewall (typed version). |
| natRuleCollectionsTyped | [natRuleCollectionType](#natRuleCollectionType)[]? | <input type="checkbox" checked> | None | <pre></pre> | Optional. Collection of NAT rule collections used by Azure Firewall (typed version). |
| availabilityZones | array | <input type="checkbox"> | None | <pre>[]</pre> | The availability zones for the Azure Firewall. |
| zones | array | <input type="checkbox"> | None | <pre>[<br>  1<br>  2<br>  3<br>]</pre> | Optional. Zone numbers e.g. 1,2,3. |
| AzureFirewallSkuName | string | <input type="checkbox"> | `'AZFW_Hub'` or `'AZFW_VNet'` | <pre>'AZFW_VNet'</pre> | The name of the Azure Firewall SKU. |
| AzureFirewallSkuTier | string | <input type="checkbox"> | `'Basic'` or `'Premium'` or `'Standard'` | <pre>'Standard'</pre> | Optional. Tier of an Azure Firewall. |
| azureSkuTier | string | <input type="checkbox"> | `'Basic'` or `'Standard'` or `'Premium'` | <pre>AzureFirewallSkuTier</pre> | Optional. Tier of an Azure Firewall (v2 parameter name). |
| threatIntelMode | string | <input type="checkbox"> | `'Alert'` or `'Deny'` or `'Off'` | <pre>'Alert'</pre> | The operation mode for Threat Intelligence. |
| autoscaleConfiguration | object | <input type="checkbox"> | None | <pre>{<br>  maxCapacity: null<br>  minCapacity: null<br>}</pre> | Properties to provide a custom autoscale configuration to this azure firewall. Constraints: Min value for both = 2 |
| hubIPAddresses | [hubIPAddressesType](#hubIPAddressesType)? | <input type="checkbox" checked> | None | <pre></pre> | Conditional. IP addresses associated with AzureFirewall. Required if `virtualHubId` is supplied. |
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

