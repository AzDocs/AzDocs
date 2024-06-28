# pricings

Target Scope: subscription

## User Defined Types
| Name | Type | Discriminator | Description
| -- |  -- | -- | -- |
| <a id="Extension">Extension</a>  | <pre>{ name: string, isEnabled: string, additionalExtensionProperties: object? }</pre> |  | See also https://learn.microsoft.com/en-us/azure/templates/microsoft.security/pricings?pivots=deployment-language-bicep#extension | 

## Synopsis
Enabling and configuring Defender for Cloud on a Subscription

## Description
Enables and Configures Defender for Cloud on a Subscription. You need to do the deploy on a subscription level.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| defenderPlanName | string | <input type="checkbox" checked> | Length between 1-260 | <pre></pre> | The name of the pricing plan |
| defenderPricingTier | string | <input type="checkbox" checked> | None | <pre></pre> | The pricing tier for the specific Defender for Cloud Plan<br>Example:<br>'Free'<br>'Standard' |
| defenderSubPlan | string | <input type="checkbox"> | None | <pre>'P2'</pre> | The subplan for the specific Defender for Cloud Plan.<br>The sub-plan selected for a Standard pricing configuration, when more than one sub-plan is available. Each sub-plan enables a set of security features.<br>When subplan is not specified at all, the full plan is applied.<br>Example:<br>'P1',<br>'P2' |
| extensions | Extension[] | <input type="checkbox"> | None | <pre>[]</pre> | List of extensions offered under a plan.<br>for example:<br>[<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;name: 'AgentlessVmScanning'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;isEnabled: 'false'<br>&nbsp;&nbsp;&nbsp;}<br>] |

## Examples
<pre>
var enableSecurityCenterFor = [
  {
    name: 'CloudPosture'
    subPlan: ''
    defenderPricingTier: 'Standard'
  }
  {
    name: 'VirtualMachines'
    subPlan: 'P2'
    defenderPricingTier: 'Standard'
  }
]
module defenderPlan 'Security/pricings.bicep' = [for i in range(0, length(enableSecurityCenterFor)): {
  name: format('{0}-{1}', take('${deployment().name}', 29), 'enableSecurityCenterFor${[i].name}')
  params: {
    defenderPlanName: '${enableSecurityCenterFor[i].name}'
    defenderPricingTier: '${enableSecurityCenterFor[i].defenderPricingTier}'
    defenderSubPlan: '${enableSecurityCenterFor[i].subPlan}'
  }
}]
</pre>
<p>Configures Defender for Cloud with Defender CSPM and Servers plan.</p>

## Links
- [Bicep Pricings Defender for Cloud](https://learn.microsoft.com/en-us/azure/templates/microsoft.security/pricings?pivots=deployment-language-bicep)<br>
- [Bicep enable Defender for Cloud via Bicep](https://cloudadministrator.net/2022/10/20/enable-defender-for-cloud-auto-provisioning-agents-via-bicep/#more-4899)
