[[_TOC_]]

# Description

Add an origin group (backend pool) and an origin to Front Door.

# Parameters

| Parameter                                            | Required                        | Example Value                     | Description                                                                                                                                                    |
| ---------------------------------------------------- | ------------------------------- | --------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| FrontDoorProfileName                                 | <input type="checkbox" checked> | `azurefrontdoorprofile`           | The name of the Front Door profile                                                                                                                             |
| FrontDoorResourceGroup                               | <input type="checkbox" checked> | `rg-$(Release.EnvironmentName)`   | The name of the resourcegroup the Front Door Profile resides in.                                                                                               |
| OriginGroupName                                      | <input type="checkbox" checked> | `myorigingroup`                   | The origin group name.                                                                                                                                         |
| OriginHealthProbePath                                | <input type="checkbox">         | `/health`                         | The health probe path of the origin. Defaults to `/`.                                                                                                          |
| OriginHealthProbeProtocol                            | <input type="checkbox">         | `Http`/`Https`/ `NotSet`          | The health probe protocol of your origin. Defaults to `Https`.                                                                                                 |
| OriginHealthProbeRequestType                         | <input type="checkbox">         | `GET`/ `HEAD`/ `NotSet`           | The health probe request type. Defaults to `GET`.                                                                                                              |
| OriginHealthProbeIntervalInSeconds                   | <input type="checkbox">         | `100`                             | The health probe interval in seconds. Defaults to `100`.                                                                                                       |
| OriginLoadBalancingSampleSize                        | <input type="checkbox">         | `4`                               | The load balancing sample size of the origin. Defaults to `4`.                                                                                                 |
| OriginLoadBalancingSuccessfulSamplesRequired         | <input type="checkbox">         | `3`                               | The load balancing successful samples that are required. Defaults to `3`.                                                                                      |
| OriginLoadBalancingAdditationalLatencyInMilliseconds | <input type="checkbox">         | `50`                              | The load balancing additational latency in milliseconds. Defaults to `50`.                                                                                     |
| OriginName                                           | <input type="checkbox" checked> | `myorigin`                        | The name of the origin.                                                                                                                                        |
| ResourceType                                         | <input type="checkbox" checked> | `webapp`/ `functionapp`/ `custom` | The resource type of the backend you want to add to the origin.                                                                                                |
| ResourceName                                         | <input type="checkbox">         | `mywebapp`                        | The name of the resource you want to add to the origin. When choosing `webapp` or `functionapp` as ResourceType, this is required and it is the resource name. |
| CustomOriginHostName                                 | <input type="checkbox">         | `10.12.13.4`                      | The custom origin host name you want to add to the origin. When choosing `custom` as ResourceType, this field is required.                                     |
| OriginHttpPort                                       | <input type="checkbox">         | `80`                              | The Http Port the origin should use. Defaults to port `80`.                                                                                                    |
| OriginHttpsPort                                      | <input type="checkbox">         | `443`                             | The Https Port the origin should use. Defaults to port `443`.                                                                                                  |
| OriginPriority                                       | <input type="checkbox">         | `1`                               | The priority of the origin. Defaults to `1`.                                                                                                                   |
| OriginWeight                                         | <input type="checkbox">         | `1000`                            | The weight of the origin. Defaults to `1000`.                                                                                                                  |
| OriginEnabled                                        | <input type="checkbox">         | `Enabled`/ `Disabled`             | Determines if the origin is enabled. Defaults to `Enabled`.                                                                                                    |

# YAML task

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Add origin to Front Door"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/Front-Door/Add-Origin-To-Front-Door.ps1"
    arguments: >
        -FrontDoorProfileName '$(FrontDoorProfileName)'
        -FrontDoorResourceGroup '$(FrontDoorResourceGroup)'
        -OriginGroupName '$(OriginGroupName)'
        -OriginHealthProbePath '$(OriginHealthProbePath)'
        -OriginHealthProbeProtocol '$(OriginHealthProbeProtocol)'
        -OriginHealthProbeRequestType '$(OriginHealthProbeRequestType)'
        -OriginHealthProbeIntervalInSeconds '$(OriginHealthProbeIntervalInSeconds)'
        -OriginLoadBalancingSampleSize '$(OriginLoadBalancingSampleSize)'
        -OriginLoadBalancingSuccessfulSamplesRequired '$(OriginLoadBalancingSuccessfulSamplesRequired)'
        -OriginLoadBalancingAdditationalLatencyInMilliseconds '(OriginLoadBalancingAdditationalLatencyInMilliseconds)'
        -OriginName '$(OriginName)'
        -ResourceType '$(ResourceType)'
        -ResourceName '$(ResourceName)'
        -CustomOriginHostName '$(CustomOriginHostName)'
        -OriginHttpPort '$(OriginHttpPort)'
        -OriginHttpsPort '$(OriginHttpsPort)'
        -OriginPriority '$(OriginPriority)'
        -OriginWeight '$(OriginWeight)'
        -OriginEnabled '$(OriginEnabled)'
```

# Code

[Click here to download this script](../../../../src/Front-Door/Add-Origin-To-Front-Door.ps1)

# Links

[Azure CLI - az afd origin create](https://docs.microsoft.com/en-us/cli/azure/afd/origin?view=azure-cli-latest#az-afd-origin-create)

[Azure CLI - az afd origin-group create](https://docs.microsoft.com/en-us/cli/azure/afd/origin-group?view=azure-cli-latest#az-afd-origin-group-create)