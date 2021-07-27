[[_TOC_]]

# Description

This snippet creates a new authorization rule for either a ServiceBus Namespace, Queue or Topic.

# Parameters

| Parameter                               | Required                      | Example Value                               | Description                                                                                                                                                                       |
| --------------------------------------- | ------------------------------| ------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ServiceBusAuthorizationRuleName       | <input type="checkbox" checked> | `SendListenSharedAccessKey`                 | The name of the authorization rule.                                                                                                                                               |
| ServiceBusNamespaceResourceGroupName  | <input type="checkbox" checked> | `$(ServiceBusNamespaceResourceGroupName)`   | The name of the resource group the ServiceBus is in.                                                                                                                              |
| ServiceBusNamespaceName               | <input type="checkbox" checked> | `$(ServiceBusNamespaceName)`                | The name for the ServiceBus Namespace.                                                                                                                                            |
| ServiceBusQueueName                   | <input type="checkbox">         | `somequeuename`                             | The Queue name to apply this auth rule to. Use either ServiceBusQueueName, ServiceBusTopicName or none. Is no Queue or Topic is passed, the rule is applied to the Namespace      |
| ServiceBusTopicName                   | <input type="checkbox">         | `sometopicname`                             | The Topic name to apply this auth rule to. Use either ServiceBusQueueName, ServiceBusTopicName or none. Is no Queue or Topic is passed, the rule is applied to the Namespace      |
| ServiceBusAuthRights                  | <input type="checkbox">         | `Send,Listen`                               | Array of rights for the selected entity. Possible values: Manage, Send, Listen.             |


# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
            - task: AzureCLI@2
              displayName: "Create ServiceBus Namespace AuthRule"
              condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
              inputs:
                azureSubscription: "${{ parameters.SubscriptionName }}"
                scriptType: pscore
                scriptPath: "$(Pipeline.Workspace)/AzDocs/ServiceBus/Create-ServiceBus-Authorization-Rule.ps1"
                arguments: "-ServiceBusAuthorizationRuleName SendListenSharedAccessKey -ServiceBusNamespaceName '$(ServiceBusNamespaceName)' -ServiceBusNamespaceResourceGroupName '$(ServiceBusNamespaceResourceGroupName)' -ServiceBusQueueName '$(ServiceBusQueueName)' -ServiceBusTopicName '$(ServiceBusTopicName)' -ServiceBusAuthRights Send,Listen"
```

# Code

[Click here to download this script](../../../../src/ServiceBus/Create-ServiceBus-Authorization-Rule.ps1)

# Links

[Azure CLI - az servicebus namespace authorization-rule create](https://docs.microsoft.com/nl-nl/cli/azure/servicebus/namespace/authorization-rule?view=azure-cli-latest#az_servicebus_namespace_authorization_rule_create)

[Azure CLI - az servicebus queue authorization-rule create](https://docs.microsoft.com/nl-nl/cli/azure/servicebus/queue/authorization-rule?view=azure-cli-latest#az_servicebus_queue_authorization_rule_create)

[Azure CLI - az servicebus topic authorization-rule create](https://docs.microsoft.com/nl-nl/cli/azure/servicebus/topic/authorization-rule?view=azure-cli-latest#az_servicebus_topic_authorization_rule_create)
