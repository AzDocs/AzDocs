[[_TOC_]]

# Description
This snippet creates a log analytics workspace. It is recommended to leave the public interface switches off (only private access).

# Parameters
Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.

| Parameter | Example Value | Description |
|--|--|--|
| LogAnalyticsWorkspaceResourceGroupName | `myteam-testapi-$(Release.EnvironmentName)` | The name of the resourcegroup you want your log analytics workspace to be created in |
| LogAnalyticsWorkspaceName | `My-Shared-Law-$(Release.EnvironmentName)` | The name you want to use for your log analytics-workspace.  |
| LogAnalyticsWorkspaceRetentionInDays | `30` | OPTIONAL: The retention in days for the log analytics workspace. NOTE: The default value is 30 days.  |
| PublicInterfaceIngestionEnabled | n.a. | If you pass this switch (without value), public access for ingestion data will be enabled for this log analytics workspace (you still need to be authenticated). |
| PublicInterfaceQueryAccess | n.a. | If you pass this switch (without value), public access for querying data will be enabled for this log analytics workspace (you still need to be authenticated). |

# Code
[Click here to download this script](../../../../src/Log-Analytics-Workspace/Create-Log-Analytics-Workspace.ps1)

# Links

[Azure CLI - az monitor log-analytics workspace create](https://docs.microsoft.com/en-us/cli/azure/monitor/log-analytics/workspace?view=azure-cli-latest#az_monitor_log_analytics_workspace_create)