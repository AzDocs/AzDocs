[[_TOC_]]

# Description

This script will add a containerinstance to the backend of your appgateway entrypoint for the given domainname.

# Parameters

Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.
| Parameter | Example Value | Description |
|--|--|--|
| ApplicationGatewayName | `my-gateway-$(Release.EnvironmentName)` | The name of the Application Gateway the managed identity is created for. |
| IngressDomainName | `my.domain.com` | DNS name for your site you want to configure in Application Gateway |
| ContainerName | `mycontainername` | The name of the container instance. |
| ContainerResourceGroupName | `Myteam-MyApp-$(Release.EnvironmentName)` | The resourcegroup where the container resides in. |
| ApplicationGatewayResourceGroupName | `sharedservices-rg` | The name of the Resource Group for the shared resources for the Application Gateway and Keyvault (certificate). |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
        - task: AzureCLI@2
           displayName: 'Add ContainerInstance To BackendPool'
           condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
           inputs:
               azureSubscription: '${{ parameters.SubscriptionName }}'
               scriptType: pscore
               scriptPath: '$(Pipeline.Workspace)/AzDocs/Application-Gateway/Add-ContainerInstance-To-BackendPool.ps1'
               arguments: "-IngressDomainName '$(IngressDomainName)' -ApplicationGatewayName '$(ApplicationGatewayName)' -ApplicationGatewayResourceGroupName '$(ApplicationGatewayResourceGroupName)' -ContainerName '$(ContainerName)' -ContainerResourceGroupName '$(ContainerResourceGroupName)'"
```

# Code

[Click here to download this script](../../../../src/Application-Gateway/Add-ContainerInstance-To-BackendPool.ps1)

# Links

- [AZ CLI - Configure Application Gateway](https://docs.microsoft.com/en-us/cli/azure/network/application-gateway?view=azure-cli-latest)
- [AZ CLI - Create and manage User Identity](https://docs.microsoft.com/en-us/cli/azure/identity?view=azure-cli-latest)
