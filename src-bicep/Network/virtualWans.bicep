/*
.SYNOPSIS
Creating a Virtual WAN.
.DESCRIPTION
Creating a Virtual WAN with the given specs.
.EXAMPLE
<pre>
module virtualWan 'br:contosoregistry.azurecr.io/network/virtualWans:latest' = {
  name: '${deployment().name}-vwan'
  params: {
    name: virtualWanName
    location: location
    type: 'Standard'
    allowBranchToBranchTraffic: true
  }
}
</pre>
<p>Creates a Virtual WAN with Standard type and branch-to-branch traffic enabled.</p>
.LINKS
- [Bicep Microsoft.Network virtualWans](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/virtualwans?pivots=deployment-language-bicep)
- [Virtual WAN overview](https://learn.microsoft.com/en-us/azure/virtual-wan/virtual-wan-about)
*/
metadata name = 'Virtual WANs'
metadata description = 'This module deploys a Virtual WAN.'

@description('Optional. Location where all resources will be created.')
param location string = resourceGroup().location

@description('Required. Name of the Virtual WAN.')
@minLength(1)
@maxLength(80)
param virtualWanName string

@description('Optional. The type of the Virtual WAN.')
@allowed([
  'Standard'
  'Basic'
])
param type string = 'Standard'

@description('Optional. True if branch to branch traffic is allowed.')
param allowBranchToBranchTraffic bool = true

@description('Allow VNet-to-VNet traffic.')
param vWanAllowVnetToVnetTraffic bool = true

@description('Disable VPN encryption.')
param vWanDisableVpnEncryption bool = false

@description('Optional. Tags of the resource.')
param tags object = {}

resource virtualWan 'Microsoft.Network/virtualWans@2025-05-01' = {
  name: virtualWanName
  location: location
  tags: tags
  properties: {
    type: type
    allowBranchToBranchTraffic: allowBranchToBranchTraffic
    allowVnetToVnetTraffic: vWanAllowVnetToVnetTraffic
    disableVpnEncryption: vWanDisableVpnEncryption
  }
}

@description('Outputs the resource name of the Virtual WAN.')
output virtualWanName string = virtualWan.name
@description('Outputs the Resource ID of the Virtual WAN.')
output virtualWanResourceId string = virtualWan.id
@description('Outputs the resource group the Virtual WAN was deployed into.')
output virtualWanResourceGroupName string = resourceGroup().name
@description('Outputs the location the Virtual WAN was deployed into.')
output virtualWanLocation string = virtualWan.location
