# configurationAssignmentsAzureFirewall

Target Scope: resourceGroup

## Synopsis
Maintenance Configuration Assignment for Azure Firewall.

## Description
Assigns an existing Maintenance Configuration directly to a single existing Azure Firewall, as an extension resource scoped to that firewall.<br>
Use this (instead of configurationAssignments.bicep, which targets resources dynamically via subscription-level tag/location/resourceGroup filters restricted to Microsoft.Compute/virtualMachines and Microsoft.HybridCompute/machines)<br>
when you want to target one specific Azure Firewall by name, e.g. for a customer-controlled maintenance window (maintenanceScope 'Resource').

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location of the configuration assignment. Should match the Azure Firewall location. |
| azureFirewallName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the existing Azure Firewall to assign the maintenance configuration to. |
| maintenanceConfigurationAssignmentName | string | <input type="checkbox"> | Length between 1-80 | <pre>'&#36;{azureFirewallName}-maintenanceassignment'</pre> | The name of the maintenance configuration assignment resource. |
| maintenanceConfigurationName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the existing maintenance configuration to assign. |
| maintenanceConfigurationResourceGroupName | string | <input type="checkbox"> | None | <pre>resourceGroup().name</pre> | The resource group name of the existing maintenance configuration. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| configurationAssignmentResourceId | string |  |
| configurationAssignmentName | string |  |

## Examples
<pre>
module fwMaintenanceAssignment 'br:contosoregistry.azurecr.io/maintenance/configurationassignmentsazurefirewall.bicep' = {
  name: format('{0}-{1}', take('${deployment().name}', 61), 'fwmaintassign')
  params: {
    location: location
    azureFirewallName: azureFirewallName
    maintenanceConfigurationName: maintenanceConfiguration.outputs.maintenanceConfigurationName
    maintenanceConfigurationResourceGroupName: resourceGroup().name
  }
}
</pre>
<p>Assigns an existing maintenance configuration to an existing Azure Firewall.</p>

## Links
- [Configure customer-controlled maintenance for Azure Firewall](https://learn.microsoft.com/en-us/azure/firewall/customer-controlled-maintenance)<br>
- [Bicep Microsoft.Maintenance configurationassignments](https://learn.microsoft.com/en-us/azure/templates/microsoft.maintenance/configurationassignments?pivots=deployment-language-bicep)
