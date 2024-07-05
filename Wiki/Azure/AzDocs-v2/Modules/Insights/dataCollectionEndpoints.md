# dataCollectionEndpoints

Target Scope: resourceGroup

## User Defined Types
| Name | Type | Discriminator | Description
| -- |  -- | -- | -- |
| <a id="identityType">identityType</a>  | <pre>{ type: 'None' } &#124; { type: 'SystemAssigned' } &#124; { type: 'UserAssigned', userAssignedIdentities: object }</pre> | type | The identity type. This can be either `None`, a `System Assigned` or a `UserAssigned` identity. In the case of UserAssigned, the userAssignedIdentities must be set with the ResourceId of the user assigned identity resource and the identity must have at least read logs rbac rights on the resource in scope. | 

## Synopsis
Creating a data collection endpoint.

## Description
Creating a data collection endpoint (DCE). A data collection endpoint (DCE) is a connection where data sources send collected data for processing and ingestion into Azure Monitor.<br>
DCE is as a connector between the endpoint and Azure Log Ingestion Pipeline. DCE is required in 2 occasions: 1) You need network isolation, 2) You are sending data to custom logs in Azure LogAnalytics.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | The location for this resource to be upserted in. |
| dataCollectionEndpointName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the data collection endpoint. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| identity | [identityType](#identityType) | <input type="checkbox"> | None | <pre>{<br>  type: 'None'<br>}</pre> | Sets the identity. This can be either `None`, a `System Assigned` or a `UserAssigned` identity.<br>Defaults no identity.<br>If type is `UserAssigned`, then userAssignedIdentities must be set with the ResourceId of the user assigned identity resource<br>and the identity must have at least read logs rbac rights on the resource in scope.<br><details><br>&nbsp;&nbsp;&nbsp;<summary>Click to show example</summary><br><pre><br>{<br>&nbsp;&nbsp;&nbsp;type: 'UserAssigned'<br>&nbsp;&nbsp;&nbsp;userAssignedIdentities: userAssignedIdentityId :{}<br>},<br>{<br>&nbsp;&nbsp;&nbsp;type: 'SystemAssigned'<br>},<br>{<br>&nbsp;&nbsp;&nbsp;type: 'None'<br>}<br></pre><br></details> |
| dataCollectionEndpointDescription | string | <input type="checkbox"> | None | <pre>'Data Collection Endpoint'</pre> | The data collection endpoint description. |
| publicNetworkAccess | string | <input type="checkbox"> | `'Enabled'` or `'Disabled'` or `'SecuredByPerimeter'` | <pre>'Enabled'</pre> | The configuration to set whether network access from public internet to the endpoints is allowed. You can use Azure Monitor Private Link Scopes to restrict access to the endpoint (SecureByPerimeter). |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| dataCollectionEndpointUri | string | The logs ingestion URI for the DataCollectionRule. |
| dataCollectionEndpointImmutableId | string | The immutableId property of the DCE object |
| dataCollectionEndpointConfigurationAccess | string | The configurationAccess property of the DCE object |
| dataCollectionEndpointMetricsIngestion | string | The metricsIngestion property of the DCE object |
| dataCollectionEndpointId | string | The DCE resourceId. |

## Examples
<pre>
module dcendpoint 'br:contosoregistry.azurecr.io/insights/datacollectionendpoints:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 60), 'dce')
  params: {
    dataCollectionEndpointName: 'dcename'
  }
}
</pre>
<p>Creates a data collection endpoint in Azure Monitor.</p>

## Links
- [Bicep Data Collection Endpoints](https://learn.microsoft.com/en-us/azure/templates/microsoft.insights/datacollectionendpoints?pivots=deployment-language-bicep)
