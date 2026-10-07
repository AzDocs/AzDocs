# dashboards

Target Scope: resourceGroup

## User Defined Types
| Name | Type | Discriminator | Description
| -- |  -- | -- | -- |
| <a id="DashboardPartPosition">DashboardPartPosition</a>  | <pre>{<br>&nbsp;&nbsp;&nbsp;x: int<br>&nbsp;&nbsp;&nbsp;y: int<br>&nbsp;&nbsp;&nbsp;colSpan: int<br>&nbsp;&nbsp;&nbsp;rowSpan: int<br>&nbsp;&nbsp;&nbsp;metadata: object?<br>}<br></pre> |  |  |
| <a id="DashboardPart">DashboardPart</a>  | <pre>{<br>&nbsp;&nbsp;&nbsp;position: DashboardPartPosition<br>&nbsp;&nbsp;&nbsp;metadata: object?<br>}<br></pre> |  |  |
| <a id="DashboardLens">DashboardLens</a>  | <pre>{<br>&nbsp;&nbsp;&nbsp;order: int<br>&nbsp;&nbsp;&nbsp;parts: DashboardPart[]<br>&nbsp;&nbsp;&nbsp;metadata: object?<br>}<br></pre> |  |  |
| <a id="DashboardProperties">DashboardProperties</a>  | <pre>{<br>&nbsp;&nbsp;&nbsp;lenses: DashboardLens[]?<br>&nbsp;&nbsp;&nbsp;metadata: object?<br>}<br></pre> |  |  |

## Synopsis
Creates an Azure portal dashboard.

## Description
Creates a Microsoft.Portal dashboard from caller-provided dashboard properties. The display name is stored in the hidden-title tag.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| dashboardName | string | <input type="checkbox" checked> | Length between 3-64 | <pre></pre> | The name of the dashboard resource. Alphanumerics and hyphens only. |
| dashboardDisplayName | string | <input type="checkbox" checked> | Length between 1-256 | <pre></pre> | The title displayed for the dashboard in the Azure portal and stored in the hidden-title tag. |
| dashboardProperties | [DashboardProperties](#DashboardProperties) | <input type="checkbox" checked> | None | <pre></pre> | The dashboard definition, including its lenses and metadata. |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | The Azure region for the dashboard. Defaults to the resource group location. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | Additional tags to apply to the dashboard. The hidden-title tag is set from dashboardDisplayName. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| dashboardId | string | The resource ID of the dashboard. |
| dashboardName | string | The name of the dashboard. |

## Examples
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

## Links
- [Bicep Microsoft.Portal dashboards](https://learn.microsoft.com/en-us/azure/templates/microsoft.portal/dashboards?pivots=deployment-language-bicep)
