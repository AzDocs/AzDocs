/*
.SYNOPSIS
Creating a security policy in an existing FrontDoor Cdn profile.
.DESCRIPTION
Creating a security policy in an existing FrontDoor Cdn profile.
<pre>
module secpolicy 'br:contosoregistry.azurecr.io/cdn/profiles/securitypolicies.bicep' = {
  name: format('{0}-{1}', take('${deployment().name}', 54), 'secpolicy')
  params: {
    afdEndpointsName: afdendpointappgw.outputs.frontDoorEndpointName
    frontDoorName: frontDoorProfile.outputs.frontDoorName
    securityPolicyName: 'securitypolicypub-tst-site-com'
    wafPolicyName: frontdoorwafmypubtstonsitecom.outputs.wafPolicyName
  }
}
</pre>
<p>Creates a security policy in an existing Frontdoor Cdn Profile.</p>
.LINKS
- [Bicep Microsoft.Cdn profiles endpoint groupname](https://learn.microsoft.com/en-us/azure/templates/microsoft.cdn/profiles/securitypolicies?pivots=deployment-language-bicep)
*/
// ===================================== Parameters =====================================
@description('Specifies the name of the security policy.')
param securityPolicyName string

@description('The name of the existing Front Door Cdn profile to create.')
param frontDoorName string

@description('Specifies the list of patterns to match by the security policy.')
param securityPolicyPatternsToMatch array = [ '/*' ]

@description('Specifies the name of the existing Azure Front Door WAF policy.')
param wafPolicyName string

@description('The name of the existing AFD endpoint.')
param afdEndpointsName string


// ===================================== Resources =====================================
@description('The ID of the Azure resource that represents the existing Front Door Cdn profile.')
resource CDNProfile 'Microsoft.Cdn/profiles@2022-11-01-preview' existing = {
  name: frontDoorName
}

@description('The Azure resource that represents the existing Front Door WAF policy.')
resource wafPolicy 'Microsoft.Network/FrontDoorWebApplicationFirewallPolicies@2022-05-01' existing = {
  name: wafPolicyName
}

@description('The Azure resource that represents the existing AFD endpoint.')
resource afdEndpoint 'Microsoft.Cdn/profiles/afdEndpoints@2022-11-01-preview' existing = {
  parent: CDNProfile
  name: afdEndpointsName
}

@description('The security policy resource to create.')
resource securityPolicy 'Microsoft.Cdn/profiles/securitypolicies@2022-11-01-preview' = {
  parent: CDNProfile
  name: securityPolicyName
  properties: {
    parameters: {
      type: 'WebApplicationFirewall'
      wafPolicy: {
        id: wafPolicy.id
      }
      associations: [
        {
          domains: [
            {
              id: afdEndpoint.id
            }
          ]
          patternsToMatch: securityPolicyPatternsToMatch
        }
      ]
    }
  }
}

@description('The name of the security policy created.')
output securityPolicyName string = securityPolicy.name
@description('The ID of the security policy created.')
output securityPolicyId string = securityPolicy.id
