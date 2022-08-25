# linkedservices

Target Scope: resourceGroup

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| dataFactoryName | string | <input type="checkbox" checked> | Length between 3-63 | <pre></pre> | The resource name of the Data Factory you are targeting. This resource has to be pre-existing. |
| dataFactoryLinkedServiceName | string | <input type="checkbox" checked> | Length between 1-260 | <pre></pre> | The resourcename of the linked service you want to use for this DataSet. This resource has to be pre-existing. |
| dataFactoryLinkedServiceTypeProperties | object | <input type="checkbox"> | None | <pre>{}</pre> | The properties for this linked service type. For options & formatting, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.datafactory/2018-06-01/factories/linkedservices?pivots=deployment-language-bicep#linkedservice-objects. |
| annotations | array | <input type="checkbox"> | None | <pre>[]</pre> | List of tags that can be used for describing the linked service. |
| connectVia | object | <input type="checkbox"> | None | <pre>{}</pre> | If you need to connect through a integration runtime, this is the parameter to define that. For options & formatting, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.datafactory/2018-06-01/factories/linkedservices?pivots=deployment-language-bicep#integrationruntimereference. |
| dataFactoryLinkedServiceType | string | <input type="checkbox"> | None | <pre>'AzureBlobStorage'</pre> | Sets the type for this linked service. For current options please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.datafactory/2018-06-01/factories/linkedservices?pivots=deployment-language-bicep#linkedservice-objects. |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| dataFactoryLinkedServiceName | string | Outputs the resource name of the upserted linkedservice |
| dataFactoryLinkedServiceId | string | Outputs the resource ID of the upserted linkedservice |

