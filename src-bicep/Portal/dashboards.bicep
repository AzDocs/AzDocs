/*
.SYNOPSIS
Creates an Azure portal dashboard.
.DESCRIPTION
Creates a Microsoft.Portal dashboard from caller-provided dashboard properties. The display name is stored in the hidden-title tag.
.EXAMPLE
<pre>
module dashboard 'br:contosoregistry.azurecr.io/portal/dashboards:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 54), 'dashboard')
  params: {
    dashboardName: 'dash-myapp-dev'
    dashboardDisplayName: 'My Application Dashboard'
    dashboardProperties: loadJsonContent('dashboard.json')
    tags: {
      EnvironmentType: 'Development'
    }
  }
}
</pre>
<p>Deploys a portal dashboard. The dashboard definition is supplied as an object, for example by loading a JSON file.</p>
.LINKS
- [Bicep Microsoft.Portal dashboards](https://learn.microsoft.com/en-us/azure/templates/microsoft.portal/dashboards?pivots=deployment-language-bicep)
*/
type DashboardPartPosition = {
  x: int
  y: int
  colSpan: int
  rowSpan: int
  metadata: object?
}

type DashboardPart = {
  position: DashboardPartPosition
  metadata: object?
}

type DashboardLens = {
  order: int
  parts: DashboardPart[]
  metadata: object?
}

type DashboardProperties = {
  lenses: DashboardLens[]?
  metadata: object?
}

// ========== Parameters ==========
@description('The name of the dashboard resource. Alphanumerics and hyphens only.')
@minLength(3)
@maxLength(64)
param dashboardName string

@description('The title displayed for the dashboard in the Azure portal and stored in the hidden-title tag.')
@minLength(1)
@maxLength(256)
param dashboardDisplayName string

@description('The dashboard definition, including its lenses and metadata.')
param dashboardProperties DashboardProperties

@description('The Azure region for the dashboard. Defaults to the resource group location.')
param location string = resourceGroup().location

@description('Additional tags to apply to the dashboard. The hidden-title tag is set from dashboardDisplayName.')
param tags object = {}

// ========== Resources ==========
@description('Creates the Azure portal dashboard.')
resource dashboard 'Microsoft.Portal/dashboards@2022-12-01-preview' = {
  name: dashboardName
  location: location
  tags: union(tags, {
    'hidden-title': dashboardDisplayName
  })
  properties: dashboardProperties
}

// ========== Outputs ==========
@description('The resource ID of the dashboard.')
output dashboardId string = dashboard.id

@description('The name of the dashboard.')
output dashboardName string = dashboard.name
