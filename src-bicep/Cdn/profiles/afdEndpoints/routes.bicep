/*
.SYNOPSIS
Create a route in an existing endpoint on a Frontdoor Cdn.
.DESCRIPTION
Create a route in an existing endpoint on a Frontdoor Cdn.
<pre>
module route 'br:contosoregistry.azurecr.io/profiles/afdEndpoints/routes.bicep' = {
  name: format('{0}-{1}', take('${deployment().name}', 58), 'route')
  params: {
    afdEndpointsName: afdendpointappgw.outputs.frontDoorEndpointName
    customDomains:[
      {
        id:customdomainpub.outputs.customDomainId
      }
    ]
    frontDoorName: frontDoorProfile.outputs.frontDoorName
    forwardingProtocol: 'MatchRequest'
    linkToDefaultDomain: 'Disabled'
    originGroupName: origingroupappgw.outputs.originGroupName
    routePatternsToMatch: [
      '/api/*'
    ]
    routeName: 'mypub-be-api'
    ruleSets: [
      {
        id: rulesetadddefaultresponseheaders.outputs.ruleSetId
      }
    ]
    originName: originappgw.outputs.originName
  }
  dependsOn: [
    origingroupappgw
    originappgw
  ]
}
</pre>
<p>Creates a route in an existing frontdoor profile with existing endpoint, existing origingroup, origin and ruleset</p>
.LINKS
- [Bicep Microsoft.Cdn endpoints routes](https://learn.microsoft.com/en-us/azure/templates/microsoft.cdn/profiles/afdendpoints/routes?pivots=deployment-language-bicep)
*/
// ===================================== Parameters =====================================
@description('Specifies the name of the Azure Front Door Route for the web application.')
@minLength(1)
@maxLength(50)
param routeName string

@description('The name of the existing AFD endpoint.')
param afdEndpointsName string

@description('Specifies the domains referenced by the endpoint.')
param customDomains array = []

@description('The name of the existing origin GroupName.')
param originGroupName string

@description('The name of the existing Front Door Cdn profile.')
param frontDoorName string

@description('Specifies a directory path on the origin that Azure Front Door Cdn can use to retrieve content from, e.g. contoso.cloudapp.net/originpath.')
param originPath string = '/'

@description('Specifies the rule sets referenced by this endpoint.')
param ruleSets array = []

@description('Specifies the list of supported protocols for this route. This can be Http Only, Https Only or Http and Https.')
param supportedProtocols array = [
  'Http'
  'Https'
]

@description('Specifies the route patterns of the rule.')
param routePatternsToMatch array = ['/*']

@description('Specifies the protocol this rule will use when forwarding traffic to backends.')
@allowed([
  'HttpOnly'
  'HttpsOnly'
  'MatchRequest'
])
param forwardingProtocol string = 'MatchRequest'

@description('Specifies whether this route will be linked to the default endpoint domain.')
@allowed([
  'Enabled'
  'Disabled'
])
param linkToDefaultDomain string = 'Enabled'

@description('Specifies whether to automatically redirect HTTP traffic to HTTPS traffic. Note that this is an easy way to set up this rule and it will be the first rule that gets executed.')
@allowed([
  'Enabled'
  'Disabled'
])
param httpsRedirect string = 'Enabled'

@description('The name of an existing origin in the existing Origin Group.')
param originName string

@description('Specifies the cache configuration for this route.')
param cacheConfiguration object = {}

// ===================================== Resources ======================================
@description('The ID of the existing Azure resource that represents the Front Door Cdn Profile.')
resource CDNProfile 'Microsoft.Cdn/profiles@2022-11-01-preview' existing = {
  name: frontDoorName
}

@description('The existing endpoint to use.')
resource afdEndpoint 'Microsoft.Cdn/profiles/afdEndpoints@2022-11-01-preview' existing = {
  parent: CDNProfile
  name: afdEndpointsName
}

@description('The existing originGroup to use.')
resource originGroup 'Microsoft.Cdn/profiles/originGroups@2022-11-01-preview' existing = {
  parent: CDNProfile
  name: originGroupName
}

@description('The existing origin to use.')
resource origin 'Microsoft.Cdn/profiles/originGroups/origins@2022-11-01-preview' existing = {
  parent: originGroup
  name: originName
}

@description('The route to create.')
resource route 'Microsoft.Cdn/profiles/afdEndpoints/routes@2022-11-01-preview' = {
  parent: afdEndpoint
  name: routeName
  properties: {
    cacheConfiguration: empty(cacheConfiguration) ? null : cacheConfiguration
    customDomains: customDomains
    originGroup: {
      id: originGroup.id
    }
    originPath: originPath
    ruleSets: ruleSets
    supportedProtocols: supportedProtocols
    patternsToMatch: routePatternsToMatch
    forwardingProtocol: forwardingProtocol
    linkToDefaultDomain: linkToDefaultDomain
    httpsRedirect: httpsRedirect
  }
  dependsOn: [
    origin // origin must be created before route
  ]
}

@description('The ID of the route.')
output routeId string = route.id
@description('The name of the route.')
output routeName string = route.name
