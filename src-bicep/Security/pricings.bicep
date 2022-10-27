/*
.SYNOPSIS
Enabling and configuring Defender for Cloud on a Subscription
.DESCRIPTION
Enables and Configures Defender for Cloud on a Subscription. You need to do the deploy on a subscription level.
.EXAMPLE
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
.LINKS
- [Bicep Pricings Defender for Cloud](https://learn.microsoft.com/en-us/azure/templates/microsoft.security/pricings?pivots=deployment-language-bicep)
- [Bicep enable Defender for Cloud via Bicep](https://cloudadministrator.net/2022/10/20/enable-defender-for-cloud-auto-provisioning-agents-via-bicep/#more-4899)
*/

// ================================================= Parameters =================================================
targetScope = 'subscription'

@description('The name of the pricing plan')
@minLength(1)
@maxLength(260)
param defenderPlanName string

@description('''
The pricing tier for the specific Defender for Cloud Plan
Example:
'Free'
'Standard'
''')
param defenderPricingTier string

@description('''
The subplan for the specific Defender for Cloud Plan.
The sub-plan selected for a Standard pricing configuration, when more than one sub-plan is available. Each sub-plan enables a set of security features.
When subplan is not specified at all, the full plan is applied.
Example:
'P1',
'P2'
'''
)
param defenderSubPlan string = 'P2'


resource defenderPricingPlan 'Microsoft.Security/pricings@2022-03-01' = {
  name: defenderPlanName
  properties: {
    pricingTier: defenderPricingTier
    subPlan: defenderSubPlan
  }
}
