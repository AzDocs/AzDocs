# connections

Target Scope: resourceGroup

## Synopsis
Creating a Api connection resource for a web resource, e.g a Logic App.

## Description
Creating a Api connection resource for a web resource, e.g a Logic App.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| connectionName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the Api connection to upsert. |
| connectorTypeName | string | <input type="checkbox"> | None | <pre>'azureautomation'</pre> | Example:<br>'sql' |
| connectionApi | object | <input type="checkbox"> | None | <pre>{<br>  id: '/subscriptions/&#36;{subscription().subscriptionId}/providers/Microsoft.Web/locations/westeurope/managedApis/&#36;{connectorTypeName}'<br>}</pre> | Example:<br>{<br>&nbsp;&nbsp;&nbsp;id: '&#36;{subscription().id}/providers/Microsoft.Web/locations/&#36;{location}/managedApis/azureblob'<br>} |
| customerParameterValues | object | <input type="checkbox"> | None | <pre>{}</pre> | Dictionary of custom parameter values. |
| nonSecretParameterValues | object | <input type="checkbox"> | None | <pre>{}</pre> | Object of non secret parameter values you can set. |
| parameterValues | object | <input type="checkbox"> | None | <pre>{}</pre> | Parameter value object to (pre-)authorize/consent the Api Connection resource. If you use a managed identity, you should also allow the logic app managed identity to access that connection.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;'token:clientId': authorizingSPClientId<br>&nbsp;&nbsp;&nbsp;'token:clientSecret': authorizingSPClientSecret<br>&nbsp;&nbsp;&nbsp;'token:TenantId': subscription().tenantId<br>&nbsp;&nbsp;&nbsp;'token:grantType': 'client_credentials'<br>&nbsp;&nbsp;&nbsp;'token:resourceUri': environment().authentication.audiences[0]<br>},<br>{<br>&nbsp;&nbsp;&nbsp;'server': 'server'<br>&nbsp;&nbsp;&nbsp;'database: 'database'<br>&nbsp;&nbsp;&nbsp;'authType': 'basic'<br>&nbsp;&nbsp;&nbsp;'username': 'username'<br>&nbsp;&nbsp;&nbsp;'password': 'password'<br>},<br>{<br>&nbsp;&nbsp;&nbsp;accountName: storageAccountName<br>&nbsp;&nbsp;&nbsp;accessKey: listKeys(storageAccountId, '2019-04-01').keys[0].value<br>} |
| connectionPropertiesDisplayName | string | <input type="checkbox"> | None | <pre>'Azure Automation'</pre> | Displayname in the connection properties. |
| connectionTestLink | array | <input type="checkbox"> | None | <pre>[]</pre> | Method and uri for the ApiConnectionTestLink to test connectivity.<br>Example:<br>{<br>requestUri: uri('&#36;{environment().resourceManager}', 'subscriptions/&#36;{subscription().subscriptionId}/resourceGroups/&#36;{resourceGroup().name}/providers/Microsoft.Web/connections/&#36;{connectionName}/extensions/proxy/testconnection?api-version=2018-07-01-preview')<br>method: 'get'<br>} |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| connectionResourceName | string | Output the connection\'s resource name. |
| connectionResourceId | string | Output the connection\'s resource id. |
| connectionApiVersion | string | Output the connection\'s resource API Version. |
| connectionRuntimeUrl | string | Output the connection\'s connection runtime url. |

## Examples
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

## Links
- [Bicep Web Connections](https://learn.microsoft.com/en-us/azure/templates/microsoft.web/connections?pivots=deployment-language-bicep)<br>
- [Example connections](https://developercommunity.visualstudio.com/t/connections-for-logic-app-deployed-with-arm-templa/1376770)
