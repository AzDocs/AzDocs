# topics

Target Scope: resourceGroup

## User Defined Types
| Name | Type | Discriminator | Description
| -- |  -- | -- | -- |
| <a id="statusType">statusType</a>  | <pre>'Active'</pre> |  | Type representing the status of a messaging entity. | 

## Synopsis
Creating a Topic inside of a servicebus namespace

## Description
Creating a Topic resource with the given specs inside of a servicebus namespace.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| serviceBusNamespaceName | string | <input type="checkbox" checked> | Length between 6-50 | <pre></pre> | <br>Character limit: 6-50<br><br>Valid characters: Alphanumerics and hyphens.<br> |
| topicName | string | <input type="checkbox" checked> | Length between 1-260 | <pre></pre> | Character limit: 1-260<br><br>Valid characters:<br>Alphanumerics, periods, hyphens, underscores, and slashes.<br><br>Start and end with alphanumeric. |
| autoDeleteOnIdle | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | ISO 8601 timespan idle interval after which the topic is automatically deleted. The minimum duration is 5 minutes. |
| defaultMessageTimeToLive | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | ISO 8601 Default message timespan to live value. This is the duration after which the message expires, starting from when the message is sent to Service Bus. This is the default value used when TimeToLive is not set on a message itself. |
| duplicateDetectionHistoryTimeWindow | string | <input type="checkbox"> | Length between 1-* | <pre>'PT10M'</pre> | ISO8601 timespan structure that defines the duration of the duplicate detection history. The default value is 10 minutes. |
| enableBatchedOperations | bool | <input type="checkbox" checked> | None | <pre></pre> | Value that indicates whether server-side batched operations are enabled. |
| enableExpress | bool | <input type="checkbox" checked> | None | <pre></pre> | Value that indicates whether Express Entities are enabled. An express topic holds a message in memory temporarily before writing it to persistent storage. |
| enablePartitioning | bool | <input type="checkbox" checked> | None | <pre></pre> | Value that indicates whether the topic to be partitioned across multiple message brokers is enabled. |
| maxMessageSizeInKilobytes | int | <input type="checkbox"> | None | <pre>1024</pre> | Maximum size (in KB) of the message payload that can be accepted by the topic. This property is only used in Premium today and default is 1024. |
| maxSizeInMegabytes | int | <input type="checkbox"> | None | <pre>1024</pre> | Maximum size of the topic in megabytes, which is the size of the memory allocated for the topic. Default is 1024. |
| requiresDuplicateDetection | bool | <input type="checkbox" checked> | None | <pre></pre> | Value indicating if this topic requires duplicate detection. |
| status | [statusType](#statusType) | <input type="checkbox"> | None | <pre>'Active'</pre> | Enumerates the possible values for the status of a messaging entity. |
| supportOrdering | bool | <input type="checkbox" checked> | None | <pre></pre> | Value that indicates whether the topic supports ordering. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| topicResourceId | string | The resource id of the topic. |

## Examples
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

## Links
- [Bicep Microsoft.ServiceBus/Namespaces/Topics](https://learn.microsoft.com/en-us/azure/templates/microsoft.servicebus/namespaces/topics?pivots=deployment-language-bicep)
