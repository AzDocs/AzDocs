# azureFirewalls_v2

Target Scope: resourceGroup

## User Defined Types
| Name | Type | Discriminator | Description
| -- |  -- | -- | -- |
| <a id="natRuleCollectionType">natRuleCollectionType</a>  | <pre>{</pre> |  | The type for a NAT rule collection. | 
| <a id="applicationRuleCollectionType">applicationRuleCollectionType</a>  | <pre>{</pre> |  | The type for an application rule collection. | 
| <a id="networkRuleCollectionType">networkRuleCollectionType</a>  | <pre>{</pre> |  | The type for a network rule collection. | 
| <a id="hubIPAddressesType">hubIPAddressesType</a>  | <pre>{</pre> |  | The type for the hub IP addresses. | 

## Synopsis
  This module deploys an Azure Firewall.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| name | string | <input type="checkbox" checked> | None | <pre></pre> | Required. Name of the Azure Firewall. |
| azureSkuTier | string | <input type="checkbox"> | `'Basic'` or `'Standard'` or `'Premium'` | <pre>'Standard'</pre> | Optional. Tier of an Azure Firewall. |
| virtualNetworkResourceId | string | <input type="checkbox"> | None | <pre>''</pre> | Conditional. Shared services Virtual Network resource ID. The virtual network ID containing AzureFirewallSubnet. If a Public IP is not provided, then the Public IP that is created as part of this module will be applied with the subnet provided in this variable. Required if `virtualHubId` is empty. |
| publicIPResourceID | string | <input type="checkbox"> | None | <pre>''</pre> | Optional. The Public IP resource ID to associate to the AzureFirewallSubnet. If empty, then the Public IP that is created as part of this module will be applied to the AzureFirewallSubnet. |
| additionalPublicIpConfigurations | array | <input type="checkbox"> | None | <pre>[]</pre> | Optional. This is to add any additional Public IP configurations on top of the Public IP with subnet IP configuration. |
| publicIPAddressObject | object | <input type="checkbox"> | None | <pre>{<br>  name: '&#36;{name}-pip'<br>}</pre> | Optional. Specifies the properties of the Public IP to create and be used by the Firewall, if no existing public IP was provided. |
| managementIPResourceID | string | <input type="checkbox"> | None | <pre>''</pre> | Optional. The Management Public IP resource ID to associate to the AzureFirewallManagementSubnet. If empty, then the Management Public IP that is created as part of this module will be applied to the AzureFirewallManagementSubnet. |
| managementIPAddressObject | object | <input type="checkbox"> | None | <pre>{}</pre> | Optional. Specifies the properties of the Management Public IP to create and be used by Azure Firewall. If it\'s not provided and managementIPResourceID is empty, a \'-mip\' suffix will be appended to the Firewall\'s name. |
| applicationRuleCollections | applicationRuleCollectionType[]? | <input type="checkbox" checked> | None | <pre></pre> | Optional. Collection of application rule collections used by Azure Firewall. |
| networkRuleCollections | networkRuleCollectionType[]? | <input type="checkbox" checked> | None | <pre></pre> | Optional. Collection of network rule collections used by Azure Firewall. |
| natRuleCollections | natRuleCollectionType[]? | <input type="checkbox" checked> | None | <pre></pre> | Optional. Collection of NAT rule collections used by Azure Firewall. |
| firewallPolicyId | string | <input type="checkbox"> | None | <pre>''</pre> | Optional. Resource ID of the Firewall Policy that should be attached. |
| hubIPAddresses | hubIPAddressesType? | <input type="checkbox" checked> | None | <pre></pre> | Conditional. IP addresses associated with AzureFirewall. Required if `virtualHubId` is supplied. |
| virtualHubId | string | <input type="checkbox"> | None | <pre>''</pre> | Conditional. The virtualHub resource ID to which the firewall belongs. Required if `virtualNetworkId` is empty. |
| threatIntelMode | string | <input type="checkbox"> | `'Alert'` or `'Deny'` or `'Off'` | <pre>'Deny'</pre> | Optional. The operation mode for Threat Intel. |
| zones | array | <input type="checkbox"> | None | <pre>[<br>  1<br>  2<br>  3<br>]</pre> | Optional. Zone numbers e.g. 1,2,3. |
| enableForcedTunneling | bool | <input type="checkbox"> | None | <pre>false</pre> | Optional. Enable/Disable forced tunneling. |
| diagnosticSettings | diagnosticSettingFullType[]? | <input type="checkbox" checked> | None | <pre></pre> | Optional. The diagnostic settings of the service. |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Optional. Location for all resources. |
| lock | lockType? | <input type="checkbox" checked> | None | <pre></pre> | Optional. The lock settings of the service. |
| roleAssignments | roleAssignmentType[]? | <input type="checkbox" checked> | None | <pre></pre> | Optional. Array of role assignments to create. |
| tags | object? | <input type="checkbox" checked> | None | <pre></pre> | Optional. Tags of the Azure Firewall resource. |
| enableTelemetry | bool | <input type="checkbox"> | None | <pre>true</pre> | Optional. Enable/Disable usage telemetry for module. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| resourceId | string | The resource ID of the Azure Firewall. |
| name | string | The name of the Azure Firewall. |
| resourceGroupName | string | The resource group the Azure firewall was deployed into. |
| privateIp | string | The private IP of the Azure firewall. |
| ipConfAzureFirewallSubnet | object | The Public IP configuration object for the Azure Firewall Subnet. |
| applicationRuleCollections | array | List of Application Rule Collections used by Azure Firewall. |
| networkRuleCollections | array | List of Network Rule Collections used by Azure Firewall. |
| natRuleCollections | array | List of NAT rule collections used by Azure Firewall. |
| location | string | The location the resource was deployed into. |
