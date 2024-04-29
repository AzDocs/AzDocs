# rules

Target Scope: resourceGroup

## Synopsis
Create a rule in an existing ruleset.

## Description
Create a rule in an existing ruleset.<br>
<pre><br>
module rulehttptohttps 'br:contosoregistry.azurecr.io/cdn/profiles/rulesets/rules.bicep' = {<br>
  name: format('{0}-{1}', take('${deployment().name}', 59), 'rule')<br>
  params: {<br>
    ruleName: ruleNameHttpToHttps<br>
    matchProcessingBehavior: 'Continue'<br>
    ruleOrder: 0<br>
    ruleSetName: rulesethttptohttps.outputs.ruleSetName<br>
    frontDoorName: frontDoorProfile.outputs.frontDoorName<br>
  }<br>
}<br>
</pre><br>
<p>Creates a rule named ruleNameHttpToHttps in an existing rulesetname in an existing frontdoor profile.</p>

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| ruleName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the rule to create in the existing ruleset.<br>This must be unique within the Front Door ruleset. Rule changes might take up to 15 minutes to propagate through Azure CDN. |
| frontDoorName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the Front Door profile that should be existing as parent for the ruleset. |
| ruleSetName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the existing ruleset to add the rule to. This will serve as parent |
| ruleOrder | int | <input type="checkbox" checked> | Value between 0-* | <pre></pre> | The order in which the rule should be evaluated.<br>Rules are evaluated in ascending order based on this value. A rule with a lesser order will be applied before a rule with a greater order.<br>The first rule should have an order value of 0. Rule with order 0 is a special rule. It does not require any condition and actions listed in it will always be applied.<br>The last rule should have an order value equal to the total number of rules minus one.<br>The order value cannot be changed after the rule is created. If two rules have the same order value, one of them will be evaluated first. |
| matchProcessingBehavior | string | <input type="checkbox"> | None | <pre>'Continue'</pre> | The processing behavior for the rule. If MatchProcessingBehavior is Stop, the rule engine will stop evaluating the request or response after the rule is matched.<br>If MatchProcessingBehavior is Continue, the rule engine will continue evaluating the request or response after the rule is matched. The default value is Continue. |
| ruleActions | array | <input type="checkbox"> | None | <pre>[<br>  {<br>    name: 'UrlRedirect'<br>    parameters: {<br>      redirectType: 'Found'<br>      destinationProtocol: 'Https'<br>      typeName: 'DeliveryRuleUrlRedirectActionParameters'<br>    }<br>  }<br>]</pre> | The actions to perform when the rule is matched. Action cannot be empty. You can override this example with your own actions. |
| ruleConditions | array | <input type="checkbox"> | None | <pre>[<br>  {<br>    name: 'RequestScheme'<br>    parameters: {<br>      operator: 'Equal'<br>      negateCondition: false<br>      matchValues: [<br>        'HTTP'<br>      ]<br>      transforms: []<br>      typeName: 'DeliveryRuleRequestSchemeConditionParameters'<br>    }<br>  }<br>]</pre> | The conditions that must be met for the rule to be executed. You can override this example with your own conditions. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| ruleName | string | The name of the rule that was created. |
| ruleNameId | string | The id of the rule that was created. |

## Links
- [Bicep Microsoft.Cdn profiles rulesets rules](https://learn.microsoft.com/en-us/azure/templates/microsoft.cdn/profiles/rulesets/rules?pivots=deployment-language-bicep)
