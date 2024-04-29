/*
.SYNOPSIS
Create a ruleset.
.DESCRIPTION
Create a ruleset.
<pre>
module ruleSet 'br:contosoregistry.azurecr.io/cdn/profiles/rulesets.bicep' = {
  name: format('{0}-{1}', take('${deployment().name}', 56), 'ruleset')
  params: {
    frontDoorName: frontDoorProfile.outputs.frontDoorName
    ruleSetName: 'ruleSetNameHttpToHttps'
  }
}
</pre>
<p>Creates ruleset with the name ruleSetNameHttpToHttps in an existing frontdoor profile.</p>
.LINKS
- [Bicep Microsoft.Cdn profiles rulesets rules](https://learn.microsoft.com/en-us/azure/templates/microsoft.cdn/profiles/rulesets?pivots=deployment-language-bicep)
*/
// ===================================== Parameters =====================================
@description('The name of the ruleset to create.')
param ruleSetName string

@description('The name of the existing Front Door profile.')
param frontDoorName string


// ===================================== Resources =====================================
@description('The existing FrontDoor Cdn profile to use.')
resource CDNProfile 'Microsoft.Cdn/profiles@2022-11-01-preview' existing = {
  name: frontDoorName
}

@description('The ruleset to create.')
resource ruleSet 'Microsoft.Cdn/profiles/ruleSets@2022-11-01-preview' = {
  parent: CDNProfile
  name: ruleSetName
}


@description('The name of the ruleset created.')
output ruleSetName string = ruleSet.name
@description('The id of the ruleset created.')
output ruleSetId string = ruleSet.id
