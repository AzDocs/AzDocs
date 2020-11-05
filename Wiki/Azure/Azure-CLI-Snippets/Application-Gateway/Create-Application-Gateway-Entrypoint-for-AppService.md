[[_TOC_]]

# Description
This code will do a full configuration of the Application Gateway for directing SSL traffic to an AppService/Function App, including uploading a certificate (pfx) to a Keyvault and Application Gateway.

Also it will update certificates if your source certificate (the certificate in Azure DevOps Secure Files) is newer than the one currently in use.

# Parameters
Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.
| Parameter | Example Value | Description |
|--|--|--|
| gatewayName | `my-gateway-$(Release.EnvironmentName)` | The name of the Application Gateway the managed identity is created for. |
| certificatePath | `$(my-domain-com.secureFilePath)` | The path where the .pfx file for the SSL can be found. In a release to use the pfx you uploaded in "secure files" (Pipelines\Library), use the task "download a secure file". Set the certificatePath in the task output variables Reference name |
| domainName | `my.domain.com` | DNS name for your site you want to configure in Application Gateway |
| gatewayType | `Private` or `Public` | `Private` for internal (i.e. VNET) entries or `Public` for customer facing apps/api's. |
| sharedServicesKeyvaultName | `myplatformkeyvault-$(Release.EnvironmentName)` | Name of your platform wide (shared) keyvault. |
| certificatePassword | `S0m3Amaz1n6P@ssw0rd123!` | The password you gave your pfx/certificate |
| backendDomainname | `mycoolbackend.azurewebsites.net` | The (backend)domainname which you want to create this entrypoint for. |
| healthProbePath | `/` | The relative URL path the probe should check after your URI |
| healthProbeInterval | `60` | Probe interval in seconds |
| healthProbeThreshold | `2` | Probe retry count |
| healthProbeTimeout | `20` | Probe timeout in seconds |
| healthProbeProtocol | `HTTPS` | Over which protocol the probe should check |
| httpsSettingsProtocol  | `HTTPS` | Protocol for the backend |
| httpsSettingsPort | `443` | Port for the backend |
| httpsSettingsCookieAffinity | `Disabled` | If the Application Gateway needs cookies to keep user on the same server |
| httpsSettingsConnectionDrainingTimeout | `0` (disabled) | The timeout to gracefully remove backend members during maintenance |
| httpsSettingsTimeout | `30` | The timeout for the Application Gateway to wait for the backend to respond |
| matchStatusCodes | `200-399` | The response the Health probe considers healthy when checking the backend|
| gatewayRuleType | `Basic` | Routing rule type. Currently only `Basic` has been used. |
| sharedServicesResourceGroupName | `sharedservices-rg` | The name of the Resource Group for the shared resources for the Application Gateway and Keyvault (certificate). |


# Code
[Click here to download this script](../../../../src/Application-Gateway/Create-Application-Gateway-Entrypoint-for-AppService.ps1)

# Links

- [AZ CLI - Configure Application Gateway](https://docs.microsoft.com/en-us/cli/azure/network/application-gateway?view=azure-cli-latest)
- [AZ CLI - Create and manage User Identity](https://docs.microsoft.com/en-us/cli/azure/identity?view=azure-cli-latest)