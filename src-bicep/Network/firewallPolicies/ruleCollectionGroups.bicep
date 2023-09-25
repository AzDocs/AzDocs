/*
.SYNOPSIS
Azure Firewall Policy Rule Collectionmodule.
.DESCRIPTION
Add an Azure Firewall Policy RuleCollection to an existing Firewall Policy.
.EXAMPLE
<pre>
module networkRuleCollectionGroup 'br:contosoregistry.azurecr.io/firewallpolicies/rulecollectiongroups.bicep' =  {
  name: format('{0}-{1}', take('${deployment().name}', 54), 'rulecoll1')
  params: {
    firewallPolicyName: 'firewallPolicyName'
    ruleCollectionGroupName: 'DefaultNetworkRuleCollectionGroup'
    ruleCollectionGroupPriority: 200
    ruleCollections: networkRuleCollectionGroupInput
  }
  dependsOn: [firewallPolicy, applicationRuleCollectionGroup]
}
</pre>
<p>Creates a Firewall Policy RuleCollectionGroup name 'DefaultNetworkRuleCollectionGroup' in the existing Firewall Policy with the name 'firewallPolicyName' .</p>
.LINK
- [Bicep Microsoft.Network firewallpolicies](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/firewallpolicies/rulecollectiongroups?pivots=deployment-language-bicep)
*/

@description('The name of the already existing Firewall Policy.')
param firewallPolicyName string

@description('''
The name for the rule collection group to upsert.
Example:
'DefaultNetworkRuleCollectionGroup',
'DefaultApplicationRuleCollectionGroup',
'DefaultDnatRuleCollectionGroup'
''')
param ruleCollectionGroupName string

@description('The priority of the rule collection group to upsert.')
param ruleCollectionGroupPriority int

@description('''
The group of Firewall Policy rule collections to upsert. 
If not empty, it needs to hold an array of a ruleCollectionType either \'FirewallPolicyFilterRuleCollection\' or \'FirewallPolicyNatRuleCollection\' that has one or more rules.
Example:
[
  {
    ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
    action: {
      type: 'Allow'
    }
    name: 'azure-global-services-nrc'
    priority: 1250
    rules: [
      {
        ruleType: 'NetworkRule'
        name: 'time-windows'
        ipProtocols: [
          'UDP'
        ]
        destinationAddresses: [
          '13.86.101.172'
        ]
        sourceIpGroups: [
          workloadIpGroup.id
          infraIpGroup.id
        ]
        destinationPorts: [
          '123'
        ]
      }
    ]
  }
]
''')
param ruleCollections array = []

resource firewallPolicy 'Microsoft.Network/firewallPolicies@2023-05-01' existing = {
  name: firewallPolicyName
}

resource ruleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2023-05-01' = {
  parent: firewallPolicy
  name: ruleCollectionGroupName
  properties: {
    priority: ruleCollectionGroupPriority
    ruleCollections: ruleCollections
  }
}

@description('The name of the Firewall Policy Rule Collection Group.')
output ruleCollectionGroupName string = ruleCollectionGroup.name
@description('The id of the Firewall Policy Rule Collection Group.')
output ruleCollectionGroupId string = ruleCollectionGroup.id
