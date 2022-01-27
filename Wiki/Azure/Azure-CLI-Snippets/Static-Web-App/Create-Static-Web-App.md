[[_TOC_]]

# Description

This snippet will create a Static Web App if it does not exist. If the location is not supplied, the location of the resource group will be used.

# Parameters

| Parameter                     | Required                        | Example Value                               | Description                                                                                                                |
| ----------------------------- | ------------------------------- | ------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------- |
| StaticWebAppName              | <input type="checkbox" checked> | `myteam-spa-$(Release.EnvironmentName)`     | Name of the Static Web App. Please note that it is not the url of the created statis web app site                          |
| StaticWebAppResourceGroupName | <input type="checkbox" checked> | `myteam-project-$(Release.EnvironmentName)` | The name for the resource group to deploy the static webpp.                                                                |
| StaticWebAppLocation          | <input type="checkbox">         | `westeurope`                                | The location in Azure the resource should be created, if not supplied it will default on the resource group location.      |
| StaticWebAppSkuName           | <input type="checkbox">         | `Free` / `Standard`                         | Sku type of the static web app. See [the features](https://docs.microsoft.com/en-us/azure/static-web-apps/plans#features). |

# Private Endpoint Parameters

If you want to use private endpoints on your resource. Use these parameters. Private Endpoints are used for connecting to your Azure Resources from on-premises.

> NOTE: These parameters are only required when you want to use a private endpoint for this resource.

| Parameter                                        | Required for Pvt Endpoint       | Example Value                           | Description                                                                                               |
| ------------------------------------------------ | ------------------------------- | --------------------------------------- | --------------------------------------------------------------------------------------------------------- |
| StaticWebAppPrivateEndpointVnetName              | <input type="checkbox" checked> | `my-vnet-$(Release.EnvironmentName)`    | The name of the VNET to place the Static Web App  Private Endpoint in.                                    |
| StaticWebAppPrivateEndpointVnetResourceGroupName | <input type="checkbox" checked> | `sharedservices-rg`                     | The ResourceGroup where your VNET, for your App Service Private Endpoint, resides in.                     |
| DNSZoneResourceGroupName                         | <input type="checkbox" checked> | `MyDNSZones-$(Release.EnvironmentName)` | Make sure to use the shared DNS Zone resource group (you can only register a zone once per subscription). |
| StaticWebAppPrivateEndpointSubnetName            | <input type="checkbox" checked> | `app-subnet-3`                          | The subnet to place the private endpoint for this StaticWebApp in                                         |

# YAML task

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Create Static Web App $(Name)"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/Static-Web-App/Create-Static-Web-App.ps1"
    arguments: >
      -StaticWebAppResourceGroupName '$(ResourceGroupName)' 
      -StaticWebAppName '$(Name)' 
      -StaticWebAppLocation '$(ResourceGroupLocation)' 
      -StaticWebAppSkuName '$(SkuName)'
      -StaticWebAppPrivateEndpointVnetName '$(StaticWebAppPrivateEndpointVnetName)'
      -StaticWebAppPrivateEndpointVnetResourceGroupName '$(StaticWebAppPrivateEndpointVnetResourceGroupName)'
      -DNSZoneResourceGroupName '$(DNSZoneResourceGroupName)'
      -StaticWebAppPrivateEndpointSubnetName '$(StaticWebAppPrivateEndpointSubnetName)'
```

# Code

[Click here to download this script](../../../../src/Static-Web-App/Create-Static-Web-App.ps1)

# Links

[Azure Powershell Module - New-AzStaticWebApp](https://docs.microsoft.com/en-us/powershell/module/az.websites/new-azstaticwebapp)
