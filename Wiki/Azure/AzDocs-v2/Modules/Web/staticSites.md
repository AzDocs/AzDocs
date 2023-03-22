# staticSites

Target Scope: resourceGroup

## Synopsis
Creating a Static Web App 

## Description
Creating a Static Web App 

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| staticWebAppName | string | <input type="checkbox" checked> | Length between 1-40 | <pre></pre> | The resourcename for the Static Web App to upsert. |
| staticWebAppSku | string | <input type="checkbox"> | `'Free'` or  `'Standard'` | <pre>'Free'</pre> | Sku type to use for this static web app. See the [documentation](https://learn.microsoft.com/en-gb/azure/static-web-apps/plans) for more information. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location. |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| staticWebAppId | string | Identifer of the newly created static web app |
| staticWebAppUrl | string | Url of the newly created static web app |
## Examples
<pre>
module stapp 'br:contosoregistry.azurecr.io/web/staticsites:latest' = {
  name: 'Deploymentname'
  params: {
    staticWebAppName:'stapp-first'
  }
}
</pre>
<p>Creates a static web app named `stapp-first` and the free sku as default</p>

## Links
- [Bicep Microsoft.Web staticSites](https://learn.microsoft.com/en-us/azure/templates/microsoft.web/staticsites?pivots=deployment-language-bicep)


