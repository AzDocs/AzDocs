@description('Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location.')
param location string = resourceGroup().location

@description('The name of the resource you want to backup. Should be pre-existing.')
param resourceName string

@description('''
The resourceId for the resource to backup. Should be pre-existing.
Example: resourceId(vmResourceGroup, 'Microsoft.Compute/virtualMachines', vmName)
''')
param targetResourceId string

@description('''
The name of the recovery services vault. This should be pre-existing.
''')
@minLength(2)
@maxLength(50)
param recoveryServicesVaultName string

@description('The name of the backup container\'s fabric.')
param backupFabric string = 'Azure'

@description('the resource group where the resources you want to backup are in. Should be pre-existing.')
param targetResourceResourceGroupName string

@description('The container type for the type of resource you want to backup')
@allowed([
  'AzureBackupServerContainer'
  'AzureSqlContainer'
  'GenericContainer'
  'Microsoft.Compute/virtualMachines'
  'SQLAGWorkLoadContainer'
  'StorageContainer'
  'VMAppContainer'
  'Windows'
])
param containerType string = 'Microsoft.Compute/virtualMachines'

@description('The id for the backup policy in the recovery vault te protected item is going to use. The should be pre-existing.')
param backupPolicyId string

@description('the type of protection container for the type of resources you want to create a protected item for in the recovery services vault.')
param protectionContainer string = 'iaasvmcontainer;iaasvmcontainerv2;${targetResourceResourceGroupName};${resourceName}'

@description('the type of resource you want to create a protected item for in the protection container type.')
param protectedItem string = 'vm;iaasvmcontainerv2;${resourceGroup().name};${resourceName}'

@description('The properties for the resource protectedItems in the protectioncontainer you want to create')
param protectedItemsProperties object = {
  protectedItemType: containerType
  policyId: backupPolicyId
  sourceResourceId: targetResourceId
}

@description('The recovery services vault that you want to create the protected item in. Should be pre-existing.')
resource recoveryServicesVault 'Microsoft.RecoveryServices/vaults@2022-04-01' existing = {
  name: recoveryServicesVaultName
}

@description('Put the resource to backup into a protected item')
resource protectedItems 'Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers/protectedItems@2022-06-01-preview' = {
  name: '${recoveryServicesVaultName}/${backupFabric}/${protectionContainer}/${protectedItem}'
  location: location
  properties: protectedItemsProperties
  dependsOn: [
    recoveryServicesVault
  ]
}

@description('the resource id for the protected items resource')
output protectedItemsResourceId string = protectedItems.id
