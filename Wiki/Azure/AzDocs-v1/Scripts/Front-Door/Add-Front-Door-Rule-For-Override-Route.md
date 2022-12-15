[[_TOC_]]

# Description

Create a rule set and add a rule specifically for overriding a route to the Azure Front Door profile. 

# Parameters

## General
| Parameter              | Required                        | Example Value                   | Description                                                      |
| ---------------------- | ------------------------------- | ------------------------------- | ---------------------------------------------------------------- |
| FrontDoorProfileName   | <input type="checkbox" checked> | `azurefrontdoorprofile`         | The name of the Front Door profile                               |
| FrontDoorResourceGroup | <input type="checkbox" checked> | `rg-$(Release.EnvironmentName)` | The name of the resourcegroup the Front Door Profile resides in. |
| RuleSetName            | <input type="checkbox" checked> | `myruleset`                     | The ruleset name.                                                |

## Rules
When wanting to add a rule all of the below parameters are required. If you don't want to add a rule, leave these parameters empty. 

| Parameter                        | Required                        | Example Value                                                                                                              | Description                                                                                                                                   |
| -------------------------------- | ------------------------------- | -------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| RuleOrder                        | <input type="checkbox">         | `1`                                                                                                                        | The order of the rule. By default, it will generate the order for you.                                                                        |
| RuleName                         | <input type="checkbox" checked> | `myrulename`                                                                                                               | The name of the rule.                                                                                                                         |
| ConditionMatchVariable           | <input type="checkbox" checked> | `RequestUri`                                                                                                               | The only option you can pick at this point is `RequestUri`. More will be added at a later time.                                               |
| ConditionOperator                | <input type="checkbox" checked> | `Any`/`BeginsWith`/ `Contains`/ `EndsWith`/`Equal`/`GreaterThan`/`GreaterThanEqual`/ `LessThan`/ `LessThanOrEqual`/`RegEx` |
| The operator of the condition.   |
| ConditionMatchValues             | <input type="checkbox" checked> | `value`                                                                                                                    | The value the condition has to match with.                                                                                                    |
| ActionActionName                 | <input type="checkbox" checked> | `RouteConfigurationOverride`                                                                                               | The action you want to apply. The only option you can pick at this point is `RouteConfigurationOverride`. More will be added at a later time. |
| OriginGroupName                  | <input type="checkbox" checked> | `myorigingroup`                                                                                                            | The name of the origin group you want to override the route with.                                                                             |
| ActionForwardingProtocol         | <input type="checkbox">         | `MatchRequest`/`Http`/ `Https`                                                                                             | The forwarding protocol for your action. Defaults to `MatchRequest`.                                                                          |
| ConditionMatchProcessingBehavior | <input type="checkbox">         | `Continue`/`Stop`                                                                                                          | The match processing behavior when the rule has been found. By default `Stop`.                                                                |
| ConditionTransformBehavior       | <input type="checkbox">         | `Lowercase`/`RemoveNulls`/`Trim`/`Uppercase`/`UrlDecode`/`UrlEncode`                                                       | The transform that will be applied on the condition of the rule. By default `Lowercase`.                                                      |


_Note: A rule with order 0 is a special rule that does not require any conditions nor any actions. This rule will always be applied. This rule should be made consciously and is not part of the generated set._

# YAML task

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Add Front Door Rule for Override Route"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/Front-Door/Add-Front-Door-Rule-For-Override-Route.ps1"
    arguments: >
        -FrontDoorProfileName '$(FrontDoorProfileName)'
        -FrontDoorResourceGroup '$(FrontDoorResourceGroup)'
        -RuleSetName '$(RuleSetName)'
        -RuleOrder '$(RuleOrder)'
        -RuleName '$(RuleName)'
        -ConditionMatchVariable '$(ConditionMatchVariable)'
        -ConditionOperator '$(ConditionOperator)'
        -ConditionMatchValues '$(ConditionMatchValues)'
        -ActionActionName '$(ActionActionName)'
        -OriginGroupName '$(OriginGroupName)'
        -ActionForwardingProtocol '$(ActionForwardingProtocol)'
        -ConditionMatchProcessingBehavior '$(ConditionMatchProcessingBehavior)'
        -ConditionTransformBehavior '$(ConditionTransformBehavior)'
```

# Code

[Click here to download this script](../../../../../src/Front-Door/Add-Front-Door-Rule-For-Override-Route.ps1)

# Links

[Azure REST Api - Azure Front Door Create Rule](https://docs.microsoft.com/en-us/rest/api/frontdoor/azurefrontdoorstandardpremium/rules/create)

[Azure REST Api - Azure Front Door List Rules](https://docs.microsoft.com/en-us/rest/api/frontdoor/azurefrontdoorstandardpremium/rules/list-by-rule-set)