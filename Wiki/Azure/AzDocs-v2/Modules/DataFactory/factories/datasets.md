# datasets

Target Scope: resourceGroup

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| dataFactoryName | string | <input type="checkbox" checked> | Length between 3-63 | <pre></pre> | The resource name of the Data Factory you are targeting. This resource has to be pre-existing. |
| dataFactoryDatasetName | string | <input type="checkbox" checked> | Length between 1-260 | <pre></pre> | The name of the dataset to create. |
| dataFactoryLinkedServiceName | string | <input type="checkbox" checked> | Length between 1-260 | <pre></pre> | The resourcename of the linked service you want to use for this DataSet. This resource has to be pre-existing. |
| dataFactoryDatasetType | string | <input type="checkbox"> | None | <pre>'Binary'</pre> | The type of the dataset to upsert. For options & formatting, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.datafactory/factories/datasets?pivots=deployment-language-bicep#dataset-objects. |
| dataFactoryDatasetTypeProperties | object | <input type="checkbox"> | None | <pre>{}</pre> | The properties of the datasettype to upsert. For options & formatting, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.datafactory/factories/datasets?pivots=deployment-language-bicep#dataset-objects. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| dataFactoryDatasetName | string | Output the resource name of this dataset. |
| dataFactoryDatasetResourceId | string | Output the resource id of this dataset. |
