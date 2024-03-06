# workspaces

Target Scope: resourceGroup

## Synopsis
Creating a  a Log Analytics Workspace.

## Description
Creating a  a Log Analytics Workspace.<br>
<pre><br>
module origin 'br:contosoregistry.azurecr.io/operationalinsights/workspaces.bicep' = {<br>
  name: format('{0}-{1}', take('${deployment().name}', 51), 'loganalytics')<br>
  params: {<br>
    logAnalyticsWorkspaceName: 'workspacename'<br>
    location: location<br>
    retentionInDays: 30<br>
  }<br>
}<br>
</pre><br>
<p>Creates a Log Analytics Workspace with the name workspacename.</p>

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| logAnalyticsWorkspaceName | string | <input type="checkbox" checked> | Length between 4-63 | <pre></pre> | Specifies the name of the Log Analytics workspace. |
| sku | string | <input type="checkbox"> | `'CapacityReservation'` or `'Free'` or `'LACluster'` or `'PerGB2018'` or `'PerNode'` or `'Premium'` or `'Standalone'` or `'Standard'` | <pre>'PerNode'</pre> | Specifies the service tier of the workspace |
| capacityReservationLevel | int | <input type="checkbox"> | `-1` or `0` or `100` or `200` or `300` or `400` or `500` or `1000` or `2000` or `5000` or `10000` or `25000` or `50000` | <pre>-1</pre> | Specifies the capacity reservation level for this workspace. This is only applicable when the Sku is CapacityReservation. Default value is -1 which means no capacity reservation. |
| retentionInDays | int | <input type="checkbox"> | Value between -1-730 | <pre>60</pre> | Specifies the workspace data retention in days. -1 means Unlimited retention for the Unlimited Sku. 730 days is the maximum allowed for all other Skus. |
| disableLocalAuth | bool | <input type="checkbox"> | None | <pre>true</pre> | Flag that indicates if local auth should be disabled. |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location. |
| publicNetworkAccessForIngestion | string | <input type="checkbox"> | `'Disabled'` or `'Enabled'` | <pre>'Enabled'</pre> | Specifies the public network access type for accessing Log Analytics ingestion. |
| publicNetworkAccessForQuery | string | <input type="checkbox"> | `'Disabled'` or `'Enabled'` | <pre>'Enabled'</pre> | Specifies the public network access type for accessing Log Analytics query. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| enableLogAccessUsingOnlyResourcePermissions | bool | <input type="checkbox"> | None | <pre>true</pre> | Flag that indicates which permission to use - resource or workspace or both. True means: Use resource or workspace permissions. |
| enableDataExport | bool | <input type="checkbox"> | None | <pre>false</pre> | Flag that indicate if data should be exported. |
| workspaceCappingDailyQuotaGb | int | <input type="checkbox"> | None | <pre>-1</pre> | Workspace capping daily quota in GB. -1 means unlimited. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| logAnalyticsWorkspaceResourceId | string | Outputs the Log Analytics Workspace Resource ID. |
| logAnalyticsWorkspaceResourceName | string | Outputs the Log Analytics Workspace Resource Name. |
| logAnalyticsWorkspaceCustomerId | string | Outputs the Log Analytics Workspace Customer ID. |
| logAnalyticsWorkspacePrimaryKey | string |  |

## Links
- [Bicep Microsoft.OperationalInsights workspaces](https://learn.microsoft.com/en-us/azure/templates/microsoft.operationalinsights/workspaces?pivots=deployment-language-bicep)
