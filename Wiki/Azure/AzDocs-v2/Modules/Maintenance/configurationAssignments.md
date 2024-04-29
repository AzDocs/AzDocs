# configurationAssignments

Target Scope: subscription

## Synopsis
Maintenance Configuration Assignment

## Description
Creates a Maintenance Configuration Assignment which is a way to add a dynamic scope to an existing Maintenance Configuration resource on subscription level. <br>
This allows you to target specific resources based on their tags, location, resource group, or resource type. <br>
The Maintenance Configuration Assignment resource is a child resource of the Maintenance Configuration resource. 

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| maintenanceConfigurationName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the existing maintenance configuration. |
| maintenanceConfigurationResourceGroupName | string | <input type="checkbox" checked> | None | <pre></pre> | The resource group name of the existing maintenance configuration. |
| maintenanceConfigurationAssignmentName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the maintenance configuration assignment. |
| subscriptionId | string | <input type="checkbox"> | None | <pre>subscription().id</pre> | The subscription id of the subscription you want to assign the dynamic scope to with the filters. |
| osTypes | array | <input type="checkbox"> | `'windows'` or `'linux'` | <pre>[<br>  'windows'<br>  'linux'<br>]</pre> | The OS types of the resources you want to apply the maintenance configuration to. |
| locations | array | <input type="checkbox"> | None | <pre>[<br>  'westeurope'<br>]</pre> | Filter of the location of the resources you want to apply the maintenance configuration to. |
| resourceGroupsToApplyTo | array | <input type="checkbox"> | None | <pre>[]</pre> | Filter of the resource groups of the resources you want to apply the maintenance configuration to. |
| resourceTypesIncluded | array | <input type="checkbox"> | `'Microsoft.HybridCompute/machines'` or `'Microsoft.Compute/virtualMachines'` | <pre>[<br>  'Microsoft.Compute/virtualMachines'<br>]</pre> | Filter of the resource types of the resources you want to apply the maintenance configuration to. |
| tagSettingsToFilterOn | object | <input type="checkbox"> | None | <pre>{<br>  filterOperator: 'All'<br>  tags: {<br>   Patchday: ['Tuesday']<br>  }<br>}</pre> | Filter of the tags of the resources you want to apply the maintenance configuration to. |

## Examples
<pre>
module configass '../../AzDocs/src-bicep/Maintenance/configurationAssignments.bicep' = {
  name: format('{0}-{1}', take('${deployment().name}', 61), 'ca')
  params: {
    maintenanceConfigurationName: existingmaintenanceconfig.name
    maintenanceConfigurationResourceGroupName: 'my-rg-dev'
    maintenanceConfigurationAssignmentName: 'testname'
    maintenanceConfigurationAssignmentName: 'mymaintassname'
    osTypes: ['linux']
    resourceGroupsToApplyTo: ['azure4-vms-dev']
    resourceTypesIncluded: ['Microsoft.Compute/virtualMachines']
    tagSettingsToFilterOn: {
      filterOperator: 'All'
      tags: {
        Patchday: ['Tuesday']
      }
    }
  }
}
</pre>
<p>Creates a maintenance configuration assignment in an existing maintenance configuration.</p>

## Links
- [Maintenance Configuration](https://learn.microsoft.com/en-us/azure/templates/microsoft.maintenance/configurationassignments?pivots=deployment-language-bicep)
