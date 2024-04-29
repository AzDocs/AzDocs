/*
.SYNOPSIS
Creating a Agent Pool of the Azure Container Registry type.
.DESCRIPTION
Creating an Agent Pool of the Azure Container Registry type with the given specs. ACR Task Agent Pool provides ACR Task (opens new window)execution in dedicated machine pools.
Task Agent Pools provide a.o VNet Support: Agent Pools may be assigned to Azure VNets, providing access the resources in the VNet (eg, Container Registry, Key Vault, Storage).
.EXAMPLE
<pre>
module agentpool 'br:contosoregistry.azurecr.io/containerregistry/registries/agentpools:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 47), 'acragentpool')
  scope: resourceGroup(acrResourceGroupName)
  params: {
    acrName: 'myacr145'
    location: location
  }
}
</pre>
<p>Creates an agentpool of the containerregistry type</p>
.LINKS
- [Bicep Microsoft.ContainerRegistry registries agentpools](https://learn.microsoft.com/en-us/azure/templates/microsoft.containerregistry/registries/agentpools?pivots=deployment-language-bicep)
*/

// ================================================= Parameters =================================================


@description('Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location.')
param location string = resourceGroup().location

@description('''
The tags to apply to this resource. This is an object with key/value pairs.
Example:
{
  FirstTag: myvalue
  SecondTag: another value
}
''')
param tags object = {}

@description('The name of the existing container registry.')
param acrName string

@description('The name of the agent pool')
param acrAgentPoolName string = 'private-pool'

@description('The resource id of the subnet the agent pool can be integrated in.')
param acrPoolSubnetId string = ''

@description('The number of virtual machines of the agent pool.')
param agentPoolMachineCount int = 1

@description('The type of OS for the agent machine')
@allowed([
  'Linux'
  'Windows'
])
param agentPoolOsType string = 'Linux'

@description('The tier of the agent machines of the agent pool.')
param agentPoolTier string = 'S1'


@description('The already existing container registry.')
resource acr 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' existing =  {
  name: acrName
}

resource acrPool 'Microsoft.ContainerRegistry/registries/agentPools@2019-06-01-preview' = {
  name: acrAgentPoolName
  location: location
  tags: tags
  parent: acr
  properties: {
    count: agentPoolMachineCount
    os: agentPoolOsType
    tier: agentPoolTier
    virtualNetworkSubnetResourceId: !empty(acrPoolSubnetId)? acrPoolSubnetId: null
  }
}
