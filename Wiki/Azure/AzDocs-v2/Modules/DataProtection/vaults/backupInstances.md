# backupInstances

Target Scope: resourceGroup

## User Defined Types
| Name | Type | Discriminator | Description
| -- |  -- | -- | -- |
| <a id="identityDetailsType">identityDetailsType</a>  | <pre>{<br>&nbsp;&nbsp;&nbsp;@description('ARM URL for User Assigned Identity')<br>&nbsp;&nbsp;&nbsp;userAssignedIdentityArmUrl: string?<br><br>&nbsp;&nbsp;&nbsp;@description('Specifies if the BI is protected by System Identity')<br>&nbsp;&nbsp;&nbsp;useSystemAssignedIdentity: bool?<br>}<br></pre> |  | Identity details configuration for backup instance | 
| <a id="baseResourcePropertiesType">baseResourcePropertiesType</a>  | <pre>{<br>&nbsp;&nbsp;&nbsp;@description('Type of the specific object - used for deserializing')<br>&nbsp;&nbsp;&nbsp;objectType: 'DefaultResourceProperties'<br>}<br></pre> |  | Base resource properties | 
| <a id="datasourceInfoType">datasourceInfoType</a>  | <pre>{<br>&nbsp;&nbsp;&nbsp;@description('DatasourceType of the resource')<br>&nbsp;&nbsp;&nbsp;datasourceType: string?<br><br>&nbsp;&nbsp;&nbsp;@description('Type of Datasource object, used to initialize the right inherited type')<br>&nbsp;&nbsp;&nbsp;objectType: 'Datasource'<br><br>&nbsp;&nbsp;&nbsp;@description('Full ARM ID of the resource. For azure resources, this is ARM ID. For non azure resources, this will be the ID created by backup service via Fabric/Vault.')<br>&nbsp;&nbsp;&nbsp;resourceID: string<br><br>&nbsp;&nbsp;&nbsp;@description('Location of datasource')<br>&nbsp;&nbsp;&nbsp;resourceLocation: string?<br><br>&nbsp;&nbsp;&nbsp;@description('Unique identifier of the resource in the context of parent')<br>&nbsp;&nbsp;&nbsp;resourceName: string?<br><br>&nbsp;&nbsp;&nbsp;@description('Properties specific to data source')<br>&nbsp;&nbsp;&nbsp;resourceProperties: baseResourcePropertiesType?<br><br>&nbsp;&nbsp;&nbsp;@description('Resource Type of Datasource')<br>&nbsp;&nbsp;&nbsp;resourceType: string?<br><br>&nbsp;&nbsp;&nbsp;@description('Uri of the resource')<br>&nbsp;&nbsp;&nbsp;resourceUri: string?<br>}<br></pre> |  | Datasource configuration | 
| <a id="datasourceSetInfoType">datasourceSetInfoType</a>  | <pre>{<br>&nbsp;&nbsp;&nbsp;@description('DatasourceType of the resource')<br>&nbsp;&nbsp;&nbsp;datasourceType: string?<br><br>&nbsp;&nbsp;&nbsp;@description('Type of Datasource object, used to initialize the right inherited type')<br>&nbsp;&nbsp;&nbsp;objectType: 'DatasourceSet'<br><br>&nbsp;&nbsp;&nbsp;@description('Full ARM ID of the resource. For azure resources, this is ARM ID. For non azure resources, this will be the ID created by backup service via Fabric/Vault.')<br>&nbsp;&nbsp;&nbsp;resourceID: string<br><br>&nbsp;&nbsp;&nbsp;@description('Location of datasource')<br>&nbsp;&nbsp;&nbsp;resourceLocation: string?<br><br>&nbsp;&nbsp;&nbsp;@description('Unique identifier of the resource in the context of parent')<br>&nbsp;&nbsp;&nbsp;resourceName: string?<br><br>&nbsp;&nbsp;&nbsp;@description('Properties specific to data source set')<br>&nbsp;&nbsp;&nbsp;resourceProperties: baseResourcePropertiesType?<br><br>&nbsp;&nbsp;&nbsp;@description('Resource Type of Datasource')<br>&nbsp;&nbsp;&nbsp;resourceType: string?<br><br>&nbsp;&nbsp;&nbsp;@description('Uri of the resource')<br>&nbsp;&nbsp;&nbsp;resourceUri: string?<br>}<br></pre> |  | Datasource set configuration | 
| <a id="policyInfoType">policyInfoType</a>  | <pre>{<br>&nbsp;&nbsp;&nbsp;@description('Policy ID')<br>&nbsp;&nbsp;&nbsp;policyId: string<br><br>&nbsp;&nbsp;&nbsp;@description('Policy parameters for the backup instance')<br>&nbsp;&nbsp;&nbsp;policyParameters: policyParametersType?<br>}<br></pre> |  | Policy information for backup instance | 
| <a id="policyParametersType">policyParametersType</a>  | <pre>{<br>&nbsp;&nbsp;&nbsp;@description('Gets or sets the DataStore Parameters - array of DataStore parameter objects')<br>&nbsp;&nbsp;&nbsp;dataStoreParametersList: dataStoreParametersType[]?<br><br>&nbsp;&nbsp;&nbsp;@description('Gets or sets the Backup Data Source Parameters - array of BackupDatasource parameter objects')<br>&nbsp;&nbsp;&nbsp;backupDatasourceParametersList: backupDatasourceParametersType[]?<br>}<br></pre> |  | Policy parameters configuration for backup instance | 
| <a id="dataStoreParametersType">dataStoreParametersType</a>  | <pre>{<br>&nbsp;&nbsp;&nbsp;@description('Type of datasource object, used to initialize the right inherited type')<br>&nbsp;&nbsp;&nbsp;objectType: 'AzureOperationalStoreParameters'<br><br>&nbsp;&nbsp;&nbsp;@description('type of datastore; Operational/Vault/Archive')<br>&nbsp;&nbsp;&nbsp;dataStoreType: 'OperationalStore' &#124; 'VaultStore' &#124; 'ArchiveStore'<br><br>&nbsp;&nbsp;&nbsp;@description('Gets or sets the Snapshot Resource Group Uri')<br>&nbsp;&nbsp;&nbsp;resourceGroupId: string?<br>}<br></pre> |  | DataStore parameters configuration | 
| <a id="namespacedNameResourceType">namespacedNameResourceType</a>  | <pre>{<br>&nbsp;&nbsp;&nbsp;@description('Name of the resource')<br>&nbsp;&nbsp;&nbsp;name: string?<br><br>&nbsp;&nbsp;&nbsp;@description('Namespace of the resource')<br>&nbsp;&nbsp;&nbsp;namespace: string?<br>}<br></pre> |  | Namespaced name resource for Kubernetes backup hook references | 
| <a id="adlsBlobBackupDatasourceParametersType">adlsBlobBackupDatasourceParametersType</a>  | <pre>{<br>&nbsp;&nbsp;&nbsp;@description('Type of the specific object - used for deserializing')<br>&nbsp;&nbsp;&nbsp;objectType: 'AdlsBlobBackupDatasourceParameters'<br><br>&nbsp;&nbsp;&nbsp;@description('List of containers to be backed up during configuration of backup of blobs')<br>&nbsp;&nbsp;&nbsp;containersList: string[]<br>}<br></pre> |  | ADLS Blob backup datasource parameters | 
| <a id="kubernetesClusterBackupDatasourceParametersType">kubernetesClusterBackupDatasourceParametersType</a>  | <pre>{<br>&nbsp;&nbsp;&nbsp;@description('Type of the specific object - used for deserializing')<br>&nbsp;&nbsp;&nbsp;objectType: 'KubernetesClusterBackupDatasourceParameters'<br><br>&nbsp;&nbsp;&nbsp;@description('Volume snapshot property')<br>&nbsp;&nbsp;&nbsp;snapshotVolumes: bool<br><br>&nbsp;&nbsp;&nbsp;@description('Include cluster scope resources')<br>&nbsp;&nbsp;&nbsp;includeClusterScopeResources: bool<br><br>&nbsp;&nbsp;&nbsp;@description('Namespaces to include')<br>&nbsp;&nbsp;&nbsp;includedNamespaces: string[]?<br><br>&nbsp;&nbsp;&nbsp;@description('Namespaces to exclude')<br>&nbsp;&nbsp;&nbsp;excludedNamespaces: string[]?<br><br>&nbsp;&nbsp;&nbsp;@description('Resource types to include')<br>&nbsp;&nbsp;&nbsp;includedResourceTypes: string[]?<br><br>&nbsp;&nbsp;&nbsp;@description('Resource types to exclude')<br>&nbsp;&nbsp;&nbsp;excludedResourceTypes: string[]?<br><br>&nbsp;&nbsp;&nbsp;@description('Volume types to include during backup - AzureDisk or AzureFileShareSMB')<br>&nbsp;&nbsp;&nbsp;includedVolumeTypes: ('AzureDisk' &#124; 'AzureFileShareSMB')[]?<br><br>&nbsp;&nbsp;&nbsp;@description('Label selectors')<br>&nbsp;&nbsp;&nbsp;labelSelectors: string[]?<br><br>&nbsp;&nbsp;&nbsp;@description('Backup hook references')<br>&nbsp;&nbsp;&nbsp;backupHookReferences: namespacedNameResourceType[]?<br>}<br></pre> |  | Kubernetes cluster backup datasource parameters | 
| <a id="backupDatasourceParametersType">backupDatasourceParametersType</a>  | <pre>&nbsp;&nbsp;&nbsp;&#124; adlsBlobBackupDatasourceParametersType<br>&nbsp;&nbsp;&nbsp;&#124; kubernetesClusterBackupDatasourceParametersType<br></pre> | objectType | Union type for backup datasource parameters - can be either ADLS Blob or Kubernetes cluster parameters | 
| <a id="secretStoreBasedAuthCredentialsType">secretStoreBasedAuthCredentialsType</a>  | <pre>{<br>&nbsp;&nbsp;&nbsp;@description('Type of the specific object - used for deserializing')<br>&nbsp;&nbsp;&nbsp;objectType: 'SecretStoreBasedAuthCredentials'<br><br>&nbsp;&nbsp;&nbsp;@description('Secret store resource configuration')<br>&nbsp;&nbsp;&nbsp;secretStoreResource: secretStoreResourceType?<br>}<br></pre> |  | Secret store based auth credentials | 
| <a id="secretStoreResourceType">secretStoreResourceType</a>  | <pre>{<br>&nbsp;&nbsp;&nbsp;@description('Uri to get to the resource')<br>&nbsp;&nbsp;&nbsp;uri: string?<br><br>&nbsp;&nbsp;&nbsp;@description('Gets or sets the type of secret store')<br>&nbsp;&nbsp;&nbsp;secretStoreType: 'AzureKeyVault' &#124; 'Invalid'<br><br>&nbsp;&nbsp;&nbsp;@description('Gets or sets value stored in secret store resource')<br>&nbsp;&nbsp;&nbsp;value: string?<br>}<br></pre> |  | Secret store resource configuration | 

## Synopsis
Provisioning an Azure Data Protection Backup Instance

## Description
Provisioning an Azure Data Protection Backup Instance to protect specific resources with comprehensive configuration options.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| backupVaultName | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | The name of the backup vault |
| backupInstanceName | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | The name of the backup instance |
| datasourceAuthCredentials | [secretStoreBasedAuthCredentialsType](#secretStoreBasedAuthCredentialsType)? | <input type="checkbox" checked> | None | <pre></pre> | Credentials to use to authenticate with data source provider |
| dataSourceInfo | [datasourceInfoType](#datasourceInfoType) | <input type="checkbox" checked> | None | <pre></pre> | Data source information for the backup instance |
| dataSourceSetInfo | [datasourceSetInfoType](#datasourceSetInfoType)? | <input type="checkbox" checked> | None | <pre></pre> | Data source set information for the backup instance |
| friendlyName | string? | <input type="checkbox" checked> | None | <pre></pre> | Friendly name for the backup instance |
| identityDetails | [identityDetailsType](#identityDetailsType)? | <input type="checkbox" checked> | None | <pre></pre> | Identity details for the backup instance |
| objectType | string | <input type="checkbox"> | None | <pre>'BackupInstance'</pre> | Object type identifier for the backup instance |
| policyInfo | [policyInfoType](#policyInfoType) | <input type="checkbox" checked> | None | <pre></pre> | Policy information for the backup instance |
| resourceGuardOperationRequests | string[] | <input type="checkbox"> | None | <pre>[]</pre> | Resource Guard operation requests on which LAC check will be performed |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | Tags to apply to the backup instance |
| validationType | string | <input type="checkbox"> | `'DeepValidation'` or `'ShallowValidation'` | <pre>'ShallowValidation'</pre> | Specifies the type of validation |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| backupInstanceId | string | The resource ID of the backup instance |
| backupInstanceName | string | The name of the backup instance |
| backupVaultId | string | The resource ID of the parent backup vault |

## Examples
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

## Links
- [Bicep Microsoft.DataProtection/backupVaults/backupInstances@2025-07-01](https://learn.microsoft.com/en-us/azure/templates/microsoft.dataprotection/2025-07-01/backupvaults/backupinstances?pivots=deployment-language-bicep)<br>
- [Microsoft Learn](https://learn.microsoft.com/en-us/azure/backup/backup-azure-dataprotection-use-rest-api-backup-blobs)
