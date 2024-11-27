/*
.SYNOPSIS
Creating a Subscription inside of a servicebus namespace topic
.DESCRIPTION
Creating a Subscription resource with the given specs inside of a servicebus namespace topic.
.EXAMPLE
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
.LINKS
- [Bicep Microsoft.ServiceBus/Namespaces/Topics/Subscriptions](https://learn.microsoft.com/en-us/azure/templates/microsoft.servicebus/namespaces/topics/subscriptions?pivots=deployment-language-bicep#sbclientaffineproperties)
*/

@description('The properties of the client-affine subscription.')
type clientAffinePropertiesType = {
  @description('Indicates the Client ID of the application that created the client-affine subscription.')
  clientId: string

  @description('For client-affine subscriptions, this value indicates whether the subscription is durable or not.')
  isDurable: bool

  @description('For client-affine subscriptions, this value indicates whether the subscription is shared or not.')
  isShared: bool
}

@description('Enumerates the possible values for the status of a messaging entity.')
type statusType =
  | 'Active'
  | 'Creating'
  | 'Deleting'
  | 'Disabled'
  | 'ReceiveDisabled'
  | 'Renaming'
  | 'Restoring'
  | 'SendDisabled'
  | 'Unknown'

@minLength(6)
@maxLength(50)
@description('''The name of the servicebus namespace. This will be the target servicebus where systemevents will be delivered.

Character limit: 6-50

Valid characters: Alphanumerics and hyphens.

Start with a letter. End with a letter or number.''')
param serviceBusNamespaceName string

@minLength(1)
@maxLength(260)
@description('''
Character limit: 1-260

Valid characters:
Alphanumerics, periods, hyphens, underscores, and slashes.

Start and end with alphanumeric.
''')
param topicName string

@minLength(1)
@maxLength(50)
@description('''
Character limit: 1-50

Valid characters:
Alphanumerics, periods, hyphens, and underscores.

Start and end with alphnumeric.
''')
param subscriptionName string

@description('ISO 8061 timeSpan idle interval after which the topic is automatically deleted. The minimum duration is 5 minutes.')
@minLength(1)
param autoDeleteOnIdle string

@description('Properties specific to client affine subscriptions.')
param clientAffineProperties clientAffinePropertiesType?

@description('Value that indicates whether a subscription has dead letter support on filter evaluation exceptions.')
param deadLetteringOnFilterEvaluationExceptions bool

@description('Value that indicates whether a subscription has dead letter support when a message expires.')
param deadLetteringOnMessageExpiration bool

@description('ISO 8061 Default message timespan to live value. This is the duration after which the message expires, starting from when the message is sent to Service Bus. This is the default value used when TimeToLive is not set on a message itself.')
param defaultMessageTimeToLive string

@description('ISO 8601 timeSpan structure that defines the duration of the duplicate detection history. The default value is 10 minutes.')
param duplicateDetectionHistoryTimeWindow string = 'PT10M'

@description('Value that indicates whether server-side batched operations are enabled.')
param enableBatchedOperations bool

@description('Topic name to forward the Dead Letter message.')
param forwardDeadLetteredMessagesTo string?

@description('Topic name to forward the messages.')
param forwardTo string?

@description('Value that indicates whether the subscription has an affinity to the client id.')
param isClientAffine bool

@description('ISO 8061 lock duration timespan for the subscription. The default value is 1 minute.')
param lockDuration string = 'PT1M'

@description('Number of maximum deliveries.')
param maxDeliveryCount int

@description('Value indicating if a subscription supports the concept of sessions.')
param requiresSession bool

@description('Enumerates the possible values for the status of a messaging entity.')
param status statusType = 'Active'

resource servicebusNamespace 'Microsoft.ServiceBus/namespaces@2022-01-01-preview' existing = {
  name: serviceBusNamespaceName
}

resource topic 'Microsoft.ServiceBus/namespaces/topics@2022-01-01-preview' existing = {
  name: topicName
  parent: servicebusNamespace
}

resource subscription 'Microsoft.ServiceBus/namespaces/topics/subscriptions@2022-01-01-preview' = {
  name: subscriptionName
  parent: topic
  properties: {
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
    status: status
  }
}

@description('The resource id of the subscription.')
output subscriptionResourceId string = subscription.id
