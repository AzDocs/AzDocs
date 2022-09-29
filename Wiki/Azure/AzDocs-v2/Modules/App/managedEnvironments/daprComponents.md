# daprComponents

Target Scope: resourceGroup

## Synopsis
Creating a Dapr Component resource

## Description
A Dapr (Distributed Application Runtime) component can be used for a container app.<br>
It is a runtime that helps build resilient, stateless, and stateful microservices.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| daprComponentName | string | <input type="checkbox" checked> | Length between 0-60 | <pre></pre> | Name of the dapr Component. Dapr is a runtime that helps build resilient, stateless, and stateful microservices.<br>The name must be in lowercase. |
| daprComponentType | string | <input type="checkbox"> | `'state.azure.blobstorage'` or  `'state.azure.cosmosdb'` or  `''` | <pre>''</pre> | The storage component type where the dapr component stores its state. |
| daprSecrets | array | <input type="checkbox"> | None | <pre>[]</pre> | Collection of secrets used by a Dapr component. For values use parameters with the @secure() attribute or a keyvault.<br>Example:<br>[<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;name: 'storageaccountkey'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;value: (!empty(storageAccountName)) ? listKeys(resourceId('Microsoft.Storage/storageAccounts/', storageAccount.name), '2021-09-01').keys[0].value : ''<br>&nbsp;&nbsp;&nbsp;}<br>] |
| daprMetadata | array | <input type="checkbox"> | None | <pre>[]</pre> | Metadata for the dapr component.<br>Example:<br>[<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;name: 'connectionString'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;value: 'Endpoint=sb://someeventhub.servicebus.windows.net/;SharedAccessKeyName=someeventhub-policy;SharedAccessKey=0000000aabbbcc0000000000000=;EntityPath=someeventhub-partition'<br>&nbsp;&nbsp;&nbsp;}<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;name: 'storageAccountName'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;value: storageAccountName<br>&nbsp;&nbsp;&nbsp;}<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;name: 'storageAccountKey'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;secretRef: 'storageaccountkey'<br>&nbsp;&nbsp;&nbsp;}<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;name: 'storageContainerName'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;value: storageContainerName<br>&nbsp;&nbsp;&nbsp;}<br>] |
| daprComponentVersion | string | <input type="checkbox"> | None | <pre>'v1'</pre> | The version of the Dapr component. |
| daprComponentIgnoreErrors | bool | <input type="checkbox"> | None | <pre>true</pre> | Boolean describing if the component errors are ignored. |
| daprComponentInitTimeout | string | <input type="checkbox"> | None | <pre>'5s'</pre> | Initialization timeout |
| daprComponentScope | array | <input type="checkbox"> | None | <pre>[]</pre> | Name(s) of container app(s) that can use this Dapr component.<br>In the Container App resource, the daprId should match the scopes property within the dapr component being defined. |
| managedEnvironmentName | string | <input type="checkbox" checked> | Length between 2-260 | <pre></pre> | The name for the managed Environment for the Container App. |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |
## Examples
<pre>
module dapr '../../AzDocs/src-bicep/App/managedEnvironments/daprComponents.bicep' = {
  name: format('{0}-{1}', take('${deployment().name}', 48), 'dapr')
  params: {
    managedEnvironmentName: managedEnvironment.outputs.managedEnvironmentName
    daprComponentName: 'myfirstdaprcomponent'
    daprComponentType: 'state.azure.blobstorage'
    daprComponentVersion: '1.0'
    daprComponentIgnoreErrors: false
    daprComponentInitTimeout: '5s'
    daprSecrets: [
      {
        name: 'storageaccountkey'
        value: listKeys(resourceId('Microsoft.Storage/storageAccounts/', storageAccount.name), '2021-09-01').keys[0].value
      }
    ]
    daprMetadata: [
      {
        name: 'accountName'
        value: storageAccount.name
      }
      {
        name: 'containerName'
        value: storageAccount.name
      }
      {
        name: 'accountKey'
        secretRef: 'storageaccountkey'
      }
    ]
    daprComponentScope: [
      'redis'
    ]

  }
}
</pre>
<p>Creates a dapr component with the name MyFirstDaprComponent</p>

## Links
- [Bicep Microsoft.App/managedEnvironments daprComponent](https://learn.microsoft.com/en-us/azure/templates/microsoft.app/managedenvironments/daprcomponents?pivots=deployment-language-bicep)


