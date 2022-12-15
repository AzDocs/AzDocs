[[_TOC_]]

# Logic Apps

When creating Logic Apps, you have two options to choose from:

- Logic App - Standard
- Logic App - Consumption

## Standard

When creating the resource, you have the possiblity to create a Logic App - Standard. The Standard is a single-tenant Logic App, runs on an App Service Plan and has the possibility to have multiple stateful or stateless workflows. The Standard has integrated support for virtual networks and private endpoints and is based upon the Function App platform extensibility. Because of this, the Standard will also need a storage account to operate.

Most of the Function App scripts can (will) also be used for the Logic App.

### Networking

For the Standard type, the following options are available:

- Public
- Private Endpoints
- VNet Whitelisting
- A combination of private endpoints and VNet whitelisting

**To be clear, we strongly advise against using public resources for obvious security implications.** Please refer to [Networking - When to use what?](/Azure/General-Documentation/Networking#when-to-use-what?) to find out what networking type suits you best. If you however do need to create a public resource, make sure to add the switch `-ForcePublic` to your task, if not, your task will fail. Whenever you plan on using Private Endpoints or/and VNet whitelisting for resources this Logic App should be able to reach, make sure to enable your VNet integration on your Logic App to be able to reach those resources in a secure & compliant way. You can use [Add-VNET-integration-to-Function-App](/Azure/AzDocs-v1/Scripts/Functions/Add-VNet-integration-to-Function-App) to enable VNet integration on your Logic App. For more information about networking and how it works, please refer to [Networking](/Azure/General-Documentation/Networking)

You can use the [Add-Network-Whitelist-to-Function-App](/Azure/AzDocs-v1/Scripts/Functions/Add-Network-Whitelist-to-Function-App) script to whitelist IP's or subnets (VNet Whitelisting) on your Azure Logic App.

_Note: When using Private Endpoints, make sure to add several private endpoints to the storage account for the different subresources the Logic App needs. These are Table, Queue, Blob and File storage. See https://docs.microsoft.com/en-us/azure/logic-apps/deploy-single-tenant-logic-apps-private-storage-account for more information._

## Consumption

When creating the resource, you have the possibility to create a Logic App - Consumption. The Consumption variant is a multi-tenant Logic App, but can only have one workflow per Logic App. This variant has no networking options (out of the box) available.

There is a possibility to use ISE, but these are not yet supported by the scripts. See https://docs.microsoft.com/en-us/azure/logic-apps/connect-virtual-network-vnet-isolated-environment for more information.

We advise to only use these when you have no internet-facing workflows and when you have no need to integrate with the VNet.

## Managed Identity

We automatically create a system-assigned identity for your Logic App for the Standard plan.

## Logging

You have the ability to disable the diagnostic settings for your Logic App. When you want to do this, add the switch `DiagnosticSettingsDisabled`. Next to that, you have the ability to specify which set of diagnostic logs you would like to enable.

For the category `logs` the parameter `DiagnosticSettingsLogs` can be used and for the category `metrics` the parameter `DiagnosticSettingsMetrics`. If you do not specify these settings, the default set (everything) will be enabled for your resource.

These logs get written to the Log Analytics Workspace that you specified.
