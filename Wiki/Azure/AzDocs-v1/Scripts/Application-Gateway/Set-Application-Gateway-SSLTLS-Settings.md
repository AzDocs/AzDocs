[[_TOC_]]

# Description

This snippet will set Ciphers & the minimal TLS version on your AppGateway. If you use the defaults, it will set to TLS 1.2 & a set of non-compromised strong cipher suites. All devices/browsers/os's newer than february 2014 should support this default set.

The default Ciphers are (in order):

```
 - TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384
 - TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256
 - TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
 - TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256
 - TLS_DHE_RSA_WITH_AES_256_GCM_SHA384
 - TLS_DHE_RSA_WITH_AES_128_GCM_SHA256
```

We don't recommend deviating from the defaults, but if you do need other ciphers, please refer to [ciphersuite.info](https://ciphersuite.info/cs/) for more information about which Ciphers are `Recommended` and/or `Secure`. We strongly recommend using the scripts defaults or using ciphers marked as `Recommended` or `Secure` only. We also strongly recommend using TLS 1.2 or higher.

# Parameters

Some parameters from [General Parameter](/Azure/AzDocs-v1/Scripts) list.

| Parameter                                | Required                        | Example Value                                                                             | Description                                                                                                                                                                                                                                                                                                                                      |
| ---------------------------------------- | ------------------------------- | ----------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| ApplicationGatewayName                   | <input type='checkbox' checked> | `customer-appgw-$(Release.EnvironmentName)`                                               | The name to use for this application gateway                                                                                                                                                                                                                                                                                                     |
| ApplicationGatewayResourceGroupName      | <input type='checkbox' checked> | `myshared-resourcegroup`                                                                  | The name of the resourcegroup to place this application gateway in.                                                                                                                                                                                                                                                                              |
| ApplicationGatewayPolicyType             | <input type='checkbox'>         | `Custom`/`Predefined`                                                                     | The type of policy to use. Microsoft offers some predefined ones, which are suboptimal from our point of view. If you want the recommended setup, don't pass this parameter.                                                                                                                                                                     |
| ApplicationGatewayPredefinedPolicyName   | <input type='checkbox'>         | `AppGwSslPolicy20170401S`                                                                 | Current options are `AppGwSslPolicy20150501`, `AppGwSslPolicy20170401`, `AppGwSslPolicy20170401S`. This field is only relevant if you choose `Predefined` for the `ApplicationGatewayPolicyType` parameter.                                                                                                                                      |
| ApplicationGatewayMinimalProtocolVersion | <input type='checkbox'>         | `TLSv1_2`                                                                                 | The minimal TLS version to use. The default is TLS 1.2. It is extremely recommended to use TLS 1.2 or higher at the point of writing. Current options: `TLSv1_0`, `TLSv1_1`, `TLSv1_2`. For all (up-to-date) options use `az network application-gateway ssl-policy list-options`. If you want the recommended setup, don't pass this parameter. |
| ApplicationGatewayCipherSuites           | <input type='checkbox'>         | `@('TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384', 'TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256')` | The set of ciphers to be allowed/used on the Application Gateway. This defaults to a set of ciphers which are (at the point of writing this) found secure & non-compromisable. For options, please use `az network application-gateway ssl-policy list-options`. If you want the recommended setup, don't pass this parameter.                   |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Set Application Gateway SSLTLS Settings"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/Application-Gateway/Set-Application-Gateway-SSLTLS-Settings.ps1"
    arguments: "-ApplicationGatewayName '$(ApplicationGatewayName)' -ApplicationGatewayResourceGroupName '$(ApplicationGatewayResourceGroupName)' -ApplicationGatewayPolicyType '$(ApplicationGatewayPolicyType)' -ApplicationGatewayPredefinedPolicyName '$(ApplicationGatewayPredefinedPolicyName)' -ApplicationGatewayMinimalProtocolVersion '$(ApplicationGatewayMinimalProtocolVersion)' -ApplicationGatewayCipherSuites $(ApplicationGatewayCipherSuites)"
```

# Code

[Click here to download this script](../../../../src/Application-Gateway/Set-Application-Gateway-SSLTLS-Settings.ps1)

# Links

[Azure CLI - az network application-gateway ssl-policy set](https://docs.microsoft.com/en-us/cli/azure/network/application-gateway/ssl-policy?view=azure-cli-latest#az_network_application_gateway_ssl_policy_set)
