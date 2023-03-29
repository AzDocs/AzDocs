# serverfarms

Target Scope: resourceGroup

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| appServicePlanName | string | <input type="checkbox" checked> | Length between 1-40 | <pre></pre> | The resourcename for the app service plan to upsert. |
| appServicePlanSku | object | <input type="checkbox"> | None | <pre>{<br>  name: 'P1v3'<br>  capacity: 1<br>}</pre> | The sku object for this app service plan. For object format, refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.web/serverfarms?tabs=bicep#skudescription.<br>Defaults to:<br>{<br>&nbsp;&nbsp;&nbsp;name: 'P1v3'<br>&nbsp;&nbsp;&nbsp;capacity: 1<br>}<br>Valid SKU names (at the time of writing) are: B1, B2, B3, D1, F1, FREE, I1, I1v2, I2, I2v2, I3, I3v2, P1V2, P1V3, P2V2, P2V3, P3V2, P3V3, S1, S2, S3, SHARED, WS1, WS2, WS3 |
| appServicePlanOsType | string | <input type="checkbox"> | `''` or `'linux'` or `'windows'` | <pre>'linux'</pre> | The OS type for this app service plan. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| appServicePlanPerSiteScaling | bool | <input type="checkbox"> | None | <pre>true</pre> | If true, apps assigned to this App Service plan can be scaled independently.<br>If false, apps assigned to this App Service plan will scale to all instances of the plan. |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location. |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| appServicePlanResourceId | string | Output the App Service Plan\'s resource id. |
| appServicePlanSkuName | string | Output the App Service Plan\'s SKU name. |
| appServicePlanResourceName | string | Output the App Service Plan\'s resource name. |

