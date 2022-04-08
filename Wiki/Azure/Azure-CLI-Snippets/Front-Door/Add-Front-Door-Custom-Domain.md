[[_TOC_]]

# Description

Create a custom domain in a front door profile. After adding the custom domain, you will have to add the following to your DNS record: 
- TXT record with `dns_auth{your_domain}` and a validation token
- CNAME record

In this script the certificate from your Azure Devops library will also be added to your keyvault and added to the front door profile. 

Do not forget to add the service principal to your global tenant, see https://docs.microsoft.com/en-us/azure/frontdoor/standard-premium/how-to-configure-https-custom-domain. To get the service principal object id for your service principal, use the following command: 

`az ad sp show --id {service-principal-id}`

# Parameters

| Parameter                            | Required                        | Example Value                              | Description                                                          |
| ------------------------------------ | ------------------------------- | ------------------------------------------ | -------------------------------------------------------------------- |
| FrontDoorProfileName                 | <input type="checkbox" checked> | `azurefrontdoorprofile`                    | The name of the Front Door profile                                   |
| FrontDoorResourceGroup               | <input type="checkbox" checked> | `rg-$(Release.EnvironmentName)`            | The name of the resourcegroup the Front Door Profile resides in.     |
| CustomDomainCertificateType          | <input type="checkbox" checked> | `CustomerCertificate`/`ManagedCertificate` | The type of certificate you can choose.                              |
| CustomDomainNameName                 | <input type="checkbox" checked> | `mycustomdomain`                           | The name of the custom domain.                                       |
| HostName                             | <input type="checkbox" checked> | `*.wildcard.dev.com`                       | The hostname of your new custom domain.                              |
| CustomDomainMinimalTLSVersion        | <input type="checkbox">         | `TLS1_2`                                   | The minimal TLS version of your custom domain. Defaults to `TLS1_2`. |
| CertificatePath                      | <input type="checkbox" checked> | `$(wildcard.secureFilePath)`               | The path of the certificate.                                         |
| CertificatePassword                  | <input type="checkbox">         | `password`                                 | The password of the certificate.                                     |
| CertificateKeyvaultResourceGroupName | <input type="checkbox" checked> | `rg-keyvault`                              | The resourcegroup where the keyvault resides in.                     |
| CertificateKeyvaultName              | <input type="checkbox">         | `keyvault-name`                            | The name of the keyvault.                                            |
| ServicePrincipalObjectId             | <input type="checkbox" checked> | `f1f30593-adf3-430d-828e-21d32d4cc5db`     | The objectid of the Azure Frontdoor Service principal.               |

# YAML task

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Add Custom Domain to Azure FrontDoor"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/Front-Door/Add-Front-Door-Custom-Domain.ps1"
    arguments: >
        -FrontDoorProfileName '$(FrontDoorProfileName)'
        -FrontDoorResourceGroup '$(FrontDoorResourceGroup)'
        -CustomDomainCertificateType '$(CustomDomainCertificateType)'
        -CustomDomainNameName '$(CustomDomainNameName)'
        -HostName '$(HostName)'
        -CustomDomainMinimalTLSVersion '$(CustomDomainMinimalTLSVersion)'
        -CertificatePath '$(CertificatePath)'
        -CertificatePassword '$(CertificatePassword)'
        -CertificateKeyvaultResourceGroupName '$(CertificateKeyvaultResourceGroupName)'
        -CertificateKeyvaultName '$(CertificateKeyvaultName)'
        -ServicePrincipalObjectId '$(ServicePrincipalObjectId)'
```

# Code

[Click here to download this script](../../../../src/Front-Door/Add-Front-Door-Custom-Domain.ps1)

# Links

[Azure CLI - az afd custom-domain](https://docs.microsoft.com/en-us/cli/azure/afd/custom-domain?view=azure-cli-latest)