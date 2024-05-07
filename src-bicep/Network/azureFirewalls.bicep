/*
.SYNOPSIS
Azure Firewall module for Bicep.
.DESCRIPTION
Add an Azure Firewall to the resource group. The firewall policy is optional and when left out, it will create a classic firewall.
.EXAMPLE
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
.LINK
- [Bicep Microsoft.Network Azure firewall](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/azurefirewalls?pivots=deployment-language-bicep)
*/

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

@description('The name for the Azure Firewall.')
param azureFirewallName string

@description('The name of the existing firewall policy.')
param firewallPolicyName string = ''

@description('The ipconfigurations in the Azure Firewall based on one or more Public Ips and a subnet.')
param azureFirewallIpConfigurations array = []

@description('The network rule collections in the Azure Firewall.')
param networkRuleCollections array = []

@description('The application rule collections in the Azure Firewall.')
param applicationRuleCollections array = []

@description('The nat rule collections in the Azure Firewall.')
param natRuleCollections array = []

@description('The availability zones for the Azure Firewall.')
param availabilityZones array = []

@description('The name of the Azure Firewall SKU.')
@allowed([
  'AZFW_Hub'
  'AZFW_VNet'
])
param AzureFirewallSkuName string = 'AZFW_VNet'

@description('The tier of the Azure Firewall.')
@allowed([
  'Basic'
  'Premium'
  'Standard'
])
param AzureFirewallSkuTier string = 'Standard'

@description('The operation mode for Threat Intelligence.')
@allowed([
  'Alert'
  'Deny'
  'Off'
])
param threatIntelMode string = 'Alert'

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

@description('The resourcegroup name where the Azure Firewall Policy resource can be found. By default it can be found in the same resource group as the Azure Firewall.')
param firewallPolicyResourceGroupName string = resourceGroup().name


resource firewallPolicy 'Microsoft.Network/firewallPolicies@2023-05-01' existing = {
  name: firewallPolicyName
  scope: resourceGroup(firewallPolicyResourceGroupName)
}

resource azureFirewall 'Microsoft.Network/azureFirewalls@2023-05-01' = {
  name: azureFirewallName
  location: location
  tags: tags
  properties: {
    sku: {
      name: AzureFirewallSkuName
      tier: AzureFirewallSkuTier
    }
    threatIntelMode: threatIntelMode
    additionalProperties: {}
    firewallPolicy: empty(firewallPolicyName) ? null : {
      id: firewallPolicy.id
    }
    ipConfigurations: azureFirewallIpConfigurations
    networkRuleCollections: networkRuleCollections
    applicationRuleCollections: applicationRuleCollections
    natRuleCollections: natRuleCollections
  }
  zones: !empty(availabilityZones) ? availabilityZones : null
}

@description('Upsert the diagnostics for this keyvault.')
resource keyvaultDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceResourceId)) {
  name: diagnosticsName
  scope: azureFirewall
  properties: {
    workspaceId: logAnalyticsWorkspaceResourceId
    logs: diagnosticSettingsLogsCategories
    metrics: diagnosticSettingsMetricsCategories
  }
}

@description('The id of the Azure Firewall.')
output azureFirewallId string = azureFirewall.id
@description('The name of the Azure Firewall.')
output azureFirewallName string = azureFirewall.name
