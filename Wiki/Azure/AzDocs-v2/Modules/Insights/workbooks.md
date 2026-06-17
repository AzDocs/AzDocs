# workbooks

Target Scope: resourceGroup

## Synopsis
Creating a Workbook.

## Description
Creating an Azure Monitor Workbook for custom visualization and analysis. Workbooks provide a flexible canvas for data analysis and the creation of rich visual reports within the Azure portal. Only 'shared' kind is currently supported.<br>
<pre><br>
module workbook 'br:contosoregistry.azurecr.io/insights/workbooks:latest' = {<br>
  name: format('{0}-{1}', take('${deployment().name}', 57), 'workbook')<br>
  params: {<br>
    name: 'wb-myworkbook-dev'<br>
    displayName: 'My Application Workbook'<br>
    category: 'workbook'<br>
    location: location<br>
    serializedData: loadTextContent('myworkbook.json')<br>
    sourceId: resourceId('Microsoft.Insights/components', 'myAppInsights')<br>
    version: 'Notebook/1.0'<br>
  }<br>
}<br>
</pre><br>
<p>Creates an Azure Monitor Workbook with custom visualization and analysis capabilities. The workbook is deployed to a resource group and requires a category, displayName, and serializedData containing valid JSON configuration.</p>

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| category | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | Workbook category, as defined by the user at creation time. |
| displayName | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | The user-defined name (display name) of the workbook. |
| identity | object? | <input type="checkbox" checked> | None | <pre></pre> | Identity used for BYOS (Bring Your Own Storage). |
| kind | resourceInput<'Microsoft.Insights/workbooks@2023-06-01'>.kind | <input type="checkbox"> | None | <pre>'shared'</pre> | Optional workbook kind. Only "shared" is supported currently. |
| location | string | <input type="checkbox" checked> | None | <pre></pre> | The geo-location where the resource lives. |
| name | string | <input type="checkbox" checked> | Length between 1-260 | <pre></pre> | The resource name. |
| serializedData | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | Configuration of this particular workbook. Configuration data is a string containing valid JSON. |
| sourceId | string? | <input type="checkbox" checked> | None | <pre></pre> | ResourceId for a source resource. |
| storageUri | string? | <input type="checkbox" checked> | None | <pre></pre> | The resourceId to the storage account when bring your own storage is used. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs. Resource may inherit tags from the ResourceGroup instead.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| version | string? | <input type="checkbox" checked> | None | <pre></pre> | Workbook schema version format, like ```Notebook/1.0``` which should match the workbook in serializedData. |
| workbookDescription | string? | <input type="checkbox" checked> | None | <pre></pre> | The description of the workbook. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| workbookId | string | The resource ID of the workbook. |
| workbookName | string | The name of the workbook. |

## Links
- [Bicep Workbooks](https://learn.microsoft.com/en-us/azure/templates/microsoft.insights/workbooks?pivots=deployment-language-bicep)
