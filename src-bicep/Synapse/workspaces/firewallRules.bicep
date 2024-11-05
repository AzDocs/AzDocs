/*
.SYNOPSIS
Create a Synapse Workspace firewall rule.
.DESCRIPTION
Create a Synapse Workspace firewall rul with the given specs.
.EXAMPLE
<pre>
module synapsefwrules 'br:contosoregistry.azurecr.io/synapse/workspaces/firewallrules:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 50), 'synapsefw')
  params: {
    synapseWorkSpaceName: 'synapsews'
    firewallRuleName: 'AllowAll'
    startIpAddress: '0.0.0.0'
    endIpAddress: '255.255.255.255'
  }
}
</pre>
<p>Creates an Synapse Analytics Workspace firewall rule.</p>
.LINKS
- [Bicep Microsoft.Synapse workspaces firewall rules](https://learn.microsoft.com/en-us/azure/templates/microsoft.synapse/workspaces/firewallrules?pivots=deployment-language-bicep)
*/

// ================================================= Parameters =================================================
@description('The name of the existing parent Synapse Workspace.')
param synapseWorkSpaceName string

@description('Required. The name of the firewall rule.')
param firewallRuleName string

@description('''
Required. The start IP address of the firewall rule. Must be IPv4 format.
Example: '86.87.243.35'
''')
param startIpAddress string

@description('''
Required. The end IP address of the firewall rule. Must be IPv4 format. Must be greater than or equal to startIpAddress.
Example: '86.87.243.35'
''')
param endIpAddress string

resource workspace 'Microsoft.Synapse/workspaces@2021-06-01' existing = {
  name: synapseWorkSpaceName
}

resource firewallRule 'Microsoft.Synapse/workspaces/firewallRules@2021-06-01' = {
  name: firewallRuleName
  parent: workspace
  properties: {
    startIpAddress: startIpAddress
    endIpAddress: endIpAddress
  }
}

@description('The name of the deployed firewall rule.')
output firewallName string = firewallRule.name
@description('The resource ID of the deployed firewall rule.')
output firewallResourceId string = firewallRule.id
