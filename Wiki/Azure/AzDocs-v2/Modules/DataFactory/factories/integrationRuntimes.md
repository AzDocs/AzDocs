# integrationRuntimes

Target Scope: resourceGroup

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| dataFactoryName | string | <input type="checkbox" checked> | Length between 3-63 | <pre></pre> | The resource name of the Data Factory you are targeting. This resource has to be pre-existing. |
| dataFactoryManagedVirtualNetworkName | string | <input type="checkbox" checked> | Length between 2-64 | <pre></pre> | The resource name of the managed virtual network within the given Data Factory. This resource should be pre-existing. |
| dataFactoryIntegrationRuntimeName | string | <input type="checkbox" checked> | Length between 3-63 | <pre></pre> | The resource name of the integration runtime to upsert. |
| integrationRuntimeDataFlowProperties | object | <input type="checkbox"> | None | <pre>{<br>  computeType: 'General'<br>  coreCount: 8<br>  timeToLive: 0<br>}</pre> | Data flow properties for managed integration runtime. For options & formatting, please refer to: https://docs.microsoft.com/en-us/azure/templates/microsoft.datafactory/2018-06-01/factories/integrationruntimes?pivots=deployment-language-bicep#integrationruntimedataflowproperties.<br>Defaults to:<br>{<br>&nbsp;&nbsp;&nbsp;computeType: 'General'<br>&nbsp;&nbsp;&nbsp;coreCount: 8<br>&nbsp;&nbsp;&nbsp;timeToLive: 0<br>} |
| dataFactoryIntegrationRuntimeType | string | <input type="checkbox"> | `'Managed'` or `'SelfHosted'` | <pre>'Managed'</pre> | The type of the integration runtime. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| dataFactoryIntegrationRuntimeResourceName | string | Output the resourcename of this integration runtime. |
| dataFactoryIntegrationRuntimeResourceId | string | Output the resource id of this integration runtime. |
