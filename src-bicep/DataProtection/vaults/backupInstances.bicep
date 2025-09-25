/*
.SYNOPSIS
Provisioning an Azure Data Protection Backup Instance
.DESCRIPTION
Provisioning an Azure Data Protection Backup Instance to protect specific resources with comprehensive configuration options.
.KEYFEATURES
- Support for multiple datasource types (Storage Accounts, Disks, PostgreSQL, MySQL, AKS)
- Flexible authentication mechanisms including secret store credentials
- Advanced identity configuration with user-assigned and system-assigned options
- Comprehensive policy parameter configuration
- DataStore parameters for operational, vault, and archive stores
- Kubernetes cluster backup with granular resource selection
- ADLS Blob backup with container-level configuration
- Resource Guard integration for enhanced security
- Validation options for backup instance creation
- Secret store integration with Azure Key Vault
.EXAMPLE
<pre>
module backupInstance 'br:contosoregistry.azurecr.io/dataprotection/vaults/backupinstances:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 48), 'backupinstances')
  params: {
    backupVaultName: backupVaultName
    backupInstanceName: backupInstanceName
    dataSourceInfo: {
      objectType: 'Datasource'
      resourceID: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Storage/storageAccounts/mystorageaccount'
      datasourceType: 'Microsoft.Storage/storageAccounts/blobServices'
      resourceType: 'Microsoft.Storage/storageAccounts'
      resourceLocation: location
    }
    policyInfo: {
      policyId: backupPolicyId
    }
    friendlyName: 'MyBackupInstance'
    validationType: 'ShallowValidation'
    tags: tags
  }
}
</pre>
<p>Provisioning an Azure Data Protection Backup Instance with advanced configuration and security features</p>
.LINKS
- [Bicep Microsoft.DataProtection/backupVaults/backupInstances@2025-07-01](https://learn.microsoft.com/en-us/azure/templates/microsoft.dataprotection/2025-07-01/backupvaults/backupinstances?pivots=deployment-language-bicep)
- [Microsoft Learn](https://learn.microsoft.com/en-us/azure/backup/backup-azure-dataprotection-use-rest-api-backup-blobs)
*/

// ================================================= Parameters =================================================

@description('The name of the backup vault')
@minLength(1)
param backupVaultName string

@description('The name of the backup instance')
@minLength(1)
param backupInstanceName string

@description('Credentials to use to authenticate with data source provider')
param datasourceAuthCredentials secretStoreBasedAuthCredentialsType?

@description('Data source information for the backup instance')
param dataSourceInfo datasourceInfoType

@description('Data source set information for the backup instance')
param dataSourceSetInfo datasourceSetInfoType?

@description('Friendly name for the backup instance')
param friendlyName string?

@description('Identity details for the backup instance')
param identityDetails identityDetailsType?

@description('Object type identifier for the backup instance')
param objectType string = 'BackupInstance'

@description('Policy information for the backup instance')
param policyInfo policyInfoType

@description('Resource Guard operation requests on which LAC check will be performed')
param resourceGuardOperationRequests string[] = []

@description('Tags to apply to the backup instance')
param tags object = {}

@description('Specifies the type of validation')
@allowed([
  'DeepValidation'
  'ShallowValidation'
])
param validationType string = 'ShallowValidation'

// ================================================= Custom Types ==============================================

@description('Identity details configuration for backup instance')
type identityDetailsType = {
  @description('ARM URL for User Assigned Identity')
  userAssignedIdentityArmUrl: string?

  @description('Specifies if the BI is protected by System Identity')
  useSystemAssignedIdentity: bool?
}

@description('Base resource properties')
type baseResourcePropertiesType = {
  @description('Type of the specific object - used for deserializing')
  objectType: 'DefaultResourceProperties'
}

@description('Datasource configuration')
type datasourceInfoType = {
  @description('DatasourceType of the resource')
  datasourceType: string?

  @description('Type of Datasource object, used to initialize the right inherited type')
  objectType: 'Datasource'

  @description('Full ARM ID of the resource. For azure resources, this is ARM ID. For non azure resources, this will be the ID created by backup service via Fabric/Vault.')
  resourceID: string

  @description('Location of datasource')
  resourceLocation: string?

  @description('Unique identifier of the resource in the context of parent')
  resourceName: string?

  @description('Properties specific to data source')
  resourceProperties: baseResourcePropertiesType?

  @description('Resource Type of Datasource')
  resourceType: string?

  @description('Uri of the resource')
  resourceUri: string?
}

@description('Datasource set configuration')
type datasourceSetInfoType = {
  @description('DatasourceType of the resource')
  datasourceType: string?

  @description('Type of Datasource object, used to initialize the right inherited type')
  objectType: 'DatasourceSet'

  @description('Full ARM ID of the resource. For azure resources, this is ARM ID. For non azure resources, this will be the ID created by backup service via Fabric/Vault.')
  resourceID: string

  @description('Location of datasource')
  resourceLocation: string?

  @description('Unique identifier of the resource in the context of parent')
  resourceName: string?

  @description('Properties specific to data source set')
  resourceProperties: baseResourcePropertiesType?

  @description('Resource Type of Datasource')
  resourceType: string?

  @description('Uri of the resource')
  resourceUri: string?
}

@description('Policy information for backup instance')
type policyInfoType = {
  @description('Policy ID')
  policyId: string

  @description('Policy parameters for the backup instance')
  policyParameters: policyParametersType?
}

@description('Policy parameters configuration for backup instance')
type policyParametersType = {
  @description('Gets or sets the DataStore Parameters - array of DataStore parameter objects')
  dataStoreParametersList: dataStoreParametersType[]?

  @description('Gets or sets the Backup Data Source Parameters - array of BackupDatasource parameter objects')
  backupDatasourceParametersList: backupDatasourceParametersType[]?
}

@description('DataStore parameters configuration')
type dataStoreParametersType = {
  @description('Type of datasource object, used to initialize the right inherited type')
  objectType: 'AzureOperationalStoreParameters'

  @description('type of datastore; Operational/Vault/Archive')
  dataStoreType: 'OperationalStore' | 'VaultStore' | 'ArchiveStore'

  @description('Gets or sets the Snapshot Resource Group Uri')
  resourceGroupId: string?
}

@description('Namespaced name resource for Kubernetes backup hook references')
type namespacedNameResourceType = {
  @description('Name of the resource')
  name: string?

  @description('Namespace of the resource')
  namespace: string?
}

@description('ADLS Blob backup datasource parameters')
type adlsBlobBackupDatasourceParametersType = {
  @description('Type of the specific object - used for deserializing')
  objectType: 'AdlsBlobBackupDatasourceParameters'

  @description('List of containers to be backed up during configuration of backup of blobs')
  containersList: string[]
}

@description('Kubernetes cluster backup datasource parameters')
type kubernetesClusterBackupDatasourceParametersType = {
  @description('Type of the specific object - used for deserializing')
  objectType: 'KubernetesClusterBackupDatasourceParameters'

  @description('Volume snapshot property')
  snapshotVolumes: bool

  @description('Include cluster scope resources')
  includeClusterScopeResources: bool

  @description('Namespaces to include')
  includedNamespaces: string[]?

  @description('Namespaces to exclude')
  excludedNamespaces: string[]?

  @description('Resource types to include')
  includedResourceTypes: string[]?

  @description('Resource types to exclude')
  excludedResourceTypes: string[]?

  @description('Volume types to include during backup - AzureDisk or AzureFileShareSMB')
  includedVolumeTypes: ('AzureDisk' | 'AzureFileShareSMB')[]?

  @description('Label selectors')
  labelSelectors: string[]?

  @description('Backup hook references')
  backupHookReferences: namespacedNameResourceType[]?
}

@discriminator('objectType')
@description('Union type for backup datasource parameters - can be either ADLS Blob or Kubernetes cluster parameters')
type backupDatasourceParametersType =
  | adlsBlobBackupDatasourceParametersType
  | kubernetesClusterBackupDatasourceParametersType

@description('Secret store based auth credentials')
type secretStoreBasedAuthCredentialsType = {
  @description('Type of the specific object - used for deserializing')
  objectType: 'SecretStoreBasedAuthCredentials'

  @description('Secret store resource configuration')
  secretStoreResource: secretStoreResourceType?
}

@description('Secret store resource configuration')
type secretStoreResourceType = {
  @description('Uri to get to the resource')
  uri: string?

  @description('Gets or sets the type of secret store')
  secretStoreType: 'AzureKeyVault' | 'Invalid'

  @description('Gets or sets value stored in secret store resource')
  value: string?
}

// ================================================= Resources =================================================

resource backupVault 'Microsoft.DataProtection/backupVaults@2025-07-01' existing = {
  name: backupVaultName
}

resource backupInstance 'Microsoft.DataProtection/backupVaults/backupInstances@2025-07-01' = {
  parent: backupVault
  name: backupInstanceName
  tags: tags
  properties: union(
    {
      dataSourceInfo: dataSourceInfo
      friendlyName: friendlyName
      objectType: objectType
      policyInfo: policyInfo
      resourceGuardOperationRequests: resourceGuardOperationRequests
      validationType: validationType
    },
    datasourceAuthCredentials != null ? { datasourceAuthCredentials: datasourceAuthCredentials } : {},
    dataSourceSetInfo != null ? { dataSourceSetInfo: dataSourceSetInfo } : {},
    identityDetails != null ? { identityDetails: identityDetails } : {}
  )
}

// ================================================= Outputs =================================================
@description('The resource ID of the backup instance')
output backupInstanceId string = backupInstance.id

@description('The name of the backup instance')
output backupInstanceName string = backupInstance.name

@description('The resource ID of the parent backup vault')
output backupVaultId string = backupVault.id
