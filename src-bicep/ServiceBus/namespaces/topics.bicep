/*
.SYNOPSIS
Creating a Topic inside of a servicebus namespace
.DESCRIPTION
Creating a Topic resource with the given specs inside of a servicebus namespace.
.EXAMPLE
<pre>
module topic 'br:contosoregistry.azurecr.io/servicebus/namespaces/topics:latest' = {
  name: '${take(deployment().name, 10)}-topic-${topicName}'
  params: {
    autoDeleteOnIdle: autoDeleteOnIdle
    defaultMessageTimeToLive: defaultMessageTimeToLive
    duplicateDetectionHistoryTimeWindow: duplicateDetectionHistoryTimeWindow
    enableBatchedOperations: enableBatchedOperations
    enableExpress: enableExpress
    enablePartitioning: enablePartitioning
    maxSizeInMegabytes: maxSizeInMegabytes
    maxMessageSizeInKilobytes: maxMessageSizeInKilobytes
    requiresDuplicateDetection: requiresDuplicateDetection
    status: status
    supportOrdering: supportOrdering
  }
}
</pre>
<p>Creating a Topic inside of a servicebus namespace with the name 'topicname'</p>
.LINKS
- [Bicep Microsoft.ServiceBus/Namespaces/Topics](https://learn.microsoft.com/en-us/azure/templates/microsoft.servicebus/namespaces/topics?pivots=deployment-language-bicep)
*/

@description('Type representing the status of a messaging entity.')
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

@description('ISO 8601 timespan idle interval after which the topic is automatically deleted. The minimum duration is 5 minutes.')
@minLength(1)
param autoDeleteOnIdle string

@description('ISO 8601 Default message timespan to live value. This is the duration after which the message expires, starting from when the message is sent to Service Bus. This is the default value used when TimeToLive is not set on a message itself.')
@minLength(1)
param defaultMessageTimeToLive string

@description('ISO8601 timespan structure that defines the duration of the duplicate detection history. The default value is 10 minutes.')
@minLength(1)
param duplicateDetectionHistoryTimeWindow string = 'PT10M'

@description('Value that indicates whether server-side batched operations are enabled.')
param enableBatchedOperations bool

@description('Value that indicates whether Express Entities are enabled. An express topic holds a message in memory temporarily before writing it to persistent storage.')
param enableExpress bool

@description('Value that indicates whether the topic to be partitioned across multiple message brokers is enabled.')
param enablePartitioning bool

@description('Maximum size (in KB) of the message payload that can be accepted by the topic. This property is only used in Premium today and default is 1024.')
param maxMessageSizeInKilobytes int = 1024

@description('Maximum size of the topic in megabytes, which is the size of the memory allocated for the topic. Default is 1024.')
param maxSizeInMegabytes int = 1024

@description('Value indicating if this topic requires duplicate detection.')
param requiresDuplicateDetection bool

@description('Enumerates the possible values for the status of a messaging entity.')
param status statusType = 'Active'

@description('Value that indicates whether the topic supports ordering.')
param supportOrdering bool

resource servicebusNamespace 'Microsoft.ServiceBus/namespaces@2022-01-01-preview' existing = {
  name: serviceBusNamespaceName
}

// Create the topic properties
// If the namespace is premium, the maxMessageSizeInKilobytes property is included. Only premium namespaces support this property.
var properties = union(
  {
    autoDeleteOnIdle: autoDeleteOnIdle
    defaultMessageTimeToLive: defaultMessageTimeToLive
    duplicateDetectionHistoryTimeWindow: duplicateDetectionHistoryTimeWindow
    enableBatchedOperations: enableBatchedOperations
    enableExpress: enableExpress
    enablePartitioning: enablePartitioning
    maxSizeInMegabytes: maxSizeInMegabytes
    requiresDuplicateDetection: requiresDuplicateDetection
    status: status
    supportOrdering: supportOrdering
  },
  servicebusNamespace.sku.name == 'Premium' ? { maxMessageSizeInKilobytes: maxMessageSizeInKilobytes } : {}
)

resource topic 'Microsoft.ServiceBus/namespaces/topics@2022-01-01-preview' = {
  name: topicName
  parent: servicebusNamespace
  properties: properties
}

@description('The resource id of the topic.')
output topicResourceId string = topic.id
