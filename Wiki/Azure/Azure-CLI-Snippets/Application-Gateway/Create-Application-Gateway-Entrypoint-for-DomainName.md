[[_TOC_]]

# Description

This code will do a full configuration of the Application Gateway for directing SSL traffic to an AppService/Function App, including uploading a certificate (pfx) to a Keyvault and Application Gateway.

Also it will update certificates if your source certificate (the certificate in Azure DevOps Secure Files) is newer than the one currently in use.

# Parameters

Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.
| Parameter | Example Value | Description |
|--|--|--|
| ApplicationGatewayName | `my-gateway-$(Release.EnvironmentName)` | The name of the Application Gateway the managed identity is created for. |
| CertificatePath | `$(my-domain-com.secureFilePath)` | The path where the .pfx file for the SSL can be found. In a release to use the pfx you uploaded in "secure files" (Pipelines\Library), use the task "download a secure file". Set the certificatePath in the task output variables Reference name |
| IngressDomainName | `my.domain.com` | DNS name for your site you want to configure in Application Gateway |
| ApplicationGatewayFacingType | `Private` or `Public` | `Private` for internal (i.e. VNET) entries or `Public` for customer facing apps/api's. |
| CertificateKeyvaultName | `myplatformkeyvault-$(Release.EnvironmentName)` | Name of your platform wide (shared) keyvault. |
| CertificatePassword | `S0m3Amaz1n6P@ssw0rd123!` | The password you gave your pfx/certificate |
| BackendDomainname | `mycoolbackend.azurewebsites.net` | The (backend)domainname which you want to create this entrypoint for |
| HealthProbeUrlPath | `/` | The relative URL path the probe should check after your URI |
| HealthProbeIntervalInSeconds | `60` | Probe interval in seconds |
| HealthProbeNumberOfTriesBeforeMarkedDown | `2` | Probe retry count |
| HealthProbeTimeoutInSeconds | `20` | Probe timeout in seconds |
| HealthProbeProtocol | `HTTPS` | Over which protocol the probe should check |
| HttpsSettingsRequestToBackendProtocol | `HTTPS` | Protocol for the backend |
| HttpsSettingsRequestToBackendPort | `443` | Port for the backend |
| HttpsSettingsCookieAffinity | `Disabled` | If the Application Gateway needs cookies to keep user on the same server |
| HttpsSettingsRequestToBackendConnectionDrainingTimeoutInSeconds | `0` (disabled) | The timeout to gracefully remove backend members during maintenance |
| HttpsSettingsRequestToBackendTimeoutInSeconds | `30` | The timeout for the Application Gateway to wait for the backend to respond |
| HealthProbeMatchStatusCodes | `200-399` | The response the Health probe considers healthy when checking the backend|
| ApplicationGatewayRuleType | `Basic` | Routing rule type. Currently only `Basic` has been used. |
| ApplicationGatewayResourceGroupName | `sharedservices-rg` | The name of the Resource Group where the application gateway lives. |
| CertificateKeyvaultResourceGroupName | `sharedservices-rg` | The name of the Resource Group where the Keyvault with certificates lives. |

# YAML

```yaml
       - task: AzureCLI@2
           displayName: 'Create Application Gateway Entrypoint for DomainName'
           condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
           inputs:
               azureSubscription: '${{ parameters.SubscriptionName }}'
               scriptType: pscore
               scriptPath: '$(Pipeline.Workspace)/AzDocs/Application-Gateway/Create-Application-Gateway-Entrypoint-for-DomainName.ps1'
               arguments: "-CertificatePath '$(CertificatePath)' -CertificatePassword '$(CertificatePassword)' -IngressDomainName '$(IngressDomainName)' -ApplicationGatewayName '$(ApplicationGatewayName)' -ApplicationGatewayFacingType '$(ApplicationGatewayFacingType)' -ApplicationGatewayResourceGroupName '$(ApplicationGatewayResourceGroupName)' -CertificateKeyvaultResourceGroupName '$(CertificateKeyvaultResourceGroupName)' -CertificateKeyvaultName '$(CertificateKeyvaultName)' -BackendDomainname '$(BackendDomainname)' -HealthProbeUrlPath '$(HealthProbeUrlPath)' -HealthProbeIntervalInSeconds '$(HealthProbeIntervalInSeconds)' -HealthProbeNumberOfTriesBeforeMarkedDown '$(HealthProbeNumberOfTriesBeforeMarkedDown)' -HealthProbeTimeoutInSeconds '$(HealthProbeTimeoutInSeconds)' -HealthProbeProtocol '$(HealthProbeProtocol)' -HttpsSettingsRequestToBackendProtocol '$(HttpsSettingsRequestToBackendProtocol)' -HttpsSettingsRequestToBackendPort '$(HttpsSettingsRequestToBackendPort)' -HttpsSettingsRequestToBackendCookieAffinity '$(HttpsSettingsRequestToBackendCookieAffinity)' -HttpsSettingsRequestToBackendConnectionDrainingTimeoutInSeconds '$(HttpsSettingsRequestToBackendConnectionDrainingTimeoutInSeconds)' -HttpsSettingsRequestToBackendTimeoutInSeconds '$(HttpsSettingsRequestToBackendTimeoutInSeconds)' -HealthProbeMatchStatusCodes '$(HealthProbeMatchStatusCodes)' -ApplicationGatewayRuleType '$(ApplicationGatewayRuleType)'"
```

# Code

[Click here to download this script](../../../../src/Application-Gateway/Create-Application-Gateway-Entrypoint-for-DomainName.ps1)

# Links

- [AZ CLI - Configure Application Gateway](https://docs.microsoft.com/en-us/cli/azure/network/application-gateway?view=azure-cli-latest)
- [AZ CLI - Create and manage User Identity](https://docs.microsoft.com/en-us/cli/azure/identity?view=azure-cli-latest)
