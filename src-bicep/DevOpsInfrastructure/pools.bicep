/*
.SYNOPSIS
Creating a Managed DevOps pool.
.DESCRIPTION
This module creates a managed devops pool with the given specs. If you want to use with a BYO NetworkProfile, the App 'DevOpsInfrastructure' needs to have Network rights on the subnet.
The account that runs the creation of this pool needs to have DevOps Organisation Pool Administrator rights otherwise you will receive the error: Failed to provision agent pool.
See also the [quickstart](https://learn.microsoft.com/en-us/azure/devops/managed-devops-pools/quickstart-azure-portal?view=azure-devops) for prerequisites.
.EXAMPLE
<pre>
module devopspools 'br:contosoregistry.azurecr.io/devopsinfrastructure/pools:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 52), 'mandevpools')
  params: {
    managedDevOpsPoolName: mydevopspool
    devCenterProjectName: mydevcenterproject
    azureDevOpsOrganizationName: myazuredevops
  }
}
</pre>
<p>Creates a devops pool with the given specs</p>
.LINKS
- [ARM Microsoft.DevOpsInfrastructure](https://learn.microsoft.com/en-us/azure/devops/managed-devops-pools/quickstart-arm-template?view=azure-devops)
*/
// ===================================== Parameters =====================================
@description('The location of the resource. Defaults to the resourcegroups location.')
param location string = resourceGroup().location

@description('The name of the managed devops pool to upsert.')
param managedDevOpsPoolName string

@description('The name of the existing Dev Center project.')
param devCenterProjectName string

@description('The name of the resource group of the existing virtual network that has the subnet to integrate the devops pool in.')
param virtualNetworkResourceGroupName string = resourceGroup().name

@description('The name of the existing virtual network that has the subnet to integrate the devops pool in.')
param virtualNetworkName string = ''

@description('The name of the existing subnet to integrate the devops pool in. This subnet needs to be delegated to Microsoft.DevOpsInfrastructure/pools.')
param subnetName string = ''

@description('The name of the existing user assigned managed identity.')
param userAssignedManagedIdentityName string = ''

@description('''
The images to use for the pool. See for more info: [information](https://learn.microsoft.com/en-us/azure/devops/managed-devops-pools/configure-images?view=azure-devops&tabs=azure-portal).
Example:
[
  {
    resourceId: '/Subscriptions/${az.subscription().subscriptionId}/Providers/Microsoft.Compute/Locations/${location}/Publishers/canonical/ArtifactTypes/VMImage/Offers/0001-com-ubuntu-server-focal/Skus/20_04-lts-gen2/versions/latest'
    aliases: []
    buffer: '*'
  }
  {
    resourceId: '/subscriptions/${remoteSubscriptionId}/resourceGroups/${remoteResourceGroupName}/providers/Microsoft.Compute/galleries/${galleryName}/images/ubuntu22/versions/latest'
    aliases: []
    buffer: '*'
  }
  {
    aliases: [
      'ubuntu-22.04'
    ]
    buffer: '*'
    wellKnownImageName: 'ubuntu-22.04/latest'
  }
]
''')
param managedDevOpsPoolImages array = [
  {
    aliases: [
      'ubuntu-22.04'
    ]
    buffer: '*'
    wellKnownImageName: 'ubuntu-22.04/latest'
  }
  {
    aliases: ['windows-2022', 'windows-latest']
    buffer: '*'
    wellKnownImageName: 'windows-2022/latest'
  }
]

@description('The permissions profile for the AzureDevOps pool in the project.')
@allowed([
  'Inherit'
  'CreatorOnly'
  'SpecificAccoumnts'
])
param azureDevOpsPoolsPermissionsProfile string = 'Inherit'

@description('The interactive mode of the pool. Service mode means the pool runs as a service account. Interactive mode means the pool runs as an interactive account.')
@allowed([
  'Service'
  'Interactive'
])
param poolInteractiveMode string = 'Service'

@description('Future keyvault configuration for the pool. Currently it is not used.')
param keyvaultConfiguration object = {
  keyExportable: false
  observedCertificates: []
}

@description('The sku name for the Azure VM used in the pool. See for more info: [information](https://learn.microsoft.com/en-us/azure/devops/managed-devops-pools/prerequisites?view=azure-devops&tabs=azure-portal#review-managed-devops-pools-quotas)')
param agentSkuName string = 'Standard_D2ads_v5'

@description('The storage account name for the OS disk of the pool.')
@allowed([
  'Premium'
  'Standard'
  'StandardSSD'
])
param osDiskStorageAccountType string = 'Standard'

@description('''
A list of empty data disks to attach. Avoid drive letters A, C, D or E.
Example:
[
  {
      "diskSizeGiB": 1,
      "storageAccountType": "Premium_LRS",
      "driveLetter": "F"
  }
]
''')
param dataDisks array = []

@description('''
The kind of the agent scaling profile.
Example:
{
  maxAgentLifetime: '7.00:00:00'
  gracePeriodTimeSpan: '00:30:00'
  kind: 'Stateful'
  resourcePredictionsProfile: {
    kind: 'Automatic'
    predictionPreference: 'MostCostEffective'
  }
}
''')
param agentScalingProfile object = {
  kind: 'Stateless' //Fresh Agent every time
  resourcePredictionsProfile: {
    predictionPreference: 'MostCostEffective' //The balance between cost and performance for standby agents.
    kind: 'Automatic' //Standby agent mode
  }
}

@description('The name of the initial existing Azure DevOps to configure the pools in.')
param azureDevOpsOrganizationName string

@description('The AzureDevOps projects to add the pool to. Empty array means all projects.')
param azureDevOpsProjects array = []

@description('Defines how many VM resources can be created at any given time.')
@minValue(1)
@maxValue(10000)
param maximumConcurrencyPoolSize int = 2

@description('''
How many pools can run in parallel when using multiple AzureDevOps organizations. 
Also the sum of parallelism for all organizations must equal the max pool size (maximumConcurrencyPoolSize).
''')
param organizationProfileOrganizationsParallelism int = 1

type additionalAzureDevOpsOrganizationsType = {
  url: string
  projects: []?
  parallelism: int?
}[]
@description('''
The additional AzureDevOps organizations to add the pool to.
Example:
[
  {
    url: 'https://dev.azure.com/azureDevOpsOrganizationName'
    projects: []
    parallelism: 1 //dependent on the total number of organizations
  }
]
''')
param additionalAzureDevOpsOrganizations additionalAzureDevOpsOrganizationsType = []

// ===================================== Variables =====================================
@description('The initial AzureDevOps organization to configure the pool in.')
var initialAzureDevOpsOrganization = [
  {
    url: 'https://dev.azure.com/${azureDevOpsOrganizationName}'
    projects: azureDevOpsProjects
    parallelism: organizationProfileOrganizationsParallelism //dependent on the total number of organizations
  }
]

@description('The total of AzureDevOps organizations to add the pool to.')
var azureDevOpsOrganizations = union(initialAzureDevOpsOrganization, additionalAzureDevOpsOrganizations)

@description('The resourceId of the subnet to integrate the devops pool in. This subnet needs to be delegated to Microsoft.DevOpsInfrastructure/pools.')
var subnetResourceId = (empty(virtualNetworkName) || empty(subnetName))
  ? ''
  : resourceId(
      virtualNetworkResourceGroupName,
      'Microsoft.Network/virtualNetworks/subnets',
      virtualNetworkName,
      subnetName
    )

@description('The resourceId of the existing user assigned managed identity.')
var userAssignedIdentity = (!empty(userAssignedManagedIdentityName))
  ? resourceId('Microsoft.ManagedIdentity/userAssignedIdentities', userAssignedManagedIdentityName)
  : ''

// ================================================= Resources =================================================
resource devCenterProject 'Microsoft.DevCenter/projects@2024-02-01' existing = {
  name: devCenterProjectName
}

resource managedDevOpsPool 'Microsoft.DevOpsInfrastructure/pools@2024-04-04-preview' = {
  name: managedDevOpsPoolName
  location: location
  tags: {}
  identity: !empty(userAssignedIdentity)
    ? {
        type: 'UserAssigned'
        userAssignedIdentities: {
          '${userAssignedIdentity}': {}
        }
      }
    : {
        type: 'None'
      }
  properties: {
    agentProfile: agentScalingProfile
    devCenterProjectResourceId: devCenterProject.id
    fabricProfile: {
      sku: {
        name: agentSkuName
      }
      images: managedDevOpsPoolImages
      osProfile: {
        secretsManagementSettings: keyvaultConfiguration
        logonType: poolInteractiveMode
      }
      storageProfile: {
        osDiskStorageAccountType: osDiskStorageAccountType
        dataDisks: dataDisks
      }
      networkProfile: empty(subnetResourceId)
        ? null
        : {
            subnetId: subnetResourceId
          }
      kind: 'Vmss'
    }
    maximumConcurrency: maximumConcurrencyPoolSize
    organizationProfile: {
      organizations: azureDevOpsOrganizations
      permissionProfile: {
        kind: azureDevOpsPoolsPermissionsProfile
      }
      kind: 'AzureDevOps' // future: also 'GitHub'
    }
  }
}
