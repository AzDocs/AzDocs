[[_TOC_]]

# Description

This snippet will create a ServiceBus queue if it does not exist.

# Parameters

Some parameters from [General Parameter](/Azure/AzDocs-v1/Scripts) list.

| Parameter                                 | Required                        | Example Value                                    | Description                                                                                                                                                                                                                               |
| ----------------------------------------- | ------------------------------- | ------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ServiceBusNamespaceResourceGroupName      | <input type="checkbox" checked> | `myteam-shared-$(Release.EnvironmentName)`       | ResourceGroupName where the ServiceBus Namespace should be created                                                                                                                                                                        |
| ServiceBusNamespaceName                   | <input type="checkbox" checked> | `myteam-servicebusns-$(Release.EnvironmentName)` | This is the ServiceBus Namespace name to use.                                                                                                                                                                                             |
| QueueName                                 | <input type="checkbox" checked> | `MyQueueName`                                    | The name of the queue.                                                                                                                                                                                                                    |
| MaxSize                                   | <input type="checkbox" checked> | 5120                                             | The maximum size of the service bus queue. You can select the following values: 1024, 10240, 2048, 20480, 3072, 4096, 40960, 5120, 81920. Please note some the options above 5120 are only available on the Premium SKU.                  |
| MaxDeliveryCount                          | <input type="checkbox" checked> | 10                                               | The amount of times a 'failed' message will be sent to a consumer for processing again before moving to the deadletter queue.                                                                                                             |
| EnableBatchedOperations                   | <input type="checkbox">         | $true                                            | [More information on batched operations](https://learn.microsoft.com/en-us/azure/service-bus-messaging/service-bus-performance-improvements?tabs=net-standard-sdk-2#batching-store-access). Defaults to true.                              |
| EnableDeadletteringOnMessageExpiration    | <input type="checkbox">         | $true                                            | [More information on Time-to-live](https://learn.microsoft.com/en-us/azure/service-bus-messaging/service-bus-dead-letter-queues#time-to-live). Defaults to true.                                                                           |
| EnablePartitioning                        | <input type="checkbox">         | $false                                           | [More information on partitioned queues](https://learn.microsoft.com/en-us/azure/service-bus-messaging/service-bus-partitioning). Defaults to false.                                                                                       |
| EnableSessions                            | <input type="checkbox">         | $true                                            | [More information on message sessions](https://learn.microsoft.com/en-us/azure/service-bus-messaging/message-sessions). Defaults to true.                                                                                                 |


# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Create ServiceBus Queue"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/ServiceBus/Create-ServiceBus-Queue.ps1"
    arguments: "-ServiceBusNamespaceName '$(ServiceBusNamespaceName)' -ServiceBusNamespaceResourceGroupName '$(ServiceBusNamespaceResourceGroupName)' -QueueName '$(QueueName)' -MaxSize $(MaxSize) -MaxDeliveryCount $(MaxDeliveryCount) -EnableBatchedOperations $(EnableBatchedOperations) -EnableDeadletteringOnMessageExpiration $(EnableDeadletteringOnMessageExpiration) -EnablePartitioning $(EnablePartitioning) -EnableSessions $(EnableSessions)"
```

# Code

[Click here to download this script](../../../../src/ServiceBus/Create-ServiceBus-Queue.ps1)

# Links

[Azure CLI - az servicebus queue create](https://learn.microsoft.com/en-us/cli/azure/servicebus/queue?view=azure-cli-latest#az-servicebus-queue-create)

[Azure CLI - az servicebus queue update](https://learn.microsoft.com/en-us/cli/azure/servicebus/queue?view=azure-cli-latest#az-servicebus-queue-update)