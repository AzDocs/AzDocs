[[_TOC_]]

# Description

This code will create a rule for your endpoint

# Parameters

Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.

| Parameter                                         | Required                        | Example Value                                  | Description                                                                                                                                                                                                               |
| ------------------------------------------------- | ------------------------------- | ---------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| CdnEndpointName                                    | <input type="checkbox" checked> | `shared-cdn`                                   | The name of the cdn endpoint.                                                                                                                                                       |
| CdnProfileName                                     | <input type="checkbox" checked> | `shared-cdn`                                   | The name of the cdn profile name.                                                                                                                                   |
| CdnResourceGroup                                  | <input type="checkbox" checked> | `my-resource-group-$(Release.EnvironmentName`  | The name of the resource group.                                                                                                                                   |
| ActionName                                         | <input type="checkbox" checked> | `UseQueryString`                | 
The name of the action for the delivery. Options are currently: `BypassCaching`, `IgnoreQueryString` `NotSet`, `UseQueryString`, `IgnoreQueryString` `NotSet`, `UseQueryString`   rule                                                                                                                                |
| CacheDuration                                      | <input type="checkbox">         | `01:00:00`                                     | The duration for which the content needs to be cached. Allowed format is [d.]hh:mm:ss.                                                                                                                 |
| CacheBehavior                                      | <input type="checkbox">         | `Override`                | The host header value sent to the origin with each request. If you leave this blank, the request hostname determines this value. Azure CDN origins, such as Web Apps, Blob Storage, and Cloud Services, require this host header value to match the origin hostname by default.                                                                                                                                |
| Order                                              | <input type="checkbox">         | 0 | The order in which the rules are applied for the endpoint. Possible values {0,1,2,3,………}. A rule with a lower order will be applied before one with a higher order. Rule with order 0 is a special rule. It does not require any condition and actions listed in it will always be applied                                                                                                                               |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Create CDN Endpoint rule"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/CDN/Create-CDN-Endpoint-Rule.ps1"
    arguments: "-CdnEndpointName '$(CdnEndpointName)' -CdnProfileName '$(CdnProfileName)' -CdnResourceGroup '$(CdnResourceGroup)' -ActionName '$(ActionName)' -CacheDuration '$(CacheDuration)' -Order '$(Order)'"
```

# Code

[Click here to download this script](../../../../src/CDN/CDN/Create-CDN-Endpoint-Rule.ps1)

# Links

- [Azure Ccli - Configure CDN endpoint rule](https://docs.microsoft.com/nl-nl/cli/azure/cdn/endpoint/rule?view=azure-cli-latest)
