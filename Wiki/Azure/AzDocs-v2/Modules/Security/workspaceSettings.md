# workspaceSettings

Target Scope: subscription

## Synopsis
Configuring log analytics workspace settings for Defender for Cloud on a Subscription

## Description
Configures Defender for Cloud on a Subscription. You need to do the deploying on a subscription level.<br>
Scope: All the VMs in this scope will send their security data to the mentioned workspace unless overridden by a setting with more specific scope.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| logAnalyticsWorkspaceResourceId | string | <input type="checkbox" checked> | None | <pre></pre> | the resource id of the log analytics workspace. |

## Examples
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

## Links
- [Bicep Pricings Defender for Cloud](https://learn.microsoft.com/en-us/azure/templates/microsoft.security/workspacesettings?pivots=deployment-language-bicep)
