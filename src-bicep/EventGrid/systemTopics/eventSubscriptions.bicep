/*
.SYNOPSIS
Creating a event subscription inside of a Event Grid System Topic resource
.DESCRIPTION
Creating a event subscription inside of a Event Grid System Topic resource with the given specs.
.EXAMPLE
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
.LINKS
- [Bicep Microsoft.EventGrid/systemTopics/eventSubscriptions](https://learn.microsoft.com/en-us/azure/templates/microsoft.eventgrid/systemtopics/eventsubscriptions)
*/

@description('The name of this Event Grid System Topic resource.')
@minLength(3)
@maxLength(50)
param eventGridNamespaceName string

@description('The name of this Event Subscription subresource.')
@minLength(3)
@maxLength(64)
param eventSubscriptionName string

@description('Information about the destination where events have to be delivered for the event subscription. Uses the managed identity setup on the parent resource (namely, topic or domain) to acquire the authentication tokens being used during delivery / dead-lettering. For objectstructure please visit the [documentation](https://learn.microsoft.com/en-us/azure/templates/microsoft.eventgrid/systemtopics/eventsubscriptions?pivots=deployment-language-bicep#deliverywithresourceidentity).')
param deliveryWithResourceIdentity object = {}

@description('Information about the filter for the event subscription. For objectstructure please visit the [documentation](https://learn.microsoft.com/en-us/azure/templates/microsoft.eventgrid/systemtopics/eventsubscriptions?pivots=deployment-language-bicep#eventsubscriptionfilter).')
param filter object

@allowed([
  'CloudEventSchemaV1_0'
  'CustomInputSchema'
  'EventGridSchema'
])
@description('The event delivery schema for the event subscription.')
param eventDeliverySchema string = 'EventGridSchema'

@description('Maximum number of delivery retry attempts for events.')
param retryPolicyMaxDeliveryAttempts int = 30

@description('Time To Live (in minutes) for events.')
param retryPolicyEventTimeToLiveInMinutes int = 1440

resource systemTopic 'Microsoft.EventGrid/systemTopics@2022-06-15' existing = {
  name: eventGridNamespaceName
}

resource eventSubscription 'Microsoft.EventGrid/systemTopics/eventSubscriptions@2022-06-15' = {
  name: eventSubscriptionName
  parent: systemTopic
  properties: {
    deliveryWithResourceIdentity: deliveryWithResourceIdentity
    filter: filter
    eventDeliverySchema: eventDeliverySchema
    retryPolicy: {
      maxDeliveryAttempts: retryPolicyMaxDeliveryAttempts
      eventTimeToLiveInMinutes: retryPolicyEventTimeToLiveInMinutes
    }
  }
}
