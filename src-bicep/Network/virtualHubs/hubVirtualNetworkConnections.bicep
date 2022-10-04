@description('The name of the VirtualHub')
@minLength(1) // TODO: verify. Based this off of the "virtualWan" resource type. Can't find any naming restrictions on a "virtualHubs" resourcetype.
@maxLength(80) // TODO: verify. Based this off of the "virtualWan" resource type. Can't find any naming restrictions on a "virtualHubs" resourcetype.
param virtualHubName string

@description('The ID of the subscription where the target (to be attached) VNet is located')
@minLength(36)
@maxLength(36)
param targetSubscriptionId string

@description('The name of the resourcegroup where the target (to be attached) VNet is located')
@minLength(1)
@maxLength(90)
param targetResourceGroupName string

@description('The name of the target (to be attached) VNet')
@minLength(2)
@maxLength(64)
param targetVNetName string

@description('The VirtualHub routetable resourceId. Defaults to the `defaultRouteTable` table.')
param virtualHubRouteResourceId string = '/subscriptions/${az.subscription().subscriptionId}/resourceGroups/${az.resourceGroup().name}/providers/Microsoft.Network/virtualHubs/${virtualHubName}/hubRouteTables/defaultRouteTable'

@description('Upsert the virtualHub Connection')
resource vnetConnection 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2022-01-01' = {
  name: '${virtualHubName}/${targetVNetName}'
  properties: {
    enableInternetSecurity: true
    remoteVirtualNetwork: {
      id: resourceId(targetSubscriptionId, targetResourceGroupName, 'Microsoft.Network/virtualNetworks', targetVNetName)
    }
    routingConfiguration: {
      associatedRouteTable: {
        id: virtualHubRouteResourceId
      }
      propagatedRouteTables: {
        ids: [
          {
            id: virtualHubRouteResourceId
          }
        ]
        labels: [
          'default'
        ]
      }
      vnetRoutes: {
        staticRoutes: []
      }
    }
  }
}
