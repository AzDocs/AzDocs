# firewallRules

Target Scope: resourceGroup

## Synopsis
Create a Synapse Workspace firewall rule.

## Description
Create a Synapse Workspace firewall rul with the given specs.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| synapseWorkSpaceName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the existing parent Synapse Workspace. |
| firewallRuleName | string | <input type="checkbox" checked> | None | <pre></pre> | Required. The name of the firewall rule. |
| startIpAddress | string | <input type="checkbox" checked> | None | <pre></pre> | Required. The start IP address of the firewall rule. Must be IPv4 format.<br>Example: '86.87.243.35' |
| endIpAddress | string | <input type="checkbox" checked> | None | <pre></pre> | Required. The end IP address of the firewall rule. Must be IPv4 format. Must be greater than or equal to startIpAddress.<br>Example: '86.87.243.35' |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| firewallName | string | The name of the deployed firewall rule. |
| firewallResourceId | string | The resource ID of the deployed firewall rule. |

## Examples
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

## Links
- [Bicep Microsoft.Synapse workspaces firewall rules](https://learn.microsoft.com/en-us/azure/templates/microsoft.synapse/workspaces/firewallrules?pivots=deployment-language-bicep)
