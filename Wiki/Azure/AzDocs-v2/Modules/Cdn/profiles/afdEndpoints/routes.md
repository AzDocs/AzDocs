# routes

Target Scope: resourceGroup

## Synopsis
Create a route in an existing endpoint on a Frontdoor Cdn.

## Description
Create a route in an existing endpoint on a Frontdoor Cdn.<br>
<pre><br>
module route 'br:contosoregistry.azurecr.io/profiles/afdEndpoints/routes.bicep' = {<br>
  name: format('{0}-{1}', take('${deployment().name}', 58), 'route')<br>
  params: {<br>
    afdEndpointsName: afdendpointappgw.outputs.frontDoorEndpointName<br>
    customDomains:[<br>
      {<br>
        id:customdomainpub.outputs.customDomainId<br>
      }<br>
    ]<br>
    frontDoorName: frontDoorProfile.outputs.frontDoorName<br>
    forwardingProtocol: 'MatchRequest'<br>
    linkToDefaultDomain: 'Disabled'<br>
    originGroupName: origingroupappgw.outputs.originGroupName<br>
    routePatternsToMatch: [<br>
      '/api/*'<br>
    ]<br>
    routeName: 'mypub-be-api'<br>
    ruleSets: [<br>
      {<br>
        id: rulesetadddefaultresponseheaders.outputs.ruleSetId<br>
      }<br>
    ]<br>
    originName: originappgw.outputs.originName<br>
  }<br>
  dependsOn: [<br>
    origingroupappgw<br>
    originappgw<br>
  ]<br>
}<br>
</pre><br>
<p>Creates a route in an existing frontdoor profile with existing endpoint, existing origingroup, origin and ruleset</p>

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| routeName | string | <input type="checkbox" checked> | Length between 1-50 | <pre></pre> | Specifies the name of the Azure Front Door Route for the web application. |
| afdEndpointsName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the existing AFD endpoint. |
| customDomains | array | <input type="checkbox"> | None | <pre>[]</pre> | Specifies the domains referenced by the endpoint. |
| originGroupName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the existing origin GroupName. |
| frontDoorName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the existing Front Door Cdn profile. |
| originPath | string | <input type="checkbox"> | None | <pre>'/'</pre> | Specifies a directory path on the origin that Azure Front Door Cdn can use to retrieve content from, e.g. contoso.cloudapp.net/originpath. |
| ruleSets | array | <input type="checkbox"> | None | <pre>[]</pre> | Specifies the rule sets referenced by this endpoint. |
| supportedProtocols | array | <input type="checkbox"> | None | <pre>[<br>  'Http'<br>  'Https'<br>]</pre> | Specifies the list of supported protocols for this route. This can be Http Only, Https Only or Http and Https. |
| routePatternsToMatch | array | <input type="checkbox"> | None | <pre>[ '/*' ]</pre> | Specifies the route patterns of the rule. |
| forwardingProtocol | string | <input type="checkbox"> | `'HttpOnly'` or `'HttpsOnly'` or `'MatchRequest'` | <pre>'MatchRequest'</pre> | Specifies the protocol this rule will use when forwarding traffic to backends. |
| linkToDefaultDomain | string | <input type="checkbox"> | `'Enabled'` or `'Disabled'` | <pre>'Enabled'</pre> | Specifies whether this route will be linked to the default endpoint domain. |
| httpsRedirect | string | <input type="checkbox"> | `'Enabled'` or `'Disabled'` | <pre>'Enabled'</pre> | Specifies whether to automatically redirect HTTP traffic to HTTPS traffic. Note that this is an easy way to set up this rule and it will be the first rule that gets executed. |
| originName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of an existing origin in the existing Origin Group. |
| cacheConfiguration | object | <input type="checkbox"> | None | <pre>{}</pre> | Specifies the cache configuration for this route. |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| routeId | string | The ID of the route. |
| routeName | string | The name of the route. |
## Links
- [Bicep Microsoft.Cdn endpoints routes](https://learn.microsoft.com/en-us/azure/templates/microsoft.cdn/profiles/afdendpoints/routes?pivots=deployment-language-bicep)


