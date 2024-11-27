/*
.SYNOPSIS
Creating a origin GroupName with an optional origin in an existing FrontDoor profile with an existing endpoint.
.DESCRIPTION
Creating a origin GroupName endpoint with an optional origin in an existing FrontDoor profile with an existing endpoint.
<pre>
module origin 'br:contosoregistry.azurecr.io/cdn/profiles/origingroups/origins.bicep' = [for (origin, index) in originGroupOrigins:{
  name: format('{0}-{1}', take('${deployment().name}', 57), origin.name)
  params: {
    originGroupName: origingroup.outputs.originGroupName
    originName: origin.name
    originHostNameFqdn: origin.hostname
    frontDoorName: frontDoorProfile.outputs.frontDoorName
    //originHostHeader: contains(origin, 'originHostHeader') ? origin.originHostHeader : ''
    originEnabledState: origin.enabledState
  }
}]
</pre>
<p>Creates an origin in a existing origin GroupName called originGroupName in an existing Frontdoor Profile.</p>
.LINKS
- [Bicep Microsoft.Cdn profiles endpoint groupname origin](https://learn.microsoft.com/en-us/azure/templates/microsoft.cdn/profiles/origingroups/origins?pivots=deployment-language-bicep)
*/
// ===================================== Parameters =====================================
@description('The name of at least one origin to create.')
@minLength(1)
@maxLength(50)
param originName string

@description('''
The FQDN of at least one origin to create. Specifies the address of the origin. Domain names, IPv4 addresses, and IPv6 addresses are supported.
This should be unique across all origins in an endpoint.
''')
param originHostNameFqdn string

@description('The name of the existing origin GroupName to create the origins in.')
param originGroupName string

@description('The name of the existing Front Door Cdn profile to create.')
param frontDoorName string

@description('''
Specifies the host header value sent to the origin with each request. If you leave this blank, the request hostname determines this value.
Azure Front Door origins, such as Web Apps, Blob Storage, and Cloud Services require this host header value to match the origin hostname by default.
This overrides the host header defined at Endpoint.
''')
param originHostHeader string = ''

@description('Specifies whether to enable health probes to be made against backends defined under backendPools. Health probes can only be disabled if there is a single enabled backend in single enabled backend pool.')
param originEnabledState bool = true

@description('The name of the private link service to use. If empty, no private link will be used.')
param privateLinkName string = ''

@description('''
The existing private link service to use. Expected if privateLinkName is not empty.
Origin support for direct private endpoint connectivity is currently limited to:
Storage (Azure Blobs)
App Services
Internal load balancers (VMs can be behind these).
''')
param privateLinkResourceId string = ''

@description('''
The group id from the provider of resource the shared private link resource is for.
Example:
'blob'
''')
param groupId string = ''

@description('The location of the shared private link resource')
param privateLinkLocation string = ''

@description('Specifies the value of the HTTP port. Must be between 1 and 65535.')
param httpPort int = 80

@description('Specifies the value of the HTTPS port. Must be between 1 and 65535.')
param httpsPort int = 443

@description('Specifies the priority of origin in given origin group for load balancing. Higher priorities will not be used for load balancing if any lower priority origin is healthy.Must be between 1 and 5.')
@minValue(1)
@maxValue(5)
param priority int = 1

@description('Specifies the weight of the origin in a given origin group for load balancing. Must be between 1 and 1000.')
@minValue(1)
@maxValue(1000)
param weight int = 1000

@description('''
Whether to enable certificate name check at origin level.
If enabled, this will validate the certificate name at origin against the request hostname.
If disabled, this will not validate the certificate name at origin against the request hostname.
If not specified, this will default to true.
''')
param enforceCertificateNameCheck bool = true

// ===================================== Resources =====================================
@description('The ID of the existing Azure resource that represents the Front Door Cdn Profile.')
resource CDNProfile 'Microsoft.Cdn/profiles@2022-11-01-preview' existing = {
  name: frontDoorName
}

@description('The existing originGroup to use.')
resource originGroup 'Microsoft.Cdn/profiles/originGroups@2022-11-01-preview' existing = {
  parent: CDNProfile
  name: originGroupName
}

@description('The origin to create.')
resource origins 'Microsoft.Cdn/profiles/originGroups/origins@2022-11-01-preview' = {
  parent: originGroup
  name: originName
  properties: {
    hostName: originHostNameFqdn
    httpPort: httpPort
    httpsPort: httpsPort
    originHostHeader: !empty(originHostHeader) ? originHostHeader : null
    priority: priority
    weight: weight
    enabledState: bool(originEnabledState) ? 'Enabled' : 'Disabled'
    enforceCertificateNameCheck: enforceCertificateNameCheck
    sharedPrivateLinkResource: empty(privateLinkName)
      ? null
      : {
          privateLink: {
            id: privateLinkResourceId
          }
          groupId: groupId
          privateLinkLocation: privateLinkLocation
          requestMessage: 'Private link service from AFD'
        }
  }
}

@description('The fqdn of the origin name created.')
output originHostNameFqdn string = origins.properties.hostName
@description('The name of the origin created.')
output originName string = origins.name
@description('The id of the origin created.')
output originNameId string = origins.id
