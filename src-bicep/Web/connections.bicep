/*
.SYNOPSIS
Creating a Api connection resource for a web resource, e.g a Logic App.
.DESCRIPTION
Creating a Api connection resource for a web resource, e.g a Logic App.
.EXAMPLE
<pre>
module connections_azureautomation 'br:contosoregistry.azurecr.io/web/connections:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 47), 'connazautomation')
  params: {
    connectionName: connectionName
    location: location
    connectionApi: connectionApi
    parameterValues: parameterValues
    connectionPropertiesDisplayName: connectionPropertiesDisplayName
  }
}
</pre>
<p>Creates a Api connection resource with the name connectionName</p>
.LINKS
- [Bicep Web Connections](https://learn.microsoft.com/en-us/azure/templates/microsoft.web/connections?pivots=deployment-language-bicep)
- [Example connections](https://developercommunity.visualstudio.com/t/connections-for-logic-app-deployed-with-arm-templa/1376770)
*/

// ================================================= Parameters =================================================
@description('Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location.')
param location string = resourceGroup().location

@description('''
The tags to apply to this resource. This is an object with key/value pairs.
Example:
{
  FirstTag: myvalue
  SecondTag: another value
}
''')
param tags object = {}

@description('The name of the Api connection to upsert.')
param connectionName string

@description('''The reference name for the type to make the connection to.
Example:
'sql'
''')
param connectorTypeName string = 'azureautomation'

@description('''Object that defines the api connection, where id is the type of the connector that must invoked in a specific <subscriptionID> and <locationname>
Example:
{
  id: '${subscription().id}/providers/Microsoft.Web/locations/${location}/managedApis/azureblob'
}
''')
param connectionApi object = {
  id: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Web/locations/westeurope/managedApis/${connectorTypeName}'
}

@description('Dictionary of custom parameter values.')
param customerParameterValues object = {}

@description('Object of non secret parameter values you can set.')
param nonSecretParameterValues object = {}

@description('''
Parameter value object to (pre-)authorize/consent the Api Connection resource. If you use a managed identity, you should also allow the logic app managed identity to access that connection.
Example:
{
  'token:clientId': authorizingSPClientId
  'token:clientSecret': authorizingSPClientSecret
  'token:TenantId': subscription().tenantId
  'token:grantType': 'client_credentials'
  'token:resourceUri': environment().authentication.audiences[0]
},
{
  'server': 'server'
  'database: 'database'
  'authType': 'basic'
  'username': 'username'
  'password': 'password'
},
{
  accountName: storageAccountName
  accessKey: listKeys(storageAccountId, '2019-04-01').keys[0].value
}
''')
param parameterValues object = {}

@description('Displayname in the connection properties.')
param connectionPropertiesDisplayName string = 'Azure Automation'

@description('''
Method and uri for the ApiConnectionTestLink to test connectivity.
Example:
{
requestUri: uri('${environment().resourceManager}', 'subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Web/connections/${connectionName}/extensions/proxy/testconnection?api-version=2018-07-01-preview')
method: 'get'
}
''')
param connectionTestLink array = []


resource connection 'Microsoft.Web/connections@2016-06-01' = {
  name: connectionName
  location: location
  tags: tags
  #disable-next-line BCP187
  kind: 'V2' //needs to be V2 to support access policies
  properties: {
    api: connectionApi
    customParameterValues: customerParameterValues
    displayName: connectionPropertiesDisplayName
    nonSecretParameterValues: nonSecretParameterValues
    parameterValues: parameterValues
    testLinks: connectionTestLink
  }
}

@description('Output the connection\'s resource name.')
output connectionResourceName string = connection.name
@description('Output the connection\'s resource id.')
output connectionResourceId string = connection.id
@description('Output the connection\'s resource API Version.')
output connectionApiVersion string = connection.apiVersion
@description('Output the connection\'s connection runtime url.')
output connectionRuntimeUrl string = reference(connection.id, connection.apiVersion, 'full').properties.connectionRuntimeUrl

