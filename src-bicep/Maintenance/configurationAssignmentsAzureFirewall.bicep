/*
.SYNOPSIS
Maintenance Configuration Assignment for Azure Firewall.
.DESCRIPTION
Assigns an existing Maintenance Configuration directly to a single existing Azure Firewall, as an extension resource scoped to that firewall.
Use this (instead of configurationAssignments.bicep, which targets resources dynamically via subscription-level tag/location/resourceGroup filters restricted to Microsoft.Compute/virtualMachines and Microsoft.HybridCompute/machines)
when you want to target one specific Azure Firewall by name, e.g. for a customer-controlled maintenance window (maintenanceScope 'Resource').
.EXAMPLE
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
.LINKS
- [Configure customer-controlled maintenance for Azure Firewall](https://learn.microsoft.com/en-us/azure/firewall/customer-controlled-maintenance)
- [Bicep Microsoft.Maintenance configurationassignments](https://learn.microsoft.com/en-us/azure/templates/microsoft.maintenance/configurationassignments?pivots=deployment-language-bicep)
*/

// ================================================= Parameters =================================================
@description('Specifies the Azure location of the configuration assignment. Should match the Azure Firewall location.')
param location string = resourceGroup().location

@description('The name of the existing Azure Firewall to assign the maintenance configuration to.')
param azureFirewallName string

@description('The name of the maintenance configuration assignment resource.')
@minLength(1)
@maxLength(80)
param maintenanceConfigurationAssignmentName string = '${azureFirewallName}-maintenanceassignment'

@description('The name of the existing maintenance configuration to assign.')
param maintenanceConfigurationName string

@description('The resource group name of the existing maintenance configuration.')
param maintenanceConfigurationResourceGroupName string = resourceGroup().name

// ================================================= Resources =================================================
@description('The existing Azure Firewall this maintenance configuration will be assigned to.')
resource azureFirewall 'Microsoft.Network/azureFirewalls@2024-05-01' existing = {
  name: azureFirewallName
}

@description('The existing maintenance configuration to assign.')
resource maintenanceConfiguration 'Microsoft.Maintenance/maintenanceConfigurations@2023-04-01' existing = {
  scope: resourceGroup(maintenanceConfigurationResourceGroupName)
  name: maintenanceConfigurationName
}

resource configurationAssignment 'Microsoft.Maintenance/configurationAssignments@2023-04-01' = {
  name: maintenanceConfigurationAssignmentName
  location: location
  scope: azureFirewall
  properties: {
    maintenanceConfigurationId: maintenanceConfiguration.id
    resourceId: azureFirewall.id
  }
}

output configurationAssignmentResourceId string = configurationAssignment.id
output configurationAssignmentName string = configurationAssignment.name
