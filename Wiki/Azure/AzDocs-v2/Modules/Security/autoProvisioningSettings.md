# autoProvisioningSettings

Target Scope: subscription

## Synopsis
Configuring Defender for Cloud auto provisioning settings for virtual machines.

## Description
Configures Defender for Cloud auto provisioning settings for virtual machines on a Subscription in the Servers plan. You need to do the deploy on a subscription level.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| autoProvisionStatus | string | <input type="checkbox"> | `'On'` or  `'Off'` | <pre>'On'</pre> | Describes what kind of security agent provisioning action to take. |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |
## Examples
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

## Links
- [Bicep autoprovisioning settings Defender for Cloud](https://learn.microsoft.com/en-us/azure/templates/microsoft.security/autoprovisioningsettings?pivots=deployment-language-bicep)


