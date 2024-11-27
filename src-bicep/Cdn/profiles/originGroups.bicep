/*
.SYNOPSIS
Creating a origin GroupName with an optional origin in an existing FrontDoor profile with an existing endpoint.
.DESCRIPTION
Creating a origin GroupName endpoint with an optional origin in an existing FrontDoor profile with an existing endpoint.
<pre>
module origingroup 'br:contosoregistry.azurecr.io/cdn/profiles/origingroups.bicep' = {
  name: format('{0}-{1}', take('${deployment().name}', 52), 'origingroup')
  params: {
    frontDoorName: frontDoorProfile.outputs.frontDoorName
    originGroupName: originGroupName
  }
}
</pre>
<p>Creates an origin GroupName called originGroupName in an existing Frontdoor Cdn Profile.</p>
.LINKS
- [Bicep Microsoft.Cdn profiles endpoint groupname](https://learn.microsoft.com/en-us/azure/templates/microsoft.cdn/profiles/origingroups?pivots=deployment-language-bicep)
*/
// ===================================== Parameters =====================================
@description('The name of the origin GroupName to create. This must be unique within the Front Door profile.')
@minLength(1)
@maxLength(50)
param originGroupName string

@description('The name of the existing Front Door Cdn profile.')
param frontDoorName string

@description('Specifies the number of samples to consider for load balancing decisions.')
param sampleSize int = 4

@description('Specifies the number of samples within the sample period that must succeed.')
param successfulSamplesRequired int = 3

@description('Specifies the additional latency in milliseconds for probes to fall into the lowest latency bucket.')
param additionalLatencyInMilliseconds int = 50

@description('Specifies path relative to the origin that is used to determine the health of the origin.')
param probePath string = '/'

@description('Specifies the health probe request type.')
@allowed([
  'GET'
  'HEAD'
  'NotSet'
])
param probeRequestType string = 'HEAD'

@description('Specifies the health probe protocol.')
@allowed([
  'Http'
  'Https'
  'NotSet'
])
param probeProtocol string = 'Http'

@description('Specifies the number of seconds between health probes.Default is 240 seconds.')
param probeIntervalInSeconds int = 60

@description('Specifies whether to allow session affinity on this host. Valid options are Enabled or Disabled.')
@allowed([
  'Enabled'
  'Disabled'
])
param sessionAffinityState string = 'Disabled'

// ===================================== Resources =====================================
@description('The existing FrontDoor profile to use.')
resource frontdoor 'Microsoft.Cdn/profiles@2022-11-01-preview' existing = {
  name: frontDoorName
}

resource originGroup 'Microsoft.Cdn/profiles/originGroups@2022-11-01-preview' = {
  parent: frontdoor
  name: originGroupName
  properties: {
    loadBalancingSettings: {
      sampleSize: sampleSize
      successfulSamplesRequired: successfulSamplesRequired
      additionalLatencyInMilliseconds: additionalLatencyInMilliseconds
    }
    healthProbeSettings: {
      probePath: probePath
      probeRequestType: probeRequestType
      probeProtocol: probeProtocol
      probeIntervalInSeconds: probeIntervalInSeconds
    }
    sessionAffinityState: sessionAffinityState
  }
}

@description('The origin groupname created.')
output originGroupName string = originGroup.name
@description('The origin groupname resource id created.')
output originGroupResourceId string = originGroup.id
