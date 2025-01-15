@description('The name of the Spoke VNet. This is the VNet you are trying to attach to the central hub.')
@minLength(2)
@maxLength(64)
param spokeVNetName string

@description('The name of the resourcegroup where the Spoke VNet resides in. This is the VNet you are trying to attach to the central hub.')
@minLength(1)
@maxLength(90)
param spokeVNetResourceGroupName string

@description('The ID of the subscription where the Spoke VNet resides in. This is the VNet you are trying to attach to the central hub.')
@minLength(36)
@maxLength(36)
param spokeVNetSubscriptionId string

@description('The environment type of the subscription where the Spoke VNet resides in. For example: `dev`, `acc`, `prd`. This is the VNet you are trying to attach to the central hub.')
@minLength(3)
@maxLength(4)
param spokeEnvironmentType string

@description('The ID of the subscription where the Hub VNet resides in. This is the VNet which acts as the central Hub in the Hub/spoke model.')
@minLength(36)
@maxLength(36)
param hubVNetSubscriptionId string

@description('The name of the resourcegroup where the Hub VNet resides in. This is the VNet which acts as the central Hub in the Hub/spoke model.')
@minLength(1)
@maxLength(90)
param hubVNetResourceGroupName string

@description('The name of the Hub VNet. This is the VNet which acts as the central Hub in the Hub/spoke model.')
@minLength(2)
@maxLength(64)
param hubVNetName string

@description('An optional infix to add to the VNet name in the name of the peering on the remote site: vnet-purpose-<infix>-env')
@maxLength(2)
param hubSpokeVNetNameInfix string = ''

@description('Make sure to have a basename for the peering name for the spoke side. This is needed to avoid names which get too long without cutting the wrong information.')
var spokeBaseNameForPeeringName = take(replace(spokeVNetName, '-${spokeEnvironmentType}', ''), 34)
@description('Make sure to have a basename for the peering name for the hub side. This is needed to avoid names which get too long without cutting the wrong information.')
var hubVnetNameForPeeringName = take(hubVNetName, 37)

@description('Fetch the existing spoke vnet')
resource vNet 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  name: spokeVNetName
}

@description('Upsert the Spoke\'s VNet with the desired peering information.')
resource vNetPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-01-01' = {
  parent: vNet
  name: '${spokeBaseNameForPeeringName}-${spokeEnvironmentType}-to-${hubVnetNameForPeeringName}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: resourceId(hubVNetSubscriptionId, hubVNetResourceGroupName, 'Microsoft.Network/virtualNetworks', hubVNetName)
    }
  }
}

@description('Upsert the Hub\'s VNet with the desired peering information.')
module remotePeering 'virtualNetworkPeerings-remote.bicep' = {
  name: format('{0}-{1}', take('${deployment().name}', 50), 'remotePeering')
  scope: az.resourceGroup(hubVNetSubscriptionId, hubVNetResourceGroupName)
  params: {
    hubVNetName: hubVNetName
    spokeVNetName: spokeVNetName
    spokeVNetResourceGroupName: spokeVNetResourceGroupName
    spokeVNetSubscriptionId: spokeVNetSubscriptionId
    spokeEnvironmentType: spokeEnvironmentType
    spokeVNetNameInfix: hubSpokeVNetNameInfix
  }
  dependsOn: [
    vNet
    vNetPeering
  ]
}
