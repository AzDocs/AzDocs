[[_TOC_]]

# Description

This snippet will create a storage account if it does not exist within a given subnet. It will also make sure that public access is denied by default. It will whitelist the application subnet so your app can connect to the storageaccount within the vnet. All the needed components (private endpoint, service endpoint etc) will be created too.

When wanting to add multiple resources inside the storage account (blobs and queues for example), this step needs to be run twice with different parameters for creating the private endpoint.

NOTE: This step was built with blob storage in mind. If you use anything else please test this extensively. It should work, but it is untested.

# Parameters

Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.

| Parameter                           | Required                        | Example Value                                                                                                                                   | Description                                                                                                                                                                                                                                                        |
| ----------------------------------- | ------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| StorageAccountResourceGroupName     | <input type="checkbox" checked> | `myteam-testapi-$(Release.EnvironmentName)`                                                                                                     | ResourceGroupName where the storage account should be created                                                                                                                                                                                                      |
| StorageAccountName                  | <input type="checkbox" checked> | `myteststgaccount$(Release.EnvironmentName)`                                                                                                    | This is the storageaccount name to use.                                                                                                                                                                                                                            |
| StorageAccountKind                  | <input type="checkbox">         | `StorageV2`                                                                                                                                     | This is the storage kind you can choose. You have a choice between: 'BlobStorage', 'BlockBlobStorage', 'FileStorage', 'Storage', 'StorageV2'. This has a default value of 'StorageV2'.                                                                             |
| StorageAccountSku                   | <input type="checkbox">         | `Standard_LRS`                                                                                                                                  | This is the sku you can choose for your storage account. You have a choice between 'Premium_LRS', 'Premium_ZRS', 'Standard_GRS', 'Standard_GZRS', 'Standard_LRS', 'Standard_RAGRS', 'Standard_RAGZRS', 'Standard_ZRS'. This has a default value of 'Standard_LRS'. |
| StorageAccountAllowBlobPublicAccess | <input type="checkbox">         | `true` / `false`                                                                                                                                | Enabling public access on the storage account. This has default value of 'false'.                                                                                                                                                                                  |
| StorageAccountMinimalTlsVersion     | <input type="checkbox">         | `TLS1_2`                                                                                                                                        | The possibility to enable a specific TLS version on your storage account. Defaults to TLS1_2.                                                                                                                                                                      |
| LogAnalyticsWorkspaceResourceId     | <input type="checkbox" checked> | `/subscriptions/<subscriptionid>/resourceGroups/<resourcegroup>/providers/Microsoft.OperationalInsights/workspaces/<loganalyticsworkspacename>` | The Log Analytics Workspace the diagnostic setting will be linked to.                                                                                                                                                                                              |
| ForcePublic                         | <input type="checkbox">         | n.a.                                                                                                                                            | If you are not using any networking settings, you need to pass this boolean to confirm you are willingly creating a public resource (to avoid unintended public resources). You can pass it as a switch without a value (`-ForcePublic`).                          |
| DiagnosticSettingsLogs              | <input type="checkbox">         | `@('Requests';'MongoRequests';)`                                                                                                                | If you want to enable a specific set of diagnostic settings for the category 'Logs'. By default, all categories for 'Logs' will be enabled.                                                                                                                        |
| DiagnosticSettingsMetrics           | <input type="checkbox">         | `@('Requests';'MongoRequests';)`                                                                                                                | If you want to enable a specific set of diagnostic settings for the category 'Metrics'. By default, all categories for 'Metrics' will be enabled.                                                                                                                  |
| DiagnosticSettingsDisabled          | <input type="checkbox">         | n.a.                                                                                                                                            | If you don't want to enable any diagnostic settings, you can pass this as a switch witout a value(`-DiagnosticsettingsDisabled`).                                                                                                                                  |

# VNET Whitelisting Parameters

If you want to use "vnet whitelisting" on your resource. Use these parameters. Using VNET Whitelisting is the recommended way of building & connecting your application stack within Azure.

> NOTE: These parameters are only required when you want to use the VNet whitelisting feature for this resource.

| Parameter                        | Required for VNET Whitelisting  | Example Value                        | Description                                                              |
| -------------------------------- | ------------------------------- | ------------------------------------ | ------------------------------------------------------------------------ |
| ApplicationVnetResourceGroupName | <input type="checkbox" checked> | `sharedservices-rg`                  | The ResourceGroup where your VNET, for your storage account, resides in. |
| ApplicationVnetName              | <input type="checkbox" checked> | `my-vnet-$(Release.EnvironmentName)` | The name of the VNET the storage account is in                           |
| ApplicationSubnetName            | <input type="checkbox" checked> | `app-subnet-4`                       | The subnetname for the subnet whitelist on the storage account.          |

# Private Endpoint Parameters

If you want to use private endpoints on your resource. Use these parameters. Private Endpoints are used for connecting to your Azure Resources from on-premises.

> NOTE: These parameters are only required when you want to use a private endpoint for this resource.

| Parameter                                          | Required for Pvt Endpoint       | Example Value                           | Description                                                                                                                      |
| -------------------------------------------------- | ------------------------------- | --------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| StorageAccountPrivateEndpointVnetResourceGroupName | <input type="checkbox" checked> | `sharedservices-rg`                     | The ResourceGroup where your VNET, for your storage account private endpoint, resides in.                                        |
| StorageAccountPrivateEndpointVnetName              | <input type="checkbox" checked> | `my-vnet-$(Release.EnvironmentName)`    | The name of the VNET to place the storage account private endpoint in.                                                           |
| StorageAccountPrivateEndpointSubnetName            | <input type="checkbox" checked> | `app-subnet-3`                          | The name of the subnet where the storageaccount's private endpoint will reside in.                                               |
| PrivateEndpointGroupId                             | <input type="checkbox" checked> | `blob`                                  | A private endpoint per storagetype is needed. Use `az network private-link-resource list` to fetch a list of possible group id's |
| DNSZoneResourceGroupName                           | <input type="checkbox" checked> | `MyDNSZones-$(Release.EnvironmentName)` | Make sure to use the shared DNS Zone resource group (you can only register a zone once per subscription).                        |
| StorageAccountPrivateDnsZoneName                   | <input type="checkbox" checked> | `privatelink.blob.core.windows.net`     | Generally this will be `privatelink.blob.core.windows.net`. This defines which DNS Zone to use for the private storage endpoint. |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Create Storage account"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/Storage-Accounts/Create-Storage-account.ps1"
    arguments: "-StorageAccountResourceGroupName '$(StorageAccountResourceGroupName)' -ResourceTags $(ResourceTags) -StorageAccountName '$(StorageAccountName)' -StorageAccountKind '$(StorageAccountKind)'-StorageAccountSku '$(StorageAccountSku)' -StorageAccountAllowBlobPublicAccess '$(StorageAccountAllowBlobPublicAccess)' -LogAnalyticsWorkspaceResourceId '$(LogAnalyticsWorkspaceResourceId)' -ApplicationVnetResourceGroupName '$(ApplicationVnetResourceGroupName)' -ApplicationVnetName '$(ApplicationVnetName)' -ApplicationSubnetName '$(ApplicationSubnetName)' -StorageAccountPrivateEndpointVnetName '$(StorageAccountPrivateEndpointVnetName)' -StorageAccountPrivateEndpointVnetResourceGroupName '$(StorageAccountPrivateEndpointVnetResourceGroupName)' -StorageAccountPrivateEndpointSubnetName '$(StorageAccountPrivateEndpointSubnetName)' -PrivateEndpointGroupId '$(PrivateEndpointGroupId)' -DNSZoneResourceGroupName '$(DNSZoneResourceGroupName)' -StorageAccountPrivateDnsZoneName '$(StorageAccountPrivateDnsZoneName)' -StorageAccountMinimalTlsVersion '$(StorageAccountMinimalTlsVersion)' -DiagnosticSettingsLogs $(DiagnosticSettingsLogs) -DiagnosticSettingsDisabled $(DiagnosticSettingsDisabled)"
```

# Code

[Click here to download this script](../../../../src/Storage-Accounts/Create-Storage-account.ps1)

# Links

[Azure CLI - az-storage-account-create](https://docs.microsoft.com/en-us/cli/azure/storage/account?view=azure-cli-latest#az-storage-account-create)

[Azure CLI - az-network-vnet-subnet-update](https://docs.microsoft.com/en-us/cli/azure/network/vnet/subnet?view=azure-cli-latest#az-network-vnet-subnet-update)

[Azure CLI - az-storage-account-show](https://docs.microsoft.com/en-us/cli/azure/storage/account?view=azure-cli-latest#az-storage-account-show)

[Azure CLI - az-network-private-endpoint-create](https://docs.microsoft.com/en-us/cli/azure/network/private-endpoint?view=azure-cli-latest#az-network-private-endpoint-create)

[Azure CLI - az-network-private-dns-zone-show](https://docs.microsoft.com/en-us/cli/azure/ext/privatedns/network/private-dns/zone?view=azure-cli-latest#ext-privatedns-az-network-private-dns-zone-show)

[Azure CLI - az-network-private-dns-zone-create](https://docs.microsoft.com/en-us/cli/azure/ext/privatedns/network/private-dns/zone?view=azure-cli-latest#ext-privatedns-az-network-private-dns-zone-create)

[Azure CLI - az-network-private-dns-link-vnet-show](https://docs.microsoft.com/en-us/cli/azure/network/private-dns/link/vnet?view=azure-cli-latest#az-network-private-dns-link-vnet-show)

[Azure CLI - az-network-private-dns-link-vnet-create](https://docs.microsoft.com/en-us/cli/azure/network/private-dns/link/vnet?view=azure-cli-latest#az-network-private-dns-link-vnet-create)

[Azure CLI - az-network-private-endpoint-dns-zone-group-create](https://docs.microsoft.com/en-us/cli/azure/network/private-endpoint/dns-zone-group?view=azure-cli-latest#az-network-private-endpoint-dns-zone-group-create)

[Azure CLI - az-network-vnet-subnet-show](https://docs.microsoft.com/en-us/cli/azure/network/vnet/subnet?view=azure-cli-latest#az-network-vnet-subnet-show)

[Azure CLI - az-storage-account-network-rule-add](https://docs.microsoft.com/en-us/cli/azure/storage/account/network-rule?view=azure-cli-latest#az-storage-account-network-rule-add)

[Azure CLI - az-storage-account-update](https://docs.microsoft.com/en-us/cli/azure/storage/account?view=azure-cli-latest#az-storage-account-update)

[Azure CLI - az-network-private-link-resource-list](https://docs.microsoft.com/en-us/cli/azure/network/private-link-resource?view=azure-cli-latest#az-network-private-link-resource-list)

[Azure CLI - az monitor diagnostic-settings-create](https://docs.microsoft.com/nl-nl/cli/azure/monitor/diagnostic-settings?view=azure-cli-latest#az_monitor_diagnostic_settings_create)

[Azure - Private Endpoints for Storage](https://docs.microsoft.com/en-us/azure/storage/common/storage-private-endpoints)

[Azure - Storage Account Types](https://docs.microsoft.com/en-us/azure/storage/common/storage-account-overview)
