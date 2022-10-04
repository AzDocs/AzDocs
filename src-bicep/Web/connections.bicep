//TODO: Document & review this --> I dont know how this works.
@description('Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location.')
param location string = resourceGroup().location

@description('The name of the connection to upsert.')
param connectionName string

@description('''
The tags to apply to this resource. This is an object with key/value pairs.
Example:
{
  FirstTag: myvalue
  SecondTag: another value
}
''')
param tags object = {}

//TODO: Are these AD objects?
param clientId string
param clientSecret string

resource connection 'Microsoft.Web/connections@2016-06-01' = {
  name: connectionName
  location: location
  #disable-next-line BCP187
  kind: 'V2' //needs to be V2
  tags: tags
  properties: {
    displayName: 'azureautomation' //TODO: Always the same? can we have multiple with the same display name?
    parameterValues: { // TODO: Make configurable?
      'token:clientId': clientId
      'token:clientSecret': clientSecret
      'token:TenantId': subscription().tenantId
      'token:grantType': 'client_credentials'
      'token:resourceUri': environment().authentication.audiences[0] //'https://management.core.windows.net/' //the resource you are requesting authorization to use
    }
    customParameterValues: {}
    api: { // What does this do? Do we need to make this configurable?
      name: 'azureautomation'
      displayName: 'Azure Automation'
      description: 'Azure Automation provides tools to manage your cloud and on-premises infrastructure seamlessly.'
      id: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Web/locations/westeurope/managedApis/${connectionName}'
      type: 'Microsoft.Web/locations/managedApis'
    }
    testLinks: [] // ????????????
  }
}

@description('Output the connection\'s resource id.')
output connectionResourceId string = connection.id
@description('Output the connection\'s resource API Version.')
output connectionApiVersion string = connection.apiVersion
@description('Output the connection\'s runtime URL.')
output connectionRuntimeUrl string = reference(connection.id, connection.apiVersion, 'full').properties.connectionRuntimeUrl // TODO: Check if this breaks if the resource does not exist, because `reference()` probably gets called compile time before creating the resource.
