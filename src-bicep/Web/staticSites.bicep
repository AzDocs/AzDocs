/*
.SYNOPSIS
Creating a Static Web App 
.DESCRIPTION
Creating a Static Web App 
.EXAMPLE
<pre>
module stapp 'br:contosoregistry.azurecr.io/web/staticsites:latest' = {
  name: 'Deploymentname'
  params: {
    staticWebAppName:'stapp-first'
  }
}
</pre>
<p>Creates a static web app named `stapp-first` and the free sku as default</p>
.LINKS
- [Bicep Microsoft.Web staticSites](https://learn.microsoft.com/en-us/azure/templates/microsoft.web/staticsites?pivots=deployment-language-bicep)
*/

@description('The resourcename for the Static Web App to upsert.')
@minLength(1)
@maxLength(40)
param staticWebAppName string

@description('Sku type to use for this static web app. See the [documentation](https://learn.microsoft.com/en-gb/azure/static-web-apps/plans) for more information.')
@allowed([
  'Free'
  'Standard'
])
param staticWebAppSku string = 'Free'


@description('''
The tags to apply to this resource. This is an object with key/value pairs.
Example:
{
  FirstTag: myvalue
  SecondTag: another value
}
''')
param tags object = {}

@description('Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location.')
param location string = resourceGroup().location


resource staticWebApp  'Microsoft.Web/staticSites@2022-03-01' = {
  name: staticWebAppName
  location: location
  tags: tags
  sku: {
    name: staticWebAppSku
    tier: staticWebAppSku
  }
  properties: {
  }
}

@description('Identifer of the newly created static web app')
output staticWebAppId string = staticWebApp.id

@description('Url of the newly created static web app')
output staticWebAppUrl string = staticWebApp.properties.defaultHostname
