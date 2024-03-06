# systemTopics

Target Scope: resourceGroup

## Synopsis
Creating a Event Grid System Topic resource

## Description
Creating a Event Grid System Topic resource with the given specs.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| eventGridNamespaceName | string | <input type="checkbox" checked> | Length between 3-50 | <pre></pre> | The name of this Event Grid System Topic resource. |
| location | string | <input type="checkbox"> | None | <pre>'global'</pre> | Specifies the Azure location where the resource should be created. Defaults \'global\'. |
| identity | object | <input type="checkbox"> | None | <pre>{<br>  type: 'SystemAssigned'<br>}</pre> | Managed service identity to use for this Resource. Defaults to a system assigned managed identity. For object format, refer to [documentation](https://learn.microsoft.com/en-us/azure/templates/microsoft.eventgrid/systemtopics?pivots=deployment-language-bicep#identityinfo). |
| eventSource | string | <input type="checkbox"> | None | <pre>az.subscription().id</pre> | The source (resource id) of the events. Defaults to the subscription resource id |
| eventTopicType | string | <input type="checkbox"> | None | <pre>'Microsoft.Resources.Subscriptions'</pre> | The topic type to subscribe to. Defaults to Microsoft.Resources.Subscriptions. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| identityPrincipalId | string |  |

## Examples
<pre>
module systemTopic 'br:contosoregistry.azurecr.io/eventgrid/systemTopics:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 50), 'topic')
  scope: resourceGroup
  params: {
    eventGridNamespaceName: eventGridNamespaceName
    location: 'global'
    eventSource: az.subscription().id
    eventTopicType: 'Microsoft.Resources.Subscriptions'
  }
}
</pre>
<p>Creating a Event Grid System Topic resource with the name eventGridNamespaceName</p>

## Links
- [Bicep Microsoft.EventGrid/systemTopics](https://learn.microsoft.com/en-us/azure/templates/microsoft.eventgrid/systemtopics?pivots=deployment-language-bicep)
