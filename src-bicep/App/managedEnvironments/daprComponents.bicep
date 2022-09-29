/*
.SYNOPSIS
Creating a Dapr Component resource
.DESCRIPTION
A Dapr (Distributed Application Runtime) component can be used for a container app.
It is a runtime that helps build resilient, stateless, and stateful microservices.
.EXAMPLE
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
.LINKS
- [Bicep Microsoft.App/managedEnvironments daprComponent](https://learn.microsoft.com/en-us/azure/templates/microsoft.app/managedenvironments/daprcomponents?pivots=deployment-language-bicep)
*/

// ================================================= Parameters =================================================
@description('''
Name of the dapr Component. Dapr is a runtime that helps build resilient, stateless, and stateful microservices.
The name must be in lowercase.
''')
@maxLength(60)
param daprComponentName string

@description('The storage component type where the dapr component stores its state.')
@allowed([
  'state.azure.blobstorage'
  'state.azure.cosmosdb'
  ''
])
param daprComponentType string = ''

@description('''
Collection of secrets used by a Dapr component. For values use parameters with the @secure() attribute or a keyvault.
Example:
[
  {
    name: 'storageaccountkey'
    value: (!empty(storageAccountName)) ? listKeys(resourceId('Microsoft.Storage/storageAccounts/', storageAccount.name), '2021-09-01').keys[0].value : ''
  }
]
''')
param daprSecrets array = []

@description('''
Metadata for the dapr component.
Example:
[
  {
    name: 'connectionString'
    value: 'Endpoint=sb://someeventhub.servicebus.windows.net/;SharedAccessKeyName=someeventhub-policy;SharedAccessKey=0000000aabbbcc0000000000000=;EntityPath=someeventhub-partition'
  }
  {
    name: 'storageAccountName'
    value: storageAccountName
  }
  {
    name: 'storageAccountKey'
    secretRef: 'storageaccountkey'
  }
  {
    name: 'storageContainerName'
    value: storageContainerName
  }
]
''')
param daprMetadata array = []

@description('The version of the Dapr component.')
param daprComponentVersion string = 'v1'

@description('Boolean describing if the component errors are ignored.')
param daprComponentIgnoreErrors bool = true

@description('Initialization timeout')
param daprComponentInitTimeout string = '5s'

@description('''
Name(s) of container app(s) that can use this Dapr component.
In the Container App resource, the daprId should match the scopes property within the dapr component being defined.
''')
param daprComponentScope array = []

@description('The name for the managed Environment for the Container App.')
@minLength(2)
@maxLength(260)
param managedEnvironmentName string

resource managedEnvironment 'Microsoft.App/managedEnvironments@2022-03-01' existing = {
  name: managedEnvironmentName

  resource daprComponent 'daprComponents@2022-03-01' = {
    name: daprComponentName
    properties: {
      componentType: daprComponentType
      version: daprComponentVersion
      ignoreErrors: daprComponentIgnoreErrors
      initTimeout: daprComponentInitTimeout
      secrets: daprSecrets
      metadata: daprMetadata
      scopes: daprComponentScope
    }
  }
}
