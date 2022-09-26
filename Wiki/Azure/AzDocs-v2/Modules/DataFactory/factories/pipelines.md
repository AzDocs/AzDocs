# pipelines

Target Scope: resourceGroup

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| dataFactoryName | string | <input type="checkbox" checked> | Length between 3-63 | <pre></pre> | The resource name of the Data Factory you are targeting. This resource has to be pre-existing. |
| dataFactoryPipelineName | string | <input type="checkbox" checked> | Length between 1-260 | <pre></pre> | The resource name of the Data Factory pipeline to be upserted. |
| activities | array | <input type="checkbox"> | None | <pre>[]</pre> | List of activities in pipeline.	For options & formatting, please refer to: https://docs.microsoft.com/en-us/azure/templates/microsoft.datafactory/factories/pipelines?pivots=deployment-language-bicep#activity. |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| dataFactoryPipelineName | string | The resource name of the upserted pipeline in the data factory |
| dataFactoryPipelineResourceId | string | The resource ID of the upserted pipeline in the data factory |

