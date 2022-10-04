@description('Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location.')
param location string = resourceGroup().location

@description('''
The name of the recovery services vault. This vault should be pre-existing.
''')
@minLength(2)
@maxLength(50)
param recoveryServicesVaultName string

@description('''
The name of the backupstorage config in the recovery vault to create. This config determines properties for the storage type.
''')
param backupstorageconfigName string = 'vaultstorageconfig'

@description('''Opt in details of Cross Region Restore feature. Enable CRR works if the vault has not registered any backup instance yet.
The Cross Region Restore option allows you to restore data in a secondary, Azure paired region. You can use Cross Region Restore to conduct drills when there's an audit or compliance requirement.
You can also use it to restore the data if there's a disaster in the primary region.
''')
param enableCrossRegionRestore bool = false

@description('''
The tags to apply to this resource. This is an object with key/value pairs.
Example:
{
  FirstTag: myvalue
  SecondTag: another value
}
''')
param tags object = {}

@description('''Storage replication type for Recovery Services vault that determines how the storage is replicated.
Works if vault has not registered any backup instance yet.
Azure Backup automatically handles storage for the vault. You need to specify how that storage is replicated.
More info: https://docs.microsoft.com/en-us/azure/backup/backup-create-rs-vault
''')
@allowed([
  'LocallyRedundant'
  'GeoRedundant'
  'ZoneRedundant'
])
param vaultStorageType string = 'LocallyRedundant'

@description('The recovery services vault you want to configure the storage config for. Should be pre-existing.')
resource recoveryServicesVault 'Microsoft.RecoveryServices/vaults@2022-04-01' existing = {
  name: recoveryServicesVaultName
}

@description('the storage config for the recovery services vault.')
resource vaultstorageconfig 'Microsoft.RecoveryServices/vaults/backupstorageconfig@2022-02-01' = {
  parent: recoveryServicesVault
  location: location
  tags: tags
  name: backupstorageconfigName
  properties: {
    storageModelType: vaultStorageType
    crossRegionRestoreFlag: enableCrossRegionRestore
  }
}

@description('the resource id for the backupstorage config.')
output vaultStorageConfigResourceId string = vaultstorageconfig.id
