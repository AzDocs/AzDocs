# storages

Target Scope: resourceGroup

## Synopsis
Creating a storages resources

## Description
A storages resources can be used for volumes for a container app.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| managedEnvironmentName | string | <input type="checkbox" checked> | None | <pre></pre> | The name for the managed Environment for the Container App. |
| storagesName | string | <input type="checkbox"> | None | <pre>'azurefilestorage'</pre> | The name for the storages resource |
| storageAccountKey | string | <input type="checkbox" checked> | None | <pre></pre> | The account key to use on the storage account |
| storageAccountName | string | <input type="checkbox" checked> | None | <pre></pre> | the storage account name. This should be pre-existing. |
| storageAccountFileShareName | string | <input type="checkbox" checked> | None | <pre></pre> | the fileshare name in the storage account. |
| storagesAccessMode | string | <input type="checkbox"> | None | <pre>'ReadWrite'</pre> | Since you need to use a shareName (Azure File Share Storage), accessMode should be set to either ReadWrite or ReadOnly. |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |
## Examples
<pre>
module storages '../../AzDocs/src-bicep/App/managedEnvironments/storages.bicep' = {
  name: format('{0}-{1}', take('${deployment().name}', 48), 'storages')
  params: {
    managedEnvironmentName: managedEnvironmentName
    storageAccountFileShareName: 'myfileshare'
    storageAccountKey: listKeys(resourceId('Microsoft.Storage/storageAccounts/', storageAccount.name), '2021-09-01').keys[0].value
    storageAccountName: daprStorageAccountName
    location: location
  }
}
</pre>
<p>Creates a storages resource</p>

## Links
- [Bicep Microsoft.App/managedEnvironments storages](https://learn.microsoft.com/en-us/azure/templates/microsoft.app/managedenvironments/storages?pivots=deployment-language-bicep)


