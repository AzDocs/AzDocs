# firewallPolicies

Target Scope: resourceGroup

## Synopsis
Azure Firewall Policy module.

## Description
Add an Azure Firewall Policy to the resource group. This can be linked to an Azure Firewall.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Location for all resources. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| firewallPolicyName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the firewall policy. |
| threatIntelMode | string | <input type="checkbox"> | `'Alert'` or `'Deny'` or `'Off'` | <pre>'Alert'</pre> | The threat intelligence mode of the firewall policy. |
| insightsEnabled | bool | <input type="checkbox"> | None | <pre>false</pre> | Whether or not to enable Policy Analytics for the firewall policy. |
| logAnalyticsResourcesDefaultWorkspaceId | string | <input type="checkbox"> | None | <pre>''</pre> | The default log analytics workspace id for the firewall policy to use for the Policy Analytics. |
| workspacesRegion | string | <input type="checkbox"> | None | <pre>'westeurope'</pre> | The region from where you can choose log analytics workspaces to use for the firewall policy to use for Policy Analytics. |
| insightsRetentionDays | int | <input type="checkbox"> | None | <pre>30</pre> | The number of days the Policy Analytics data for the firewall policy is saved in the log analytics workspace. |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| firewallPolicyResourceId | string | The resource id of the firewall policy. |
| firewallPolicyName | string | The name of the firewall policy. |
## Examples
<pre>
module firewallPolicy 'br:contosoregistry.azurecr.io/network/firewallpolicies:latest' = if( !empty(firewallPolicyName)) {
  name: format('{0}-{1}', take('${deployment().name}', 54), 'fw-policy')
  params: {
    firewallPolicyName: firewallPolicyName
    location: location
  }
}
</pre>
<p>Creates a Firewall Policy with the name of the parameter firewallPolicyName if that is filled with a name value.</p>


