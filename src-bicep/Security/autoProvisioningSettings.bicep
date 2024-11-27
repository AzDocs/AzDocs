/*
.SYNOPSIS
Configuring Defender for Cloud auto provisioning settings for virtual machines.
.DESCRIPTION
Configures Defender for Cloud auto provisioning settings for virtual machines on a Subscription in the Servers plan. You need to do the deploy on a subscription level.
.EXAMPLE
<pre>
module autoProvisioning 'Security/autoProvisioningSettings.bicep' = {
  name: format('{0}-{1}', take('${deployment().name}', 48), 'dfcProvSettings')
  params: {
    autoProvisionStatus: 'On'
  }
  dependsOn: [
    autoProvisioningWorkspaceSettings
  ]
}
</pre>
<p>Configures Defender for Cloud autoprovisioning settings</p>
.LINKS
- [Bicep autoprovisioning settings Defender for Cloud](https://learn.microsoft.com/en-us/azure/templates/microsoft.security/autoprovisioningsettings?pivots=deployment-language-bicep)
*/
targetScope = 'subscription'

@description('Describes what kind of security agent provisioning action to take.')
@allowed([
  'On'
  'Off'
])
param autoProvisionStatus string = 'On'

resource autoProvisioning 'Microsoft.Security/autoProvisioningSettings@2017-08-01-preview' = {
  name: 'default'
  properties: {
    autoProvision: autoProvisionStatus
  }
}
