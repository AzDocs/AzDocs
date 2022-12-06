[[_TOC_]]

# Description

This snippet will create an authorization rule for a ServiceBus queue if it does not exist.

# Parameters

Some parameters from [General Parameter](/Azure/AzDocs-v1/Scripts) list.

| Parameter                                 | Required                        | Example Value                                    | Description                                                                                                                                                                                                                               |
| ----------------------------------------- | ------------------------------- | ------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ServiceBusNamespaceResourceGroupName      | <input type="checkbox" checked> | `myteam-shared-$(Release.EnvironmentName)`       | ResourceGroupName where the ServiceBus Namespace should be created                                                                                                                                                                        |
| ServiceBusNamespaceName                   | <input type="checkbox" checked> | `myteam-servicebusns-$(Release.EnvironmentName)` | This is the ServiceBus Namespace name to use.                                                                                                                                                                                             |
| QueueName                                 | <input type="checkbox" checked> | `MyQueueName`                                    | The name of the queue.                                                                                                                                                                                                                    |
| RuleName                                  | <input type="checkbox" checked> | `MyRule`                                         | The name of the rule.                                                                                                                                                                                                                     |
| GrantSend                                 | <input type="checkbox">         | $true                                            | Grant the Send permission. Defaults to false.                              |
| GrantListen                               | <input type="checkbox">         | $true                                            | Grant the Listen permission. Defaults to false.                                                                        |
| GrantManage                               | <input type="checkbox">         | $false                                           | Grants the Manage permission. When setting this permission you automatically grant Send and Listen permission. Defaults to false.                                                                                       |


# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Create ServiceBus Queue Authorization Rule"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/ServiceBus/Create-ServiceBus-Queue-Authorization-Rule.ps1"
    arguments: "-ServiceBusNamespaceName '$(ServiceBusNamespaceName)' -ServiceBusNamespaceResourceGroupName '$(ServiceBusNamespaceResourceGroupName)' -QueueName '$(QueueName)' -RuleName '$(RuleName)' -GrantSend $true -GrantListen $true -GrantManage $true"
```

# Code

[Click here to download this script](../../../../src/ServiceBus/Create-ServiceBus-Queue-Authorization-Rule.ps1)

# Links

[Azure CLI - az servicebus queue authorization-rule create](https://learn.microsoft.com/en-us/cli/azure/servicebus/queue/authorization-rule?view=azure-cli-latest#az-servicebus-queue-authorization-rule-create)

[Azure CLI - az servicebus queue authorization-rule update](https://learn.microsoft.com/en-us/cli/azure/servicebus/queue/authorization-rule?view=azure-cli-latest#az-servicebus-queue-authorization-rule-update)