[[_TOC_]]

# Description

This snippet will remove the full configuration for a domain in the Application Gateway. This also includes removing the certificate (pfx) from the Keyvault and Application Gateway (if it is not used by any other listeners).

This includes the following:

- Rules
- Listeners
- Certificates
- Backend pools
- Http settings
- Health probe
- Rewrite rule sets
- Redirect configurations

# Parameters

Some parameters from [General Parameter](/Azure/AzDocs-v1/Scripts) list.

| Parameter                            | Required                        | Example Value                       | Description                                                                                                     |
| ------------------------------------ | ------------------------------- | ----------------------------------- | --------------------------------------------------------------------------------------------------------------- |
| IngressDomainName                    | <input type="checkbox" checked> | `test.dev.domain.org`               | The ingress domain name.                                                                                        |
| ApplicationGatewayName               | <input type="checkbox" checked> | `application-gatewayname`           | The Application Gateway to remove the settings from.                                                            |
| ApplicationGatewayResourceGroupName  | <input type="checkbox" checked> | `application-gateway-resourcegroup` | The name of the resourcegroup the Application Gateway resides in.                                               |
| CertificateKeyvaultResourceGroupName | <input type="checkbox" checked> | `shared-keyvault-rg`                | The name of the resourcegroup the keyvault resides in, in which you keep your application gateway certificates. |
| CertificateKeyvaultName              | <input type="checkbox" checked> | `shared-keyvault`                   | The name of the keyvault, in which you keep your application gateway certificates.                              |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Remove Application Gateway Entrypoint"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/Application-Gateway/Remove-Application-Gateway-Entrypoint.ps1"
    arguments: "-IngressDomainName '$(IngressDomainName)' -ApplicationGatewayName '$(ApplicationGatewayName)' -ApplicationGatewayResourceGroupName '$(ApplicationGatewayResourceGroupName)' -CertificateKeyvaultResourceGroupName '$(CertificateKeyvaultResourceGroupName)' -CertificateKeyvaultName '$(CertificateKeyvaultName)'"
```

# Code

[Click here to download this script](../../../../src/Application-Gateway/Remove-Application-Gateway-Entrypoint.ps1)

# Links

- [AZ CLI - Configure Application Gateway](https://docs.microsoft.com/en-us/cli/azure/network/application-gateway?view=azure-cli-latest)
