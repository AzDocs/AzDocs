# eventSubscriptions

Target Scope: resourceGroup

## Synopsis
Creating a event subscription inside of a Event Grid System Topic resource

## Description
Creating a event subscription inside of a Event Grid System Topic resource with the given specs.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| eventGridNamespaceName | string | <input type="checkbox" checked> | Length between 3-50 | <pre></pre> | The name of this Event Grid System Topic resource. |
| eventSubscriptionName | string | <input type="checkbox" checked> | Length between 3-64 | <pre></pre> | The name of this Event Subscription subresource. |
| deliveryWithResourceIdentity | object | <input type="checkbox"> | None | <pre>{}</pre> | Information about the destination where events have to be delivered for the event subscription. Uses the managed identity setup on the parent resource (namely, topic or domain) to acquire the authentication tokens being used during delivery / dead-lettering. For objectstructure please visit the [documentation](https://learn.microsoft.com/en-us/azure/templates/microsoft.eventgrid/systemtopics/eventsubscriptions?pivots=deployment-language-bicep#deliverywithresourceidentity). |
| filter | object | <input type="checkbox" checked> | None | <pre></pre> | Information about the filter for the event subscription. For objectstructure please visit the [documentation](https://learn.microsoft.com/en-us/azure/templates/microsoft.eventgrid/systemtopics/eventsubscriptions?pivots=deployment-language-bicep#eventsubscriptionfilter). |
| eventDeliverySchema | string | <input type="checkbox"> | `'CloudEventSchemaV1_0'` or  `'CustomInputSchema'` or  `'EventGridSchema'` | <pre>'EventGridSchema'</pre> | The event delivery schema for the event subscription. |
| retryPolicyMaxDeliveryAttempts | int | <input type="checkbox"> | None | <pre>30</pre> | Maximum number of delivery retry attempts for events. |
| retryPolicyEventTimeToLiveInMinutes | int | <input type="checkbox"> | None | <pre>1440</pre> | Time To Live (in minutes) for events. |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |
## Examples
<pre>
resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2022-01-01-preview' existing = {
  name: serviceBusNamespaceName
  scope: az.resourceGroup(serviceBusNamespaceSubscriptionId, serviceBusNamespaceResourceGroupName)

  resource queue 'queues@2022-10-01-preview' existing = {
    name: 'systemevents'
  }
}

module eventSubscription 'br:contosoregistry.azurecr.io/eventgrid/systemTopics/eventSubscriptions:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 50), 'eventsub')
  scope: resourceGroup
  params: {
    eventSubscriptionName: 'SomeSubscription'
    eventGridNamespaceName: eventGridNamespaceName
    deliveryWithResourceIdentity: {
      identity: {
        type: 'SystemAssigned'
      }
      destination: {
        endpointType: 'ServiceBusQueue'
        properties: {
          resourceId: serviceBusNamespace::queue.id // Reference to an servicebus queue bicep resource id
        }
      }
    }
    filter: {
      includedEventTypes: [
        'Microsoft.Resources.ResourceWriteSuccess'
      ]
      enableAdvancedFilteringOnArrays: true
      advancedFilters: [
        {
          values: [
            'Microsoft.Resources/subscriptions/resourceGroups/write'
            'Microsoft.Authorization/roleAssignments/write'
          ]
          operatorType: 'StringIn'
          key: 'data.operationName'
        }
      ]
    }
  }
}
</pre>
<p>Creating a event subscription inside of a Event Grid System Topic resource with the name 'SomeSubscription'</p>

## Links
- [Bicep Microsoft.EventGrid/systemTopics/eventSubscriptions](https://learn.microsoft.com/en-us/azure/templates/microsoft.eventgrid/systemtopics/eventsubscriptions)


