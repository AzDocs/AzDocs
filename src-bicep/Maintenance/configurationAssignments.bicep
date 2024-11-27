/*
.SYNOPSIS
Maintenance Configuration Assignment
.DESCRIPTION
Creates a Maintenance Configuration Assignment which is a way to add a dynamic scope to an existing Maintenance Configuration resource on subscription level. 
This allows you to target specific resources based on their tags, location, resource group, or resource type. 
The Maintenance Configuration Assignment resource is a child resource of the Maintenance Configuration resource. 
.EXAMPLE
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
.LINKS
- [Maintenance Configuration](https://learn.microsoft.com/en-us/azure/templates/microsoft.maintenance/configurationassignments?pivots=deployment-language-bicep)
*/

// ================================================= Parameters =================================================
targetScope = 'subscription'

@description('The name of the existing maintenance configuration.')
param maintenanceConfigurationName string

@description('The resource group name of the existing maintenance configuration.')
param maintenanceConfigurationResourceGroupName string

@description('The name of the maintenance configuration assignment.')
param maintenanceConfigurationAssignmentName string

@description('The subscription id of the subscription you want to assign the dynamic scope to with the filters.')
param subscriptionId string = subscription().id

@description('The OS types of the resources you want to apply the maintenance configuration to.')
@allowed([
  'windows'
  'linux'
])
param osTypes array = [
  'windows'
  'linux'
]

@description('Filter of the location of the resources you want to apply the maintenance configuration to.')
param locations array = [
  'westeurope'
]

@description('Filter of the resource groups of the resources you want to apply the maintenance configuration to.')
param resourceGroupsToApplyTo array = []

@description('Filter of the resource types of the resources you want to apply the maintenance configuration to.')
@allowed([
  'Microsoft.HybridCompute/machines'
  'Microsoft.Compute/virtualMachines'
])
param resourceTypesIncluded array = [
  'Microsoft.Compute/virtualMachines'
]

@description('Filter of the tags of the resources you want to apply the maintenance configuration to.')
param tagSettingsToFilterOn object = {
  filterOperator: 'All'
  tags: {
    Patchday: ['Tuesday']
  }
}

// ================================================= Resources =================================================
@description('The existing maintenance configuration instance.')
resource maintenanceConfiguration 'Microsoft.Maintenance/maintenanceConfigurations@2023-04-01' existing = {
  scope: resourceGroup(maintenanceConfigurationResourceGroupName)
  name: maintenanceConfigurationName
}

resource configurationAssignment 'Microsoft.Maintenance/configurationAssignments@2023-04-01' = {
  name: guid(maintenanceConfigurationAssignmentName)
  properties: {
    filter: {
      locations: locations
      osTypes: osTypes
      resourceGroups: resourceGroupsToApplyTo
      resourceTypes: resourceTypesIncluded
      tagSettings: tagSettingsToFilterOn
    }
    maintenanceConfigurationId: maintenanceConfiguration.id
    resourceId: subscriptionId
  }
}
