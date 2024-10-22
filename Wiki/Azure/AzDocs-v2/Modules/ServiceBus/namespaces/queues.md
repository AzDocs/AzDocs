# queues

Target Scope: resourceGroup

## Synopsis
Creating a Queue inside of a servicebus namespace

## Description
Creating a Queue resource with the given specs inside of a servicebus namespace.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| serviceBusNamespaceName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the servicebus namespace. |
| serviceBusQueueName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the servicebus queue. |
| lockDuration | string | <input type="checkbox"> | None | <pre>'PT1M'</pre> | ISO 8601 timespan duration of a peek-lock; that is, the amount of time that the message is locked for other receivers. The maximum value for LockDuration is 5 minutes; the default value is 1 minute. |

## Examples
<pre>
module queue 'br:contosoregistry.azurecr.io/servicebus/namespaces/queues:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 50), 'queue')
  scope: resourceGroup
  params: {
    serviceBusNamespaceName: serviceBusNamespaceName
    serviceBusQueueName: 'queuename'
  }
}
</pre>
<p>Creating a Queue inside of a servicebus namespace with the name 'queuename'</p>

## Links
- [Bicep Microsoft.ServiceBus/Namespaces/Queue](https://learn.microsoft.com/en-us/azure/templates/microsoft.servicebus/namespaces/queues?pivots=deployment-language-bicep)
