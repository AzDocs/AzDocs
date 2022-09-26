# ddosProtectionPlans

Target Scope: resourceGroup

## Synopsis
Creating a DDOS Protection Plans

## Description
Creating a DDOS Protection Plans.<br>
Azure DDoS Protection Standard, combined with application design best practices, provides enhanced DDoS mitigation features to defend against DDoS attacks.<br>
It's automatically tuned to help protect your specific Azure resources in a virtual network. Protection is simple to enable on any new or existing virtual network, and it requires no application or resource changes.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| ddosProtectionPlanName | string | <input type="checkbox" checked> | Length between 2-64 | <pre></pre> | Specifies the name of the ddos protection plan. This can be suffixed with the environmentType parameter. Format: <ddosProtectionPlanName>-<environmentType>. |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| ddosProtectionPlanId | string | Outputs the Resource ID of the upserted DDOS Protection plan. |
## Examples
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

## Links
- [Azure DDoS Protection Standard documentation](https://docs.microsoft.com/en-us/azure/ddos-protection/)<br>
- [Bicep DDoS Protection documentation](https://docs.microsoft.com/en-us/azure/templates/microsoft.network/ddosprotectionplans?pivots=deployment-language-bicep)


