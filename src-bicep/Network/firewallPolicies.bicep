/*
.SYNOPSIS
Azure Firewall Policy module.
.DESCRIPTION
Add an Azure Firewall Policy to the resource group. This can be linked to an Azure Firewall.
.EXAMPLE
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
.LINK
- [Bicep Microsoft.Network firewallpolicies](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/firewallpolicies?pivots=deployment-language-bicep)
*/

@description('Location for all resources.')
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

@description('The name of the firewall policy.')
param firewallPolicyName string

@description('The threat intelligence mode of the firewall policy.')
@allowed([
  'Alert'
  'Deny'
  'Off'
])
param threatIntelMode string = 'Alert'

@description('Whether or not to enable Policy Analytics for the firewall policy.')
param insightsEnabled bool = false

@description('The default log analytics workspace id for the firewall policy to use for the Policy Analytics.')
param logAnalyticsResourcesDefaultWorkspaceId string = ''

@description('The region from where you can choose log analytics workspaces to use for the firewall policy to use for Policy Analytics.')
param workspacesRegion string = 'westeurope'

@description('The number of days the Policy Analytics data for the firewall policy is saved in the log analytics workspace.')
param insightsRetentionDays int = 30

resource firewallPolicy 'Microsoft.Network/firewallPolicies@2023-05-01' = {
  name: firewallPolicyName
  tags: tags
  location: location
  properties: {
    threatIntelMode: threatIntelMode
    insights: (!insightsEnabled || empty(logAnalyticsResourcesDefaultWorkspaceId))
      ? null
      : {
          isEnabled: insightsEnabled
          logAnalyticsResources: {
            defaultWorkspaceId: {
              id: logAnalyticsResourcesDefaultWorkspaceId
            }
            workspaces: [
              {
                region: workspacesRegion
                workspaceId: {
                  id: logAnalyticsResourcesDefaultWorkspaceId
                }
              }
            ]
          }
          retentionDays: insightsRetentionDays
        }
  }
}

@description('The resource id of the firewall policy.')
output firewallPolicyResourceId string = firewallPolicy.id
@description('The name of the firewall policy.')
output firewallPolicyName string = firewallPolicy.name
