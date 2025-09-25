# backupInstances

Target Scope: resourceGroup

## User Defined Types
| Name | Type | Discriminator | Description
| -- |  -- | -- | -- |
| <a id="identityDetailsType">identityDetailsType</a>  | <pre>{</pre> |  | Identity details configuration for backup instance | 
| <a id="baseResourcePropertiesType">baseResourcePropertiesType</a>  | <pre>{</pre> |  | Base resource properties | 
| <a id="datasourceInfoType">datasourceInfoType</a>  | <pre>{</pre> |  | Datasource configuration | 
| <a id="datasourceSetInfoType">datasourceSetInfoType</a>  | <pre>{</pre> |  | Datasource set configuration | 
| <a id="policyInfoType">policyInfoType</a>  | <pre>{</pre> |  | Policy information for backup instance | 
| <a id="policyParametersType">policyParametersType</a>  | <pre>{</pre> |  | Policy parameters configuration for backup instance | 
| <a id="dataStoreParametersType">dataStoreParametersType</a>  | <pre>{</pre> |  | DataStore parameters configuration | 
| <a id="namespacedNameResourceType">namespacedNameResourceType</a>  | <pre>{</pre> |  | Namespaced name resource for Kubernetes backup hook references | 
| <a id="adlsBlobBackupDatasourceParametersType">adlsBlobBackupDatasourceParametersType</a>  | <pre>{</pre> |  | ADLS Blob backup datasource parameters | 
| <a id="kubernetesClusterBackupDatasourceParametersType">kubernetesClusterBackupDatasourceParametersType</a>  | <pre>{</pre> |  | Kubernetes cluster backup datasource parameters | 
| <a id="backupDatasourceParametersType">backupDatasourceParametersType</a>  | <pre></pre> | objectType | Union type for backup datasource parameters - can be either ADLS Blob or Kubernetes cluster parameters | 
| <a id="secretStoreBasedAuthCredentialsType">secretStoreBasedAuthCredentialsType</a>  | <pre>{</pre> |  | Secret store based auth credentials | 
| <a id="secretStoreResourceType">secretStoreResourceType</a>  | <pre>{</pre> |  | Secret store resource configuration | 

## Synopsis
Provisioning an Azure Data Protection Backup Instance

## Description
Provisioning an Azure Data Protection Backup Instance to protect specific resources with comprehensive configuration options.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| backupVaultName | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | The name of the backup vault |
| backupInstanceName | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | The name of the backup instance |
| datasourceAuthCredentials | secretStoreBasedAuthCredentialsType? | <input type="checkbox" checked> | None | <pre></pre> | Credentials to use to authenticate with data source provider |
| dataSourceInfo | datasourceInfoType | <input type="checkbox" checked> | None | <pre></pre> | Data source information for the backup instance |
| dataSourceSetInfo | datasourceSetInfoType? | <input type="checkbox" checked> | None | <pre></pre> | Data source set information for the backup instance |
| friendlyName | string? | <input type="checkbox" checked> | None | <pre></pre> | Friendly name for the backup instance |
| identityDetails | identityDetailsType? | <input type="checkbox" checked> | None | <pre></pre> | Identity details for the backup instance |
| objectType | string | <input type="checkbox"> | None | <pre>'BackupInstance'</pre> | Object type identifier for the backup instance |
| policyInfo | policyInfoType | <input type="checkbox" checked> | None | <pre></pre> | Policy information for the backup instance |
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
