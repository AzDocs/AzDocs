[[_TOC_]]

# Description

This script will apply a SSLProfile to a application gateway listener. This can be used to apply a stricter or less strict ssl cipher suite collection to the endpoint.

# Parameters

Some parameters from [General Parameter](/Azure/AzDocs-v1/Scripts) list.

| Parameter                           | Required                        | Example Value                           | Description                                                                                      |
| ----------------------------------- | ------------------------------- | --------------------------------------- | ------------------------------------------------------------------------------------------------ |
| ApplicationGatewayResourceGroupName | <input type="checkbox" checked> | `sharedservices-rg`                     | The name of the Resource Group where the application gateway lives.                              |
| ApplicationGatewayName              | <input type="checkbox" checked> | `my-gateway-$(Release.EnvironmentName)` | The name of the Application Gateway the WAF rule is created for.                                 |
| IngressDomainName                   | <input type="checkbox" checked> | `my.domain.com`                         | DNS name for your site you want to configure the WAF custom rule for in the Application Gateway. |
| SSLProfileName                      | <input type='checkbox' checked> | `mysslpolicy`                           | Name of the ssl profile policy to apply.                                                         |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
    displayName: 'Apply SSL Profile for $(IngressDomainName)'
    condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
    inputs:
        azureSubscription: '${{ parameters.SubscriptionName }}'
        scriptType: pscore
        scriptPath: '$(Pipeline.Workspace)/AzDocs/Application-Gateway/Set-SSLTLS-Profile-On-Application-Gateway-Entrypoint.ps1'
        arguments: "
          -ApplicationGatewayName '$(ApplicationGatewayName)' -ApplicationGatewayResourceGroupName '$(ApplicationGatewayResourceGroupName)'
          -IngressDomainName '$(IngressDomainName)'
          -SSLProfileName '$(ApplicationGatewayPolicyName)'
        "
```

# Code

[Click here to download this script](../../../../src/Application-Gateway/Set-SSLTLS-Profile-On-Application-Gateway-Entrypoint.ps1)

# Links

- [Azure CLI - az network application-gateway http-listener update](https://docs.microsoft.com/en-us/cli/azure/network/application-gateway/http-listener?view=azure-cli-latest#az_network_application_gateway_http_listener_update)
- [Azure CLI - az network application-gateway ssl-profile](https://docs.microsoft.com/en-us/cli/azure/network/application-gateway/ssl-profile?view=azure-cli-latest)
