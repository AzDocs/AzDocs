[[_TOC_]]

# Description

This code will create a custom domain for your CDN. And also the possibility to enable https. 

# Parameters

Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.

| Parameter                                         | Required                        | Example Value                                  | Description                                                                                                                                                                                                               |
| ------------------------------------------------- | ------------------------------- | ---------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| AddHttps                                          | <input type="checkbox"> | n.                                   | The possibility to enable https                                                                                                                  |
| CdnEndpointName                                    | <input type="checkbox" checked> | `shared-cdn`                                   | The name of the cdn endpoint.                                                                                                                               |
| CdnProfileName                                     | <input type="checkbox" checked> | `shared-cdn`                                   | The name of the cdn profile name.                                                                                                                                   |
| CdnResourceGroupName                                  | <input type="checkbox" checked> | `my-resource-group-$(Release.EnvironmentName)`  | The name of the resource group.                                                                                                                                   |
| Hostname                                          | <input type="checkbox" checked> | `image.$(Release.EnvironmentName).nl`                | 
The hostname of the custom domain                |
| CdnCustomDomainName                                  | <input type="checkbox" checked> | `image-$(Release.EnvironmentName)-nl`                | 
Resource name of customdomain                 |
| UserCertSecretName                                | <input type="checkbox">        | `wildcard-$(Release.EnvironmentName)-test-nl`                                          | The user certificate secret name hh:mm:ss.                                                                                                                 |
| UserCertVaultName                                 | <input type="checkbox">         | `DP-Shared-keyvault-$(Release.EnvironmentName`                | The user certificate vault name.                                                                                                                                |
| UserCertProtocolType                              | <input type="checkbox">         | `sni`   | The protocoltype of the certificate. possible options: `sni` and `ip`  |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Create CDN Custom domain"
  condition: succeeded()
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/CDN/Create-CDN-Custom-Domain.ps1"
    arguments: "-AddHttps -CdnEndpointName '$(CdnEndpointName)' -CdnProfileName '$(CdnProfileName)' -CdnResourceGroupName '$(CdnResourceGroupName)' -CdnCustomDomainName '$(CdnCustomDomainName)' -Hostname '$(CdnHostname)' -UserCertSecretName '$(UserCertSecretName)' -UserCertVaultName '$(UserCertVaultName)' -UserCertProtocolType '$(UserCertProtocolType)'"

```

# Code

[Click here to download this script](../../../../src/CDN/CDN/Create-CDN-Custom-Domain.ps1)

# Links

- [Azure Cli - Configure CDN custom domain](https://docs.microsoft.com/nl-nl/cli/azure/cdn/custom-domain?view=azure-cli-latest)
