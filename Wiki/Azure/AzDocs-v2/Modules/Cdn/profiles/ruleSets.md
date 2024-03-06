# ruleSets

Target Scope: resourceGroup

## Synopsis
Create a ruleset.

## Description
Create a ruleset.<br>
<pre><br>
module ruleSet 'br:contosoregistry.azurecr.io/cdn/profiles/rulesets.bicep' = {<br>
  name: format('{0}-{1}', take('${deployment().name}', 56), 'ruleset')<br>
  params: {<br>
    frontDoorName: frontDoorProfile.outputs.frontDoorName<br>
    ruleSetName: 'ruleSetNameHttpToHttps'<br>
  }<br>
}<br>
</pre><br>
<p>Creates ruleset with the name ruleSetNameHttpToHttps in an existing frontdoor profile.</p>

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| ruleSetName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the ruleset to create. |
| frontDoorName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the existing Front Door profile. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| ruleSetName | string | The name of the ruleset created. |
| ruleSetId | string | The id of the ruleset created. |

## Links
- [Bicep Microsoft.Cdn profiles rulesets rules](https://learn.microsoft.com/en-us/azure/templates/microsoft.cdn/profiles/rulesets?pivots=deployment-language-bicep)
