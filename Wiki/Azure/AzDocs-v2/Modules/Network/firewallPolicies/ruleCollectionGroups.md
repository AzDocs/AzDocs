# ruleCollectionGroups

Target Scope: resourceGroup

## Synopsis
Azure Firewall Policy Rule Collectionmodule.

## Description
Add an Azure Firewall Policy RuleCollection to an existing Firewall Policy.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| firewallPolicyName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the already existing Firewall Policy. |
| ruleCollectionGroupName | string | <input type="checkbox" checked> | None | <pre></pre> | The name for the rule collection group to upsert.<br>Example:<br>'DefaultNetworkRuleCollectionGroup',<br>'DefaultApplicationRuleCollectionGroup',<br>'DefaultDnatRuleCollectionGroup' |
| ruleCollectionGroupPriority | int | <input type="checkbox" checked> | None | <pre></pre> | The priority of the rule collection group to upsert. |
| ruleCollections | array | <input type="checkbox"> | None | <pre>[]</pre> | The group of Firewall Policy rule collections to upsert. <br>If not empty, it needs to hold an array of a ruleCollectionType either \'FirewallPolicyFilterRuleCollection\' or \'FirewallPolicyNatRuleCollection\' that has one or more rules.<br>Example:<br>[<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ruleCollectionType: 'FirewallPolicyFilterRuleCollection'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;action: {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;type: 'Allow'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;name: 'azure-global-services-nrc'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;priority: 1250<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;rules: [<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ruleType: 'NetworkRule'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;name: 'time-windows'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ipProtocols: [<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'UDP'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;]<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;destinationAddresses: [<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'13.86.101.172'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;]<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;sourceIpGroups: [<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;workloadIpGroup.id<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;infraIpGroup.id<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;]<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;destinationPorts: [<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'123'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;]<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;]<br>&nbsp;&nbsp;&nbsp;}<br>] |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| ruleCollectionGroupName | string | The name of the Firewall Policy Rule Collection Group. |
| ruleCollectionGroupId | string | The id of the Firewall Policy Rule Collection Group. |

## Examples
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
