# openidconnectproviders

Target Scope: resourceGroup

## Synopsis
Register or modify OpenId Connect in Api Management Service.

## Description
Register a new or modify OpenId Connect provider in Api Management Service.<br>
<pre><br>
module diagnostics 'br:contosoregistry.azurecr.io/service/openidconnectproviders.bicep' = {<br>
  name: format('{0}-{1}', take('${deployment().name}', 58), 'openidconnectproviders')<br>
  params: {<br>
    apiManagementServiceName: apiManagementServiceName<br>
    clientId: clientId<br>
    clientSecret: clientSecret<br>
    description: description<br>
    displayName: displayName<br>
    metadataEndpoint: metadataEndpoint<br>
    name: name<br>
    useInApiDocumentation: useInApiDocumentation<br>
    useInTestConsole: useInTestConsole<br>
  }<br>
}<br>
</pre><br>
<p>Register or modify OpenId Connect in Api Management Service.</p>

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| apiManagementServiceName | string | <input type="checkbox" checked> | Length between 1-50 | <pre></pre> |  |
| clientId | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> |  |
| clientSecret | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> |  |
| description | string | <input type="checkbox" checked> | Length between 1-256 | <pre></pre> |  |
| displayName | string | <input type="checkbox" checked> | Length between 1-50 | <pre></pre> |  |
| metadataEndpoint | string | <input type="checkbox" checked> | None | <pre></pre> |  |
| name | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> |  |
| useInApiDocumentation | bool | <input type="checkbox"> | None | <pre>false</pre> |  |
| useInTestConsole | bool | <input type="checkbox"> | None | <pre>true</pre> |  |

## Links
- [Bicep Microsoft.ApiManagement diagnostics](https://learn.microsoft.com/en-us/azure/templates/microsoft.apimanagement/service/openidconnectproviders?pivots=deployment-language-bicep)
