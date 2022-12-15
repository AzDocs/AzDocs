[[_TOC_]]

# Description

This code will create a CDN profile endpoint

# Parameters

Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.

| Parameter                                         | Required                        | Example Value                                  | Description                                                                                                                                                                                                               |
| ------------------------------------------------- | ------------------------------- | ---------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| CdnEndpointName                                    | <input type="checkbox" checked> | `shared-cdn`                                   | The name of the cdn endpoint.                                                                                                                                                       |
| CdnProfileName                                     | <input type="checkbox" checked> | `shared-cdn`                                   | The name of the cdn profile name.                                                                                                                                   |
| CdnResourceGroupName                                                                    | <input type="checkbox" checked> | `my-resource-group-$(Release.EnvironmentName`  | The name of the resource group.                                                                                                                                   |
| Origin                                             | <input type="checkbox" checked> | `storage.blob.core.windows.net`                | 
Choose an origin hostname from the list, type a custom name, or enter an IP address. CDN will pull content from this origin.                                                                                                                                 |
| OriginHostHeader                                   | <input type="checkbox" checked> | `storage.blob.core.windows.net` | The host header value sent to the origin with each request. If you leave this blank, the request hostname determines this value. Azure CDN origins, such as Web Apps, Blob Storage, and Cloud Services, require this host header value to match the origin hostname by default.                                                                                                                                |
| QueryStringCaching                                 | <input type="checkbox">         | `UseQueryString`                               | This sets how the CDN treats cacheable objects when the request URL contains query strings. This option has no effect when caching is turned off for the asset. This setting doesn't modify query string values sent back to the origin. Options are currently :  `BypassCaching`, `IgnoreQueryString` `NotSet`, `UseQueryString`                                                                                                                         |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Create CDN Endpoint"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/CDN/Create-CDN-Endpoint.ps1"
    arguments: "-CdnEndpointName '$(CdnEndpointName)' -CdnProfileName '$(CdnProfileName)' -CdnResourceGroupName '$(CdnResourceGroupName)' -Origin '$(Origin)' -OriginHostHeader '$(OriginHostHeader)' -QueryStringCaching '$(QueryStringCaching)'"
```

# Code

[Click here to download this script](../../../../src/CDN/CDN/Create-CDN-Endpoint.ps1)

# Links

- [Azure Cli - Configure CDN endpoint](https://docs.microsoft.com/nl-nl/cli/azure/cdn/endpoint?view=azure-cli-latest#az-cdn-endpoint-create)
