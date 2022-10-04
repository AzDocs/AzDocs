# backupstorageconfig

Target Scope: resourceGroup

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location. |
| recoveryServicesVaultName | string | <input type="checkbox" checked> | Length between 2-50 | <pre></pre> | The name of the recovery services vault. This vault should be pre-existing. |
| backupstorageconfigName | string | <input type="checkbox"> | None | <pre>'vaultstorageconfig'</pre> | The name of the backupstorage config in the recovery vault to create. This config determines properties for the storage type. |
| enableCrossRegionRestore | bool | <input type="checkbox"> | None | <pre>false</pre> | The Cross Region Restore option allows you to restore data in a secondary, Azure paired region. You can use Cross Region Restore to conduct drills when there's an audit or compliance requirement.<br>You can also use it to restore the data if there's a disaster in the primary region. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| vaultStorageType | string | <input type="checkbox"> | `'LocallyRedundant'` or  `'GeoRedundant'` or  `'ZoneRedundant'` | <pre>'LocallyRedundant'</pre> | Works if vault has not registered any backup instance yet.<br>Azure Backup automatically handles storage for the vault. You need to specify how that storage is replicated.<br>More info: https://docs.microsoft.com/en-us/azure/backup/backup-create-rs-vault |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| vaultStorageConfigResourceId | string | the resource id for the backupstorage config. |

