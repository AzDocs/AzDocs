# subscriptions

Target Scope: resourceGroup

## User Defined Types
| Name | Type | Discriminator | Description
| -- |  -- | -- | -- |
| <a id="clientAffinePropertiesType">clientAffinePropertiesType</a>  | <pre>{</pre> |  | The properties of the client-affine subscription. | 

## Synopsis
Creating a Subscription inside of a servicebus namespace topic

## Description
Creating a Subscription resource with the given specs inside of a servicebus namespace topic.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| serviceBusNamespaceName | string | <input type="checkbox" checked> | Length between 6-50 | <pre></pre> | <br>Character limit: 6-50<br><br>Valid characters: Alphanumerics and hyphens.<br> |
| topicName | string | <input type="checkbox" checked> | Length between 1-260 | <pre></pre> | Character limit: 1-260<br><br>Valid characters:<br>Alphanumerics, periods, hyphens, underscores, and slashes.<br><br>Start and end with alphanumeric. |
| subscriptionName | string | <input type="checkbox" checked> | Length between 1-50 | <pre></pre> | Character limit: 1-50<br><br>Valid characters:<br>Alphanumerics, periods, hyphens, and underscores.<br><br>Start and end with alphnumeric. |
| autoDeleteOnIdle | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | ISO 8061 timeSpan idle interval after which the topic is automatically deleted. The minimum duration is 5 minutes. |
| clientAffineProperties | clientAffinePropertiesType? | <input type="checkbox" checked> | None | <pre></pre> | Properties specific to client affine subscriptions. |
| deadLetteringOnFilterEvaluationExceptions | bool | <input type="checkbox" checked> | None | <pre></pre> | Value that indicates whether a subscription has dead letter support on filter evaluation exceptions. |
| deadLetteringOnMessageExpiration | bool | <input type="checkbox" checked> | None | <pre></pre> | Value that indicates whether a subscription has dead letter support when a message expires. |
| defaultMessageTimeToLive | string | <input type="checkbox" checked> | None | <pre></pre> | ISO 8061 Default message timespan to live value. This is the duration after which the message expires, starting from when the message is sent to Service Bus. This is the default value used when TimeToLive is not set on a message itself. |
| duplicateDetectionHistoryTimeWindow | string | <input type="checkbox"> | None | <pre>'PT10M'</pre> | ISO 8601 timeSpan structure that defines the duration of the duplicate detection history. The default value is 10 minutes. |
| enableBatchedOperations | bool | <input type="checkbox" checked> | None | <pre></pre> | Value that indicates whether server-side batched operations are enabled. |
| forwardDeadLetteredMessagesTo | string? | <input type="checkbox" checked> | None | <pre></pre> | Topic name to forward the Dead Letter message. |
| forwardTo | string? | <input type="checkbox" checked> | None | <pre></pre> | Topic name to forward the messages. |
| isClientAffine | bool | <input type="checkbox" checked> | None | <pre></pre> | Value that indicates whether the subscription has an affinity to the client id. |
| lockDuration | string | <input type="checkbox"> | None | <pre>'PT1M'</pre> | ISO 8061 lock duration timespan for the subscription. The default value is 1 minute. |
| maxDeliveryCount | int | <input type="checkbox" checked> | None | <pre></pre> | Number of maximum deliveries. |
| requiresSession | bool | <input type="checkbox" checked> | None | <pre></pre> | Value indicating if a subscription supports the concept of sessions. |
| status | string | <input type="checkbox" checked> | `'Active'` or `'Creating'` or `'Deleting'` or `'Disabled'` or `'ReceiveDisabled'` or `'Renaming'` or `'Restoring'` or `'SendDisabled'` or `'Unknown'` | <pre></pre> | Enumerates the possible values for the status of a messaging entity. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| subscriptionResourceId | string | The resource id of the subscription. |

## Examples
<pre>
module subscription 'br:contosoregistry.azurecr.io/servicebus/namespaces/topics/subscriptions:latest' = {
  name: '${take(deployment().name, 10)}-${take('topic-${topicName}', 20)}-${take('subscription-${subscriptionName}', 32)}'
  params: {
    autoDeleteOnIdle: autoDeleteOnIdle
    clientAffineProperties: clientAffineProperties
    deadLetteringOnFilterEvaluationExceptions: deadLetteringOnFilterEvaluationExceptions
    deadLetteringOnMessageExpiration: deadLetteringOnMessageExpiration
    defaultMessageTimeToLive: defaultMessageTimeToLive
    duplicateDetectionHistoryTimeWindow: duplicateDetectionHistoryTimeWindow
    enableBatchedOperations: enableBatchedOperations
    forwardDeadLetteredMessagesTo: forwardDeadLetteredMessagesTo
    forwardTo: forwardTo
    isClientAffine: isClientAffine
    lockDuration: lockDuration
    maxDeliveryCount: maxDeliveryCount
    requiresSession: requiresSession
    serviceBusNamespaceName: serviceBusNamespaceName
    status: status
    subscriptionName: subscriptionName
    topicName: topicName
  }
}

</pre>
<p>Creating a Subscription inside of a servicebus namespace topic with the name 'subscriptionname'</p>

## Links
- [Bicep Microsoft.ServiceBus/Namespaces/Topics/Subscriptions](https://learn.microsoft.com/en-us/azure/templates/microsoft.servicebus/namespaces/topics/subscriptions?pivots=deployment-language-bicep#sbclientaffineproperties)
