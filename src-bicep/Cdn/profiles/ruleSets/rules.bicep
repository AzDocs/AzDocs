/*
.SYNOPSIS
Create a rule in an existing ruleset.
.DESCRIPTION
Create a rule in an existing ruleset.
<pre>
module rulehttptohttps 'br:contosoregistry.azurecr.io/cdn/profiles/rulesets/rules.bicep' = {
  name: format('{0}-{1}', take('${deployment().name}', 59), 'rule')
  params: {
    ruleName: ruleNameHttpToHttps
    matchProcessingBehavior: 'Continue'
    ruleOrder: 0
    ruleSetName: rulesethttptohttps.outputs.ruleSetName
    frontDoorName: frontDoorProfile.outputs.frontDoorName
  }
}
</pre>
<p>Creates a rule named ruleNameHttpToHttps in an existing rulesetname in an existing frontdoor profile.</p>
.LINKS
- [Bicep Microsoft.Cdn profiles rulesets rules](https://learn.microsoft.com/en-us/azure/templates/microsoft.cdn/profiles/rulesets/rules?pivots=deployment-language-bicep)
*/
// ===================================== Parameters =====================================
@description('''
The name of the rule to create in the existing ruleset.
This must be unique within the Front Door ruleset. Rule changes might take up to 15 minutes to propagate through Azure CDN.
''')
param ruleName string

@description('The name of the Front Door profile that should be existing as parent for the ruleset.')
param frontDoorName string

@description('The name of the existing ruleset to add the rule to. This will serve as parent')
param ruleSetName string

@description('''
The order in which the rule should be evaluated.
Rules are evaluated in ascending order based on this value. A rule with a lesser order will be applied before a rule with a greater order.
The first rule should have an order value of 0. Rule with order 0 is a special rule. It does not require any condition and actions listed in it will always be applied.
The last rule should have an order value equal to the total number of rules minus one.
The order value cannot be changed after the rule is created. If two rules have the same order value, one of them will be evaluated first.
''')
@minValue(0)
param ruleOrder int

@description('''
The processing behavior for the rule. If MatchProcessingBehavior is Stop, the rule engine will stop evaluating the request or response after the rule is matched.
If MatchProcessingBehavior is Continue, the rule engine will continue evaluating the request or response after the rule is matched. The default value is Continue.
''')
param matchProcessingBehavior string = 'Continue'

@description('The actions to perform when the rule is matched. Action cannot be empty. You can override this example with your own actions.')
param ruleActions array = [
  {
    name: 'UrlRedirect'
    parameters: {
      redirectType: 'Found'
      destinationProtocol: 'Https'
      typeName: 'DeliveryRuleUrlRedirectActionParameters'
    }
  }
]

@description('The conditions that must be met for the rule to be executed. You can override this example with your own conditions.')
param ruleConditions array = [
  {
    name: 'RequestScheme'
    parameters: {
      operator: 'Equal'
      negateCondition: false
      matchValues: [
        'HTTP'
      ]
      transforms: []
      typeName: 'DeliveryRuleRequestSchemeConditionParameters'
    }
  }
]

// ===================================== Resources =====================================
@description('The existing FrontDoor Cdn profile to use.')
resource CDNProfile 'Microsoft.Cdn/profiles@2022-11-01-preview' existing = {
  name: frontDoorName
}

@description('The existing ruleset to use.')
resource ruleSet 'Microsoft.Cdn/profiles/ruleSets@2022-11-01-preview' existing = {
  parent: CDNProfile
  name: ruleSetName
}

@description('The rule to create in the existing ruleset.')
resource rule 'Microsoft.Cdn/profiles/ruleSets/rules@2022-11-01-preview' = {
  parent: ruleSet
  name: ruleName
  properties: {
    actions: ruleActions
    conditions: ruleConditions
    matchProcessingBehavior: matchProcessingBehavior
    order: ruleOrder
  }
}

@description('The name of the rule that was created.')
output ruleName string = rule.name
@description('The id of the rule that was created.')
output ruleNameId string = rule.id
