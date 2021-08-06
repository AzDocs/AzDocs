[[_TOC_]]

# Log Analytics Workspace

When creating a [Log Analytics Workspace](/Azure/Azure-CLI-Snippets/Log-Analytics-Workspace/Create-Log-Analytics-Workspace), you have some options to choose from:

## Public network access

When creating a Log Analytics Workspace, you have the possibility to configure network access for the ingestion of the LAW and the Query access. These two parameters, `PublicInterfaceIngestionEnabled` and `PublicInterfaceQueryAccess`, can be added as a switch to enable these settings.

## Workspace solution types

Several workspace solution types can be added to your Log Analytics Workspace. A solution type can provide analysis of an operation or a particular service. To find out more about solution types, see [Azure Solution types](https://docs.microsoft.com/en-us/azure/azure-monitor/insights/ad-assessment)
