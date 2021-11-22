[[_TOC_]]

# Description

This snippet will create an application gateway.

# Parameters

Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.

| Parameter                               | Required                        | Example Value                                                                                                                                   | Description                                                                                                                                                                                                   |
| --------------------------------------- | ------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ApplicationGatewayName                  | <input type="checkbox" checked> | `customer-appgw-$(Release.EnvironmentName)`                                                                                                     | The name to use for this application gateway                                                                                                                                                                  |
| ApplicationGatewayResourceGroupName     | <input type="checkbox" checked> | `myshared-resourcegroup`                                                                                                                        | The name of the resourcegroup to place this application gateway in.                                                                                                                                           |
| ApplicationGatewaySubnetName            | <input type="checkbox" checked> | `gateway-subnet`                                                                                                                                | The subnet where you want to place this Application Gateway in.                                                                                                                                               |
| ApplicationGatewayCapacity              | <input type="checkbox" checked> | `2`                                                                                                                                             | The number of instances to use for this appgw                                                                                                                                                                 |
| ApplicationGatewaySku                   | <input type="checkbox" checked> | `Standard_v2`                                                                                                                                   | The SKU name for the AppGw. Advised value: Standard_v2. List of accepted values: Standard_Large, Standard_Medium, Standard_Small, Standard_v2, WAF_Large, WAF_Medium, WAF_v2.                                 |
| CertificateKeyvaultName                 | <input type="checkbox" checked> | `my-shared-keyvault`                                                                                                                            | The keyvault where you want to save your SSL certificates to for this AppGw. This is usually 1 tenant-wide shared keyvault dedicated to these SSL certificates.                                               |
| CertificateKeyvaultResourceGroupName    | <input type="checkbox" checked> | `myshared-resourcegroup`                                                                                                                        | The resourcegroup where the keyvault resides in.                                                                                                                                                              |
| ApplicationGatewayVnetName              | <input type="checkbox" checked> | `my-vnet-$(Release.EnvironmentName)`                                                                                                            | The name of the VNET to place your Application Gateway in.                                                                                                                                                    |
| ApplicationGatewayVnetResourceGroupName | <input type="checkbox" checked> | `sharedservices-rg`                                                                                                                             | The ResourceGroup where the VNET for your Application Gateway lives in.                                                                                                                                       |
| EnableWafPreventionMode                 | <input type="checkbox">         | `$true`/`$false`                                                                                                                                | Enable prevention mode for your WAF. NOTE: This parameter is only applicable to application gateways with an SKU type of WAF.                                                                                 |
| WafRuleSetType                          | <input type="checkbox">         | `OWASP`                                                                                                                                         | Choose the WAF RuleSet Type. Get possible values from `az network application-gateway waf-config list-rule-sets`. NOTE: This parameter is only applicable to application gateways with an SKU type of WAF.    |
| WafRuleSetVersion                       | <input type="checkbox">         | `3.0`                                                                                                                                           | Choose the WAF RuleSet Version. Get possible values from `az network application-gateway waf-config list-rule-sets`. NOTE: This parameter is only applicable to application gateways with an SKU type of WAF. |
| LogAnalyticsWorkspaceResourceId         | <input type="checkbox" checked> | `/subscriptions/<subscriptionid>/resourceGroups/<resourcegroup>/providers/Microsoft.OperationalInsights/workspaces/<loganalyticsworkspacename>` | The Log Analytics Workspace the diagnostic setting will be linked to.                                                                                                                                         |
| DiagnosticSettingsLogs                  | <input type="checkbox">         | `@('Requests';'MongoRequests';)`                                                                                                                | If you want to enable a specific set of diagnostic settings for the category 'Logs'. By default, all categories for 'Logs' will be enabled.                                                                   |
| DiagnosticSettingsMetrics               | <input type="checkbox">         | `@('Requests';'MongoRequests';)`                                                                                                                | If you want to enable a specific set of diagnostic settings for the category 'Metrics'. By default, all categories for 'Metrics' will be enabled.                                                             |
| DiagnosticSettingsDisabled              | <input type="checkbox">         | n.a.                                                                                                                                            | If you don't want to enable any diagnostic settings, you can pass this as a switch witout a value(`-DiagnosticsettingsDisabled`).                                                                             |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Create Application Gateway"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/Application-Gateway/Create-Application-Gateway.ps1"
    arguments: "-ApplicationGatewayName '$(ApplicationGatewayName)' -ApplicationGatewayResourceGroupName '$(ApplicationGatewayResourceGroupName)' -ApplicationGatewayVnetName '$(ApplicationGatewayVnetName)' -ApplicationGatewayVnetResourceGroupName '$(ApplicationGatewayVnetResourceGroupName)' -ApplicationGatewaySubnetName '$(ApplicationGatewaySubnetName)' -ApplicationGatewayCapacity '$(ApplicationGatewayCapacity)' -ApplicationGatewaySku '$(ApplicationGatewaySku)' -CertificateKeyvaultName '$(CertificateKeyvaultName)' -CertificateKeyvaultResourceGroupName '$(CertificateKeyvaultResourceGroupName)' -LogAnalyticsWorkspaceResourceId '$(LogAnalyticsWorkspaceResourceId)' -DiagnosticSettingsLogs $(DiagnosticSettingsLogs) -DiagnosticSettingsDisabled $(DiagnosticSettingsDisabled)"
```

# Code

[Click here to download this script](../../../../src/Application-Gateway/Create-Application-Gateway.ps1)

# Links

[Azure CLI - az network vnet show](https://docs.microsoft.com/en-us/cli/azure/network/vnet?view=azure-cli-latest#az_network_vnet_show)

[Azure CLI - az network public-ip create](https://docs.microsoft.com/en-us/cli/azure/network/public-ip?view=azure-cli-latest#az_network_public_ip_create)

[Azure CLI - az network public-ip show](https://docs.microsoft.com/en-us/cli/azure/network/public-ip?view=azure-cli-latest#az_network_public_ip_show)

[Azure CLI - az network application-gateway create](https://docs.microsoft.com/en-us/cli/azure/network/application-gateway?view=azure-cli-latest#az_network_application_gateway_create)

[Azure CLI - az identity create](https://docs.microsoft.com/en-us/cli/azure/identity?view=azure-cli-latest#az_identity_create)

[Azure CLI - az identity show](https://docs.microsoft.com/en-us/cli/azure/identity?view=azure-cli-latest#az_identity_show)

[Azure CLI - az network application-gateway identity assign](https://docs.microsoft.com/en-us/cli/azure/network/application-gateway/identity?view=azure-cli-latest#az_network_application_gateway_identity_assign)

[Azure CLI - az network vnet subnet update](https://docs.microsoft.com/en-us/cli/azure/network/vnet/subnet?view=azure-cli-latest#az_network_vnet_subnet_update)

[Azure CLI - az keyvault network-rule add](https://docs.microsoft.com/en-us/cli/azure/keyvault/network-rule?view=azure-cli-latest#az_keyvault_network_rule_add)

[Azure CLI - az monitor diagnostic-settings-create](https://docs.microsoft.com/nl-nl/cli/azure/monitor/diagnostic-settings?view=azure-cli-latest#az_monitor_diagnostic_settings_create)
