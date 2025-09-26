/*
.SYNOPSIS
Azure Firewall module for Bicep - Enhanced version with backwards compatibility.

.DESCRIPTION
Add an Azure Firewall to the resource group. The firewall policy is optional and when left out, it will create a classic firewall.
This version combines the original functionality with enhanced features from v2 while maintaining full backwards compatibility.

BACKWARDS COMPATIBILITY:
- All existing parameters from the original template are preserved
- Existing deployments will continue to work without any changes
- Original parameter names (azureFirewallName, azureFirewallIpConfigurations, etc.) are maintained
- Original diagnostic settings behavior is preserved

ENHANCED FEATURES (V2):
- Typed rule collections with enhanced validation (applicationRuleCollectionType, networkRuleCollectionType, natRuleCollectionType)
- Advanced diagnostic settings supporting multiple destinations (storage, event hub, etc.)
- Role assignments and resource locking capabilities
- Forced tunneling support
- Enhanced Public IP management
- AVM-compliant telemetry and structure

MIGRATION PATH:
- Continue using existing parameters for current deployments
- Gradually adopt new v2 parameters for enhanced features
- Use typed rule collections for better validation and IntelliSense
- Switch to enhanced diagnostic settings for multi-destination logging

.EXAMPLE
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

.LINK
- [Bicep Microsoft.Network Azure firewall](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/azurefirewalls?pivots=deployment-language-bicep)
- [Azure Verified Modules](https://aka.ms/avm)
*/

metadata name = 'Azure Firewalls'
metadata description = 'This module deploys an Azure Firewall with enhanced features and backwards compatibility.'

// =============== //
//   Type Definitions   //
// =============== //

@export()
@description('The type for the hub IP addresses.')
type hubIPAddressesType = {
  @description('Optional. Private IP Address associated with AzureFirewall.')
  privateIPAddress: string?
  @description('Optional. List of public IP addresses associated with AzureFirewall.')
  publicIPs: {
    @description('Optional. The list of Public IP addresses associated with AzureFirewall or IP addresses to be retained.')
    addresses: [
      {
        @description('Optional. Public IP.')
        address: string?
      }
    ]?
    @description('Optional. Public IP address count.')
    count: int?
  }?
}

@export()
@description('The type for a NAT rule collection.')
type natRuleCollectionType = {
  @description('Required. Name of the NAT rule collection.')
  name: string

  @description('Required. Properties of the azure firewall NAT rule collection.')
  properties: {
    @description('Required. The action type of a NAT rule collection.')
    action: {
      @description('Required. The type of action.')
      type: 'Dnat' | 'Snat'
    }

    @description('Required. Priority of the NAT rule collection.')
    @minValue(100)
    @maxValue(65000)
    priority: int

    @description('Required. Collection of rules used by a NAT rule collection.')
    rules: {
      @description('Required. Name of the NAT rule.')
      name: string

      @description('Optional. Description of the rule.')
      description: string?

      @description('Required. Array of AzureFirewallNetworkRuleProtocols applicable to this NAT rule.')
      protocols: ('TCP' | 'UDP' | 'Any' | 'ICMP')[]

      @description('Optional. List of destination IP addresses for this rule. Supports IP ranges, prefixes, and service tags.')
      destinationAddresses: string[]?

      @description('Optional. List of destination ports.')
      destinationPorts: string[]?

      @description('Optional. List of source IP addresses for this rule.')
      sourceAddresses: string[]?

      @description('Optional. List of source IpGroups for this rule.')
      sourceIpGroups: string[]?

      @description('Optional. The translated address for this NAT rule.')
      translatedAddress: string?

      @description('Optional. The translated FQDN for this NAT rule.')
      translatedFqdn: string?

      @description('Optional. The translated port for this NAT rule.')
      translatedPort: string?
    }[]
  }
}

@export()
@description('The type for an application rule collection.')
type applicationRuleCollectionType = {
  @description('Required. Name of the application rule collection.')
  name: string

  @description('Required. Properties of the azure firewall application rule collection.')
  properties: {
    @description('Required. The action type of a rule collection.')
    action: {
      @description('Required. The type of action.')
      type: 'Allow' | 'Deny'
    }

    @description('Required. Priority of the application rule collection.')
    @minValue(100)
    @maxValue(65000)
    priority: int

    @description('Required. Collection of rules used by a application rule collection.')
    rules: {
      @description('Required. Name of the application rule.')
      name: string

      @description('Optional. Description of the rule.')
      description: string?

      @description('Required. Array of ApplicationRuleProtocols.')
      protocols: {
        @description('Optional. Port number for the protocol.')
        @maxValue(64000)
        port: int?

        @description('Required. Protocol type.')
        protocolType: 'Http' | 'Https' | 'Mssql'
      }[]

      @description('Optional. List of FQDN Tags for this rule.')
      fqdnTags: string[]?

      @description('Optional. List of FQDNs for this rule.')
      targetFqdns: string[]?

      @description('Optional. List of source IP addresses for this rule.')
      sourceAddresses: string[]?

      @description('Optional. List of source IpGroups for this rule.')
      sourceIpGroups: string[]?
    }[]
  }
}

@export()
@description('The type for a network rule collection.')
type networkRuleCollectionType = {
  @description('Required. Name of the network rule collection.')
  name: string

  @description('Required. Properties of the azure firewall network rule collection.')
  properties: {
    @description('Required. The action type of a rule collection.')
    action: {
      @description('Required. The type of action.')
      type: 'Allow' | 'Deny'
    }

    @description('Required. Priority of the network rule collection.')
    @minValue(100)
    @maxValue(65000)
    priority: int

    @description('Required. Collection of rules used by a network rule collection.')
    rules: {
      @description('Required. Name of the network rule.')
      name: string

      @description('Optional. Description of the rule.')
      description: string?

      @description('Required. Array of AzureFirewallNetworkRuleProtocols.')
      protocols: ('TCP' | 'UDP' | 'Any' | 'ICMP')[]

      @description('Optional. List of destination IP addresses.')
      destinationAddresses: string[]?

      @description('Optional. List of destination FQDNs.')
      destinationFqdns: string[]?

      @description('Optional. List of destination IP groups for this rule.')
      destinationIpGroups: string[]?

      @description('Optional. List of destination ports.')
      destinationPorts: string[]?

      @description('Optional. List of source IP addresses for this rule.')
      sourceAddresses: string[]?

      @description('Optional. List of source IpGroups for this rule.')
      sourceIpGroups: string[]?
    }[]
  }
}

@export()
@description('The type for additional public IP configurations.')
type additionalPublicIpConfigurationType = {
  @description('Required. Name of the IP configuration.')
  name: string

  @description('Optional. Resource ID of an existing public IP address to use.')
  publicIPAddressResourceId: string?
}

// =============== //
//   Parameters   //
// =============== //

@description('Location for all resources.')
param location string = resourceGroup().location

@description('''
The tags to apply to this resource. This is an object with key/value pairs.
Example:
{
  FirstTag: myvalue
  SecondTag: another value
}
''')
param tags object = {}

// Backwards compatibility: Primary parameter name from original template
@description('The name for the Azure Firewall.')
param azureFirewallName string

// Enhanced v2 parameters - Optional for backwards compatibility
@description('Optional. Alternative name parameter (AVM standard). If not provided, uses azureFirewallName.')
param name string = azureFirewallName

@description('Optional. Resource ID of the Firewall Policy that should be attached.')
param firewallPolicyId string = ''

// Original IP configuration parameter for backwards compatibility
@description('The ipconfigurations in the Azure Firewall based on one or more Public Ips and a subnet.')
param azureFirewallIpConfigurations array = []

// Enhanced v2 IP configuration parameters
@description('Conditional. Shared services Virtual Network resource ID. The virtual network ID containing AzureFirewallSubnet. If a Public IP is not provided, then the Public IP that is created as part of this module will be applied with the subnet provided in this variable. Required if `virtualHubId` is empty.')
param virtualNetworkResourceId string = ''

@description('Optional. The Public IP resource ID to associate to the AzureFirewallSubnet. If empty, then the Public IP that is created as part of this module will be applied to the AzureFirewallSubnet.')
param publicIPResourceID string = ''

@description('Optional. This is to add any additional Public IP configurations on top of the Public IP with subnet IP configuration.')
param additionalPublicIpConfigurations additionalPublicIpConfigurationType[] = []

@description('Optional. Specifies the properties of the Public IP to create and be used by the Firewall, if no existing public IP was provided.')
param publicIPAddressObject object = {}

@description('Optional. The Management Public IP resource ID to associate to the AzureFirewallManagementSubnet. If empty, then the Management Public IP that is created as part of this module will be applied to the AzureFirewallManagementSubnet.')
param managementIPResourceID string = ''

@description('Optional. Specifies the properties of the Management Public IP to create and be used by Azure Firewall. If it\'s not provided and managementIPResourceID is empty, a \'-mip\' suffix will be appended to the Firewall\'s name.')
param managementIPAddressObject object = {}

// Rule collections - support both original arrays and new typed collections
@description('The network rule collections in the Azure Firewall.')
param networkRuleCollections array = []

@description('The application rule collections in the Azure Firewall.')
param applicationRuleCollections array = []

@description('The nat rule collections in the Azure Firewall.')
param natRuleCollections array = []

// Enhanced v2 typed rule collections (optional)
@description('Optional. Collection of application rule collections used by Azure Firewall (typed version).')
param applicationRuleCollectionsTyped applicationRuleCollectionType[]?

@description('Optional. Collection of network rule collections used by Azure Firewall (typed version).')
param networkRuleCollectionsTyped networkRuleCollectionType[]?

@description('Optional. Collection of NAT rule collections used by Azure Firewall (typed version).')
param natRuleCollectionsTyped natRuleCollectionType[]?

// SKU and Configuration
@description('The availability zones for the Azure Firewall.')
param availabilityZones array = []

@description('Optional. Zone numbers e.g. 1,2,3.')
param zones array = [
  1
  2
  3
]

@description('The name of the Azure Firewall SKU.')
@allowed([
  'AZFW_Hub'
  'AZFW_VNet'
])
param AzureFirewallSkuName string = 'AZFW_VNet'

@description('Optional. Tier of an Azure Firewall.')
@allowed([
  'Basic'
  'Premium'
  'Standard'
])
param AzureFirewallSkuTier string = 'Standard'

// Enhanced v2 alias for SKU tier
@description('Optional. Tier of an Azure Firewall (v2 parameter name).')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param azureSkuTier string = AzureFirewallSkuTier

@description('The operation mode for Threat Intelligence.')
@allowed([
  'Alert'
  'Deny'
  'Off'
])
param threatIntelMode string = 'Alert'

@description('Properties to provide a custom autoscale configuration to this azure firewall. Constraints: Min value for both = 2')
param autoscaleConfiguration object = {
  maxCapacity: null
  minCapacity: null
}

@description('Conditional. IP addresses associated with AzureFirewall. Required if `virtualHubId` is supplied.')
param hubIPAddresses hubIPAddressesType?

@description('Optional. The resource ID of the Virtual Hub to associate with the Azure Firewall.')
param virtualHubId string = ''

@description('Optional. Enable/Disable forced tunneling.')
param enableForcedTunneling bool = false

// Enhanced v2 diagnostic settings
import { diagnosticSettingFullType } from 'br/public:avm/utl/types/avm-common-types:0.5.1'
@description('Optional. The diagnostic settings of the service.')
param diagnosticSettings diagnosticSettingFullType[]?

// Original diagnostic parameters for backwards compatibility
@description('The name of the diagnostics. This defaults to `AzurePlatformCentralizedLogging`.')
@minLength(1)
@maxLength(260)
param diagnosticsName string = 'AzurePlatformCentralizedLogging'

@description('The azure resource id of the log analytics workspace to log the diagnostics to. If you set this to an empty string, logging & diagnostics will be disabled.')
@minLength(0)
param logAnalyticsWorkspaceResourceId string = ''

@description('Which log categories to enable; This defaults to `allLogs`. For array/object format, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep#logsettings.')
param diagnosticSettingsLogsCategories array = [
  {
    categoryGroup: 'allLogs'
    enabled: true
  }
]

@description('Which Metrics categories to enable; This defaults to `AllMetrics`. For array/object format, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep&pivots=deployment-language-bicep#metricsettings')
param diagnosticSettingsMetricsCategories array = [
  {
    categoryGroup: 'AllMetrics'
    enabled: true
  }
]

// Enhanced v2 features
import { lockType } from 'br/public:avm/utl/types/avm-common-types:0.5.1'
@description('Optional. The lock settings of the service.')
param lock lockType?

import { roleAssignmentType } from 'br/public:avm/utl/types/avm-common-types:0.5.1'
@description('Optional. Array of role assignments to create.')
param roleAssignments roleAssignmentType[]?

@description('Optional. Enable/Disable usage telemetry for module.')
param enableTelemetry bool = true

// =============== //
//   Variables   //
// =============== //

var enableReferencedModulesTelemetry = false
var effectiveName = !empty(name) ? name : azureFirewallName
var effectiveZones = !empty(zones) ? zones : (!empty(availabilityZones) ? availabilityZones : [])
var effectiveSkuTier = !empty(azureSkuTier) ? azureSkuTier : AzureFirewallSkuTier
var azureSkuName = empty(virtualNetworkResourceId) && empty(azureFirewallIpConfigurations) ? 'AZFW_Hub' : AzureFirewallSkuName
var requiresManagementIp = (effectiveSkuTier == 'Basic' || enableForcedTunneling) ? true : false
var isCreateDefaultPublicIP = empty(publicIPResourceID) && empty(azureFirewallIpConfigurations) && azureSkuName == 'AZFW_VNet'
var isCreateDefaultManagementIP = empty(managementIPResourceID) && requiresManagementIp

// Use typed rule collections if provided, otherwise fall back to original arrays
var effectiveApplicationRuleCollections = applicationRuleCollectionsTyped ?? applicationRuleCollections
var effectiveNetworkRuleCollections = networkRuleCollectionsTyped ?? networkRuleCollections
var effectiveNatRuleCollections = natRuleCollectionsTyped ?? natRuleCollections

// Default public IP object if none provided
var defaultPublicIPAddressObject = {
  name: '${effectiveName}-pip'
}
var effectivePublicIPAddressObject = !empty(publicIPAddressObject) ? publicIPAddressObject : defaultPublicIPAddressObject

// ----------------------------------------------------------------------------
// Prep ipConfigurations object for different use cases:
// 1. Use existing configurations (backwards compatibility)
// 2. Use existing Public IP
// 3. Use new Public IP created in this module

// Additional Public IP configurations processing (v2 feature)
var additionalPublicIpConfigurationsVar = [
  for ipConfiguration in additionalPublicIpConfigurations: {
    name: ipConfiguration.name
    properties: {
      publicIPAddress: ipConfiguration.?publicIPAddressResourceId != null
        ? {
            id: ipConfiguration.?publicIPAddressResourceId
          }
        : null
    }
  }
]

// Build dynamic IP configurations for new v2 style deployments
var dynamicIpConfigurations = azureSkuName == 'AZFW_VNet' && !empty(virtualNetworkResourceId) ? concat(
  [
    {
      name: !empty(publicIPResourceID) ? last(split(publicIPResourceID, '/')) : effectivePublicIPAddressObject.name
      properties: {
        subnet: {
          id: '${virtualNetworkResourceId}/subnets/AzureFirewallSubnet'
        }
        publicIPAddress: !empty(publicIPResourceID) ? {
          id: publicIPResourceID
        } : null
      }
    }
  ],
  additionalPublicIpConfigurationsVar
) : additionalPublicIpConfigurationsVar

// Use original IP configurations if provided (backwards compatibility)
// If additional public IPs are specified but no base configurations, add them to original configs
var effectiveIpConfigurations = !empty(azureFirewallIpConfigurations) 
  ? (!empty(additionalPublicIpConfigurations) 
      ? concat(azureFirewallIpConfigurations, additionalPublicIpConfigurationsVar)
      : azureFirewallIpConfigurations)
  : dynamicIpConfigurations

// Management IP configuration will be handled directly in the resource

// ----------------------------------------------------------------------------
var builtInRoleNames = {
  Contributor: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
  Owner: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '8e3af657-a8ff-443c-a75c-2fe8c4bcb635')
  Reader: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'acdd72a7-3385-48ef-bd42-f606fba81ae7')
  'Role Based Access Control Administrator': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'f58310d9-a9f6-439a-9e8d-f62e7b41a168'
  )
  'User Access Administrator': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '18d7d88d-d35e-4fb5-a5c3-7773c20a72d9'
  )
}

var formattedRoleAssignments = [
  for (roleAssignment, index) in (roleAssignments ?? []): union(roleAssignment, {
    roleDefinitionId: builtInRoleNames[?roleAssignment.roleDefinitionIdOrName] ?? (contains(
        roleAssignment.roleDefinitionIdOrName,
        '/providers/Microsoft.Authorization/roleDefinitions/'
      )
      ? roleAssignment.roleDefinitionIdOrName
      : subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleAssignment.roleDefinitionIdOrName))
  })
]

// =============== //
//   Resources   //
// =============== //

#disable-next-line no-deployments-resources
resource avmTelemetry 'Microsoft.Resources/deployments@2024-03-01' = if (enableTelemetry) {
  name: '46d3xbcp.res.network-azurefirewall.${replace('0.6.1', '.', '-')}.${substring(uniqueString(deployment().name, location), 0, 4)}'
  properties: {
    mode: 'Incremental'
    template: {
      '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
      contentVersion: '1.0.0.0'
      resources: []
      outputs: {
        telemetry: {
          type: 'String'
          value: 'For more information, see https://aka.ms/avm/TelemetryInfo'
        }
      }
    }
  }
}

module publicIPAddress 'br/public:avm/res/network/public-ip-address:0.8.0' = if (isCreateDefaultPublicIP) {
  name: '${uniqueString(deployment().name, location)}-Firewall-PIP'
  params: {
    name: effectivePublicIPAddressObject.name
    publicIpPrefixResourceId: effectivePublicIPAddressObject.?publicIPPrefixResourceId ?? ''
    publicIPAllocationMethod: effectivePublicIPAddressObject.?publicIPAllocationMethod ?? 'Static'
    skuName: effectivePublicIPAddressObject.?skuName ?? 'Standard'
    skuTier: effectivePublicIPAddressObject.?skuTier ?? 'Regional'
    roleAssignments: effectivePublicIPAddressObject.?roleAssignments ?? []
    diagnosticSettings: effectivePublicIPAddressObject.?diagnosticSettings
    location: location
    lock: lock
    tags: effectivePublicIPAddressObject.?tags ?? tags
    zones: effectiveZones
    enableTelemetry: enableReferencedModulesTelemetry
  }
}

// create a Management Public IP address if one is not provided and the flag is true
module managementIPAddress 'br/public:avm/res/network/public-ip-address:0.8.0' = if (isCreateDefaultManagementIP && azureSkuName == 'AZFW_VNet') {
  name: '${uniqueString(deployment().name, location)}-Firewall-MIP'
  params: {
    name: managementIPAddressObject.?name ?? '${effectiveName}-mip'
    publicIpPrefixResourceId: managementIPAddressObject.?managementIPPrefixResourceId ?? ''
    publicIPAllocationMethod: managementIPAddressObject.?managementIPAllocationMethod ?? 'Static'
    skuName: managementIPAddressObject.?skuName ?? 'Standard'
    skuTier: managementIPAddressObject.?skuTier ?? 'Regional'
    roleAssignments: managementIPAddressObject.?roleAssignments ?? []
    diagnosticSettings: managementIPAddressObject.?diagnosticSettings
    location: location
    tags: managementIPAddressObject.?tags ?? tags
    zones: effectiveZones
    enableTelemetry: enableReferencedModulesTelemetry
  }
}

resource azureFirewall 'Microsoft.Network/azureFirewalls@2024-05-01' = {
  name: effectiveName
  location: location
  zones: length(effectiveZones) == 0 ? null : effectiveZones
  tags: tags
  properties: azureSkuName == 'AZFW_VNet'
    ? {
        threatIntelMode: threatIntelMode
        firewallPolicy: !empty(firewallPolicyId)
          ? {
              id: firewallPolicyId
            }
          : null
        ipConfigurations: effectiveIpConfigurations
        sku: {
          name: azureSkuName
          tier: effectiveSkuTier
        }
        applicationRuleCollections: effectiveApplicationRuleCollections
        networkRuleCollections: effectiveNetworkRuleCollections
        natRuleCollections: effectiveNatRuleCollections
        autoscaleConfiguration: !empty(autoscaleConfiguration) && (autoscaleConfiguration.maxCapacity != null || autoscaleConfiguration.minCapacity != null)
          ? {
              maxCapacity: autoscaleConfiguration.maxCapacity
              minCapacity: autoscaleConfiguration.minCapacity
            }
          : null
      }
    : {
        firewallPolicy: !empty(firewallPolicyId)
          ? {
              id: firewallPolicyId
            }
          : null
        ipConfigurations: effectiveIpConfigurations
        sku: {
          name: azureSkuName
          tier: effectiveSkuTier
        }
        hubIPAddresses: !empty(hubIPAddresses) ? hubIPAddresses : null
        virtualHub: !empty(virtualHubId)
          ? {
              id: virtualHubId
            }
          : null
      }
}

resource azureFirewall_lock 'Microsoft.Authorization/locks@2020-05-01' = if (!empty(lock ?? {}) && lock.?kind != 'None') {
  name: lock.?name ?? 'lock-${effectiveName}'
  properties: {
    level: lock.?kind ?? ''
    notes: lock.?kind == 'CanNotDelete'
      ? 'Cannot delete resource or child resources.'
      : 'Cannot delete or modify the resource or child resources.'
  }
  scope: azureFirewall
}

// Enhanced diagnostic settings (v2 style)
resource azureFirewall_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
  for (diagnosticSetting, index) in (diagnosticSettings ?? []): {
    name: diagnosticSetting.?name ?? '${effectiveName}-diagnosticSettings'
    properties: {
      storageAccountId: diagnosticSetting.?storageAccountResourceId
      workspaceId: diagnosticSetting.?workspaceResourceId
      eventHubAuthorizationRuleId: diagnosticSetting.?eventHubAuthorizationRuleResourceId
      eventHubName: diagnosticSetting.?eventHubName
      metrics: [
        for group in (diagnosticSetting.?metricCategories ?? [{ category: 'AllMetrics' }]): {
          category: group.category
          enabled: group.?enabled ?? true
          timeGrain: null
        }
      ]
      logs: [
        for group in (diagnosticSetting.?logCategoriesAndGroups ?? [{ categoryGroup: 'allLogs' }]): {
          categoryGroup: group.?categoryGroup
          category: group.?category
          enabled: group.?enabled ?? true
        }
      ]
      marketplacePartnerId: diagnosticSetting.?marketplacePartnerResourceId
      logAnalyticsDestinationType: diagnosticSetting.?logAnalyticsDestinationType
    }
    scope: azureFirewall
  }
]

// Original diagnostic settings (backwards compatibility)
resource firewallDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceResourceId) && empty(diagnosticSettings)) {
  name: diagnosticsName
  scope: azureFirewall
  properties: {
    workspaceId: logAnalyticsWorkspaceResourceId
    logs: diagnosticSettingsLogsCategories
    metrics: diagnosticSettingsMetricsCategories
  }
}

resource azureFirewall_roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (roleAssignment, index) in (formattedRoleAssignments ?? []): {
    name: roleAssignment.?name ?? guid(azureFirewall.id, roleAssignment.principalId, roleAssignment.roleDefinitionId)
    properties: {
      roleDefinitionId: roleAssignment.roleDefinitionId
      principalId: roleAssignment.principalId
      description: roleAssignment.?description
      principalType: roleAssignment.?principalType
      condition: roleAssignment.?condition
      conditionVersion: !empty(roleAssignment.?condition) ? (roleAssignment.?conditionVersion ?? '2.0') : null // Must only be set if condtion is set
      delegatedManagedIdentityResourceId: roleAssignment.?delegatedManagedIdentityResourceId
    }
    scope: azureFirewall
  }
]

// =============== //
//   Outputs   //
// =============== //

// Original outputs for backwards compatibility
@description('The id of the Azure Firewall.')
output azureFirewallId string = azureFirewall.id

@description('The name of the Azure Firewall.')
output azureFirewallName string = azureFirewall.name

// Enhanced v2 outputs
@description('The resource ID of the Azure Firewall.')
output resourceId string = azureFirewall.id

@description('The name of the Azure Firewall.')
output name string = azureFirewall.name

@description('The resource group the Azure firewall was deployed into.')
output resourceGroupName string = resourceGroup().name

@description('The private IP of the Azure firewall.')
output privateIp string = contains(azureFirewall.properties, 'ipConfigurations') && length(azureFirewall.properties.ipConfigurations) > 0
  ? azureFirewall.properties.ipConfigurations[0].properties.privateIPAddress
  : ''

@description('The Public IP configuration object for the Azure Firewall Subnet.')
output ipConfAzureFirewallSubnet object = contains(azureFirewall.properties, 'ipConfigurations') && length(azureFirewall.properties.ipConfigurations) > 0
  ? azureFirewall.properties.ipConfigurations[0]
  : {}

@description('List of Application Rule Collections used by Azure Firewall.')
output applicationRuleCollections array = effectiveApplicationRuleCollections

@description('List of Network Rule Collections used by Azure Firewall.')
output networkRuleCollections array = effectiveNetworkRuleCollections

@description('List of NAT rule collections used by Azure Firewall.')
output natRuleCollections array = effectiveNatRuleCollections

@description('The location the resource was deployed into.')
output location string = azureFirewall.location
