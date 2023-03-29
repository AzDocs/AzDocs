# protectedItems

Target Scope: resourceGroup

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location. |
| resourceName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the resource you want to backup. Should be pre-existing. |
| targetResourceId | string | <input type="checkbox" checked> | None | <pre></pre> | The resourceId for the resource to backup. Should be pre-existing.<br>Example: resourceId(vmResourceGroup, 'Microsoft.Compute/virtualMachines', vmName) |
| recoveryServicesVaultName | string | <input type="checkbox" checked> | Length between 2-50 | <pre></pre> | The name of the recovery services vault. This should be pre-existing. |
| backupFabric | string | <input type="checkbox"> | None | <pre>'Azure'</pre> | The name of the backup container\'s fabric. |
| targetResourceResourceGroupName | string | <input type="checkbox" checked> | None | <pre></pre> | the resource group where the resources you want to backup are in. Should be pre-existing. |
| containerType | string | <input type="checkbox"> | `'AzureBackupServerContainer'` or `'AzureSqlContainer'` or `'GenericContainer'` or `'Microsoft.Compute/virtualMachines'` or `'SQLAGWorkLoadContainer'` or `'StorageContainer'` or `'VMAppContainer'` or `'Windows'` | <pre>'Microsoft.Compute/virtualMachines'</pre> | The container type for the type of resource you want to backup |
| backupPolicyId | string | <input type="checkbox" checked> | None | <pre></pre> | The id for the backup policy in the recovery vault te protected item is going to use. The should be pre-existing. |
| protectionContainer | string | <input type="checkbox"> | None | <pre>'iaasvmcontainer;iaasvmcontainerv2;&#36;{targetResourceResourceGroupName};&#36;{resourceName}'</pre> | the type of protection container for the type of resources you want to create a protected item for in the recovery services vault. |
| protectedItem | string | <input type="checkbox"> | None | <pre>'vm;iaasvmcontainerv2;&#36;{resourceGroup().name};&#36;{resourceName}'</pre> | the type of resource you want to create a protected item for in the protection container type. |
| protectedItemsProperties | object | <input type="checkbox"> | None | <pre>{<br>  protectedItemType: containerType<br>  policyId: backupPolicyId<br>  sourceResourceId: targetResourceId<br>}</pre> | The properties for the resource protectedItems in the protectioncontainer you want to create |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| protectedItemsResourceId | string | the resource id for the protected items resource |

