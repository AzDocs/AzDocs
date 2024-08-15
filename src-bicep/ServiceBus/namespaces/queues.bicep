/*
.SYNOPSIS
Creating a Queue inside of a servicebus namespace
.DESCRIPTION
Creating a Queue resource with the given specs inside of a servicebus namespace.
.EXAMPLE
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
.LINKS
- [Bicep Microsoft.ServiceBus/Namespaces/Queue](https://learn.microsoft.com/en-us/azure/templates/microsoft.servicebus/namespaces/queues?pivots=deployment-language-bicep)
*/

@description('The name of the servicebus namespace.')
param serviceBusNamespaceName string

@description('The name of the servicebus queue.')
param serviceBusQueueName string

resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2022-01-01-preview' existing = {
  name: serviceBusNamespaceName
}

resource queue 'Microsoft.ServiceBus/namespaces/queues@2022-10-01-preview' = {
  name: serviceBusQueueName
  parent: serviceBusNamespace
}
