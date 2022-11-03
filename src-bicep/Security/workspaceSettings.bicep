/*
.SYNOPSIS
Configuring log analytics workspace settings for Defender for Cloud on a Subscription
.DESCRIPTION
Configures Defender for Cloud on a Subscription. You need to do the deploying on a subscription level.
Scope: All the VMs in this scope will send their security data to the mentioned workspace unless overridden by a setting with more specific scope.
.EXAMPLE
<pre>
module autoProvisioningWorkspaceSettings 'Security/workspaceSettings.bicep' = {
  name: format('{0}-{1}', take('${deployment().name}', 37), 'defenderautoProvisioningws')
  params: {
    logAnalyticsWorkspaceResourceId: logAnalyticsWorkspaceResourceId
  }
  dependsOn: [
    defenderPlan
  ]
}
</pre>
<p>Configures Defender for Cloud</p>
.LINKS
- [Bicep Pricings Defender for Cloud](https://learn.microsoft.com/en-us/azure/templates/microsoft.security/workspacesettings?pivots=deployment-language-bicep)
*/
// ================================================= Parameters =================================================
targetScope = 'subscription'

@description('the resource id of the log analytics workspace.')
param logAnalyticsWorkspaceResourceId string


resource autoProvisioningWorkspaceSettings 'Microsoft.Security/workspaceSettings@2017-08-01-preview' = {
  name: 'default'
  properties: {
    scope: '/subscriptions/${az.subscription().subscriptionId}'
    workspaceId: logAnalyticsWorkspaceResourceId
  }
}
