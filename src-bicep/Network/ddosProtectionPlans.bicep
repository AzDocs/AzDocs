/*
.SYNOPSIS
Creating a DDOS Protection Plans
.DESCRIPTION
Creating a DDOS Protection Plans.
Azure DDoS Protection Standard, combined with application design best practices, provides enhanced DDoS mitigation features to defend against DDoS attacks.
It's automatically tuned to help protect your specific Azure resources in a virtual network. Protection is simple to enable on any new or existing virtual network, and it requires no application or resource changes.
.EXAMPLE
<pre>
module ddos '../../AzDocs/src-bicep/Network/ddosProtectionPlans.bicep' = {
  name: 'Creating_ddos_plan'
  scope: resourceGroup
  params: {
    ddosProtectionPlanName: 'ddos-prd'
  }
}

var ddosProtectionPlanId =  ddos.ddosProtectionPlanId
</pre>
<p>Creates a DDOS protection plan</p>
.LINKS
- [Azure DDoS Protection Standard documentation](https://docs.microsoft.com/en-us/azure/ddos-protection/)
- [Bicep DDoS Protection documentation](https://docs.microsoft.com/en-us/azure/templates/microsoft.network/ddosprotectionplans?pivots=deployment-language-bicep)
*/
@description('Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location.')
param location string = resourceGroup().location

@description('''
The tags to apply to this resource. This is an object with key/value pairs.
Example:
{
  FirstTag: myvalue
  SecondTag: another value
}
''')
param tags object = {}

@description('''
Specifies the name of the ddos protection plan. This can be suffixed with the environmentType parameter. Format: <ddosProtectionPlanName>-<environmentType>.
''')
@minLength(2)
@maxLength(64)
param ddosProtectionPlanName string

resource ddosProtectionPlan 'Microsoft.Network/ddosProtectionPlans@2022-01-01' = {
  name: ddosProtectionPlanName
  location: location
  tags: tags
  properties: {}
}

@description('Outputs the Resource ID of the upserted DDOS Protection plan.')
output ddosProtectionPlanId string = ddosProtectionPlan.id
