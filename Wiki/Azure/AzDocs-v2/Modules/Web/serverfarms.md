# serverfarms

Target Scope: resourceGroup

> [!NOTE]
> This module uses Bicep resource-derived types (`resourceInput<>` / `resourceOutput<>`).
> - [Resource-derived types](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/user-defined-data-types#resource-derived-types)
> - [Bicep data types](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/data-types)

## Synopsis
Creating a serverfarms (AppService Plan) instance with the given specs.

## Description
Creating a serverfarms (AppService Plan) instance with the given specs.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| appServicePlanName | string | <input type="checkbox" checked> | Length between 1-40 | <pre></pre> | The resourcename for the app service plan to upsert. |
| appServicePlanSku | [resourceInput<'Microsoft.Web/serverfarms@2025-03-01'>.sku](https://learn.microsoft.com/en-us/azure/templates/microsoft.web/2025-03-01/serverfarms?pivots=deployment-language-bicep) | <input type="checkbox"> | Schema-constrained (resource-derived type) | <pre>{<br>  name: 'P1v3'<br>  capacity: 1<br>}</pre> | The sku object for this app service plan. For object format, refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.web/serverfarms?tabs=bicep#skudescription.<br>Defaults to:<br>{<br>&nbsp;&nbsp;&nbsp;name: 'P1v3'<br>&nbsp;&nbsp;&nbsp;capacity: 1<br>}<br>Valid SKU names (at the time of writing) include: B1, B2, B3, D1, F1, FC1, FREE, I1, I1v2, I2, I2v2, I3, I3v2, P1V2, P1V3, P2V2, P2V3, P3V2, P3V3, S1, S2, S3, SHARED, WS1, WS2, WS3<br>For a Flex Consumption plan, specify `{ name: 'FC1', tier: 'FlexConsumption' }` and use `functionapp` for the app service plan kind. |
| appServicePlanOsType | [resourceInput<'Microsoft.Web/serverfarms@2025-03-01'>.kind](https://learn.microsoft.com/en-us/azure/templates/microsoft.web/2025-03-01/serverfarms?pivots=deployment-language-bicep) | <input type="checkbox"> | `'app'` or `'functionapp'` or `'windows'` or `'linux'` or `'elastic'` | <pre>'app'</pre> | The server farm kind. Use windows for Windows, linux for Linux, or app, functionapp, or elastic with appServicePlanReserved to select the worker operating system. Defaults to app, which uses Windows. For FC1, use functionapp because Flex Consumption always uses Linux. |
| appServicePlanReserved | bool | <input type="checkbox"> | None | <pre>false</pre> | Sets the worker operating system for app, functionapp, and elastic kinds. Set to true for Linux and false for Windows. Defaults to Windows. Flex Consumption always uses Linux, and explicit linux or windows kinds take precedence. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| appServicePlanPerSiteScaling | bool | <input type="checkbox"> | None | <pre>true</pre> | If true, apps assigned to this App Service plan can be scaled independently.<br>If false, apps assigned to this App Service plan will scale to all instances of the plan.<br>This value is ignored and set to null for Flex Consumption plans. |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location. |
| appServicePlanMaximumElasticWorkerCount | int? | <input type="checkbox" checked> | None | <pre></pre> | Maximum number of total workers allowed for this ElasticScaleEnabled App Service Plan. This value is ignored and set to null for Flex Consumption plans. |
| zoneRedundant | bool | <input type="checkbox"> | None | <pre>false</pre> | If set to true, this App Service Plan will perform availability zone balancing. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| appServicePlanResourceId | string | Output the App Service Plan\'s resource id. |
| appServicePlanSkuName | string | Output the App Service Plan\'s SKU name. |
| appServicePlanResourceName | string | Output the App Service Plan\'s resource name. |

## Examples
<pre>
module appServicePlan 'br:contosoregistry.azurecr.io/web/serverfarms:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 53), 'serverfarms')
  params: {
    appServicePlanName: 'asp-contoso-prd'
    appServicePlanSku: {
      name: 'FC1'
      tier: 'FlexConsumption'
    }
    appServicePlanOsType: 'functionapp'
  }
}
</pre>
<p>Creates a Linux Flex Consumption plan. Configure On Demand or Always Ready billing on the Function App module.</p>
<p>A Flex Consumption plan supports one app only, and Flex Consumption is not available in every region. Virtual network integration needs the `Microsoft.App` resource provider registered and a subnet delegated to `Microsoft.App/environments`. With `zoneRedundant: true`, configure at least two Always ready instances per group on the Function App.</p>
<p>For Flex Consumption plans, per-site scaling and maximum elastic worker count are ignored and set to null by the module.</p>
<p>For <code>app</code>, <code>functionapp</code>, and <code>elastic</code> kinds, set <code>appServicePlanReserved</code> to <code>true</code> for Linux or <code>false</code> for Windows. Explicit <code>linux</code> and <code>windows</code> kinds determine the worker OS, and Flex Consumption always uses Linux.</p>

## Links
- [Bicep Microsoft.Web Serverfarms ](https://learn.microsoft.com/en-us/azure/templates/microsoft.web/serverfarms?pivots=deployment-language-bicep)<br>
- [Azure App Service Kind](https://github.com/Azure/app-service-linux-docs/blob/master/Things_You_Should_Know/kind_property.md)
