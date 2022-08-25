// This module manages the VNet integration for your Microsoft.Web/sites resource.
@description('The name of the appservice/webapp/logicapp/functionapp to VNet integrate.')
@minLength(2)
@maxLength(60)
param appServiceName string

@description('The resource id of the subnet where to integrate the appservice/webapp/logicapp/functionapp into.')
param vNetIntegrationSubnetResourceId string

@description('Upsert the VNet integration with the given parameters.')
resource vnetIntegration 'Microsoft.Web/sites/networkConfig@2021-03-01' = {
  name: '${appServiceName}/VirtualNetwork'
  properties: {
    subnetResourceId: vNetIntegrationSubnetResourceId
    swiftSupported: true
  }
}
