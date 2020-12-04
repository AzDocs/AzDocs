[[_TOC_]]

# Description
This script will add a containerinstance to the backend of your appgateway entrypoint for the given domainname.

# Parameters
Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.
| Parameter | Example Value | Description |
|--|--|--|
| gatewayName | `my-gateway-$(Release.EnvironmentName)` | The name of the Application Gateway the managed identity is created for. |
| domainName | `my.domain.com` | DNS name for your site you want to configure in Application Gateway |
| containerName | `mycontainername` | The name of the container instance. |
| containerResourceGroupName | `Myteam-MyApp-$(Release.EnvironmentName)` | The resourcegroup where the container resides in. |
| sharedServicesResourceGroupName | `sharedservices-rg` | The name of the Resource Group for the shared resources for the Application Gateway and Keyvault (certificate). |


# Code
[Click here to download this script](../../../../src/Application-Gateway/Add-ContainerInstance-To-BackendPool.ps1)

# Links

- [AZ CLI - Configure Application Gateway](https://docs.microsoft.com/en-us/cli/azure/network/application-gateway?view=azure-cli-latest)
- [AZ CLI - Create and manage User Identity](https://docs.microsoft.com/en-us/cli/azure/identity?view=azure-cli-latest)