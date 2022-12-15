[[_TOC_]]

# Description

This code will do a full configuration of the Application Gateway for directing SSL traffic to an AppService/Function App, including uploading a certificate (pfx) to a Keyvault and Application Gateway.

Also it will update certificates if your source certificate (the certificate in Azure DevOps Secure Files) is newer than the one currently in use.

# Parameters

Some parameters from [General Parameter](/Azure/AzDocs-v1/Scripts) list.
| Parameter | Required | Example Value | Description |
|--|--|--|--|
| ApplicationGatewayName | <input type="checkbox" checked> | `my-gateway-$(Release.EnvironmentName)` | The name of the Application Gateway the managed identity is created for. |
| IngressDomainName | <input type="checkbox" checked> | `my.domain.com` | DNS name for your site you want to configure in Application Gateway |
| ApplicationGatewayFacingType | <input type="checkbox" checked> | `Private` or `Public` | `Private` for internal (i.e. VNET) entries or `Public` for customer facing apps/api's. |
| ApplicationGatewayRuleType | <input type="checkbox" checked> | `Basic` | Routing rule type. Currently only `Basic` has been used. |
| CertificateKeyvaultResourceGroupName | <input type="checkbox" checked> | `sharedservices-rg` | The name of the Resource Group where the Keyvault with certificates lives. |
| CertificateKeyvaultName | <input type="checkbox" checked> | `myplatformkeyvault-$(Release.EnvironmentName)` | Name of your platform wide (shared) keyvault. |
| CertificatePath | <input type="checkbox" checked> | `$(my-domain-com.secureFilePath)` | The path where the .pfx file for the SSL can be found. In a release to use the pfx you uploaded in "secure files" (Pipelines\Library), use the task "download a secure file". Set the certificatePath in the task output variables Reference name |
| CertificatePassword | <input type="checkbox" checked> | `S0m3Amaz1n6P@ssw0rd123!` | The password you gave your pfx/certificate |
| BackendDomainname | <input type="checkbox" checked> | `mycoolbackend.azurewebsites.net` | The (backend)domainname which you want to create this entrypoint for |
| HealthProbeUrlPath | <input type="checkbox" checked> | `/` | The relative URL path the probe should check after your URI |
| HealthProbeDomainName | <input type="checkbox"> | `mycoolbackend.azurewebsites.net` | OPTIONAL: Pass a domainname for the healthprobe to check. This is needed whenever you use wildcard domains. |
| HealthProbeIntervalInSeconds | <input type="checkbox"> | `60` | Probe interval in seconds |
| HealthProbeNumberOfTriesBeforeMarkedDown | <input type="checkbox"> | `2` | Probe retry count |
| HealthProbeTimeoutInSeconds | <input type="checkbox"> | `20` | Probe timeout in seconds |
| HealthProbeProtocol | <input type="checkbox"> | `HTTPS` | Over which protocol the probe should check |
| HttpsSettingsRequestToBackendProtocol | <input type="checkbox"> | `HTTPS` | Protocol for the backend |
| HttpsSettingsRequestToBackendPort | <input type="checkbox"> | `443` | Port for the backend |
| HttpsSettingsCookieAffinity | <input type="checkbox"> | `Disabled` | If the Application Gateway needs cookies to keep user on the same server |
| HttpsSettingsRequestToBackendConnectionDrainingTimeoutInSeconds | <input type="checkbox"> | `0` (disabled) | The timeout to gracefully remove backend members during maintenance |
| HttpsSettingsRequestToBackendTimeoutInSeconds | <input type="checkbox"> | `30` | The timeout for the Application Gateway to wait for the backend to respond |
| HttpsSettingsCustomRootCertificateFilePath | <input type="checkbox"> | `$(trustedRootCA.secureFilePath)` | The path where the .cer file can be found. In a release, use the .cer you uploaded in (It's recommended to stick to lowercase alphanumeric characters when naming the .cer files in the portal) "secure files" (Pipelines\Library) and use the task "download a secure file". The filename must begin with a letter or number, end with a letter, number or underscore, and may contain only letters, numbers, underscores, periods, or hyphens. |
| HealthProbeMatchStatusCodes | <input type="checkbox"> | `200-399` | The response the Health probe considers healthy when checking the backend|
| ApplicationGatewayResourceGroupName | <input type="checkbox"> | `sharedservices-rg` | The name of the Resource Group where the application gateway lives. |
| ApplicationGatewayRuleDefaultIngressDomainName | <input type="checkbox"> | `application1.domain.com` | The ingress domain name for setting the default backendpool and httpssettings when using `PathBasedRouting`. |
| ApplicationGatewayRulePath | <input type="checkbox"> | `/api/*` | The path that will be set when using `PathBasedRouting`.|

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Create Application Gateway Entrypoint for DomainName"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/Application-Gateway/Create-Application-Gateway-Entrypoint-for-DomainName.ps1"
    arguments: "-CertificatePath '$(CertificatePath)' -CertificatePassword '$(CertificatePassword)' -IngressDomainName '$(IngressDomainName)' -ApplicationGatewayName '$(ApplicationGatewayName)' -ApplicationGatewayFacingType '$(ApplicationGatewayFacingType)' -ApplicationGatewayResourceGroupName '$(ApplicationGatewayResourceGroupName)' -CertificateKeyvaultResourceGroupName '$(CertificateKeyvaultResourceGroupName)' -CertificateKeyvaultName '$(CertificateKeyvaultName)' -BackendDomainname '$(BackendDomainname)' -HealthProbeDomainName '$(HealthProbeDomainName)' -HealthProbeUrlPath '$(HealthProbeUrlPath)' -HealthProbeIntervalInSeconds '$(HealthProbeIntervalInSeconds)' -HealthProbeNumberOfTriesBeforeMarkedDown '$(HealthProbeNumberOfTriesBeforeMarkedDown)' -HealthProbeTimeoutInSeconds '$(HealthProbeTimeoutInSeconds)' -HealthProbeProtocol '$(HealthProbeProtocol)' -HttpsSettingsRequestToBackendProtocol '$(HttpsSettingsRequestToBackendProtocol)' -HttpsSettingsRequestToBackendPort '$(HttpsSettingsRequestToBackendPort)' -HttpsSettingsRequestToBackendCookieAffinity '$(HttpsSettingsRequestToBackendCookieAffinity)' -HttpsSettingsRequestToBackendConnectionDrainingTimeoutInSeconds '$(HttpsSettingsRequestToBackendConnectionDrainingTimeoutInSeconds)' -HttpsSettingsRequestToBackendTimeoutInSeconds '$(HttpsSettingsRequestToBackendTimeoutInSeconds)' -HealthProbeMatchStatusCodes '$(HealthProbeMatchStatusCodes)' -ApplicationGatewayRuleType '$(ApplicationGatewayRuleType)' -ApplicationGatewayRuleDefaultIngressDomainName '$(ApplicationGatewayRuleDefaultIngressDomainName)' -ApplicationGatewayRulePath '$(ApplicationGatewayRulePath)'"
```

# Code

[Click here to download this script](../../../../../src/Application-Gateway/Create-Application-Gateway-Entrypoint-for-DomainName.ps1)

# Links

- [AZ CLI - Configure Application Gateway](https://docs.microsoft.com/en-us/cli/azure/network/application-gateway?view=azure-cli-latest)
- [AZ CLI - Create and manage User Identity](https://docs.microsoft.com/en-us/cli/azure/identity?view=azure-cli-latest)
- [AZ CLI - Create url-path-map for PathBasedRouting](https://docs.microsoft.com/en-us/cli/azure/network/application-gateway/url-path-map?view=azure-cli-latest#az-network-application-gateway-url-path-map-create)
- [AZ - Use pathbased routing for your Entrypoint](https://docs.microsoft.com/en-us/azure/application-gateway/tutorial-url-redirect-cli)
