# diagnosticTypes

Target Scope: resourceGroup

## User Defined Types
| Name | Type | Discriminator | Description
| -- |  -- | -- | -- |
| <a id="diagnosticLogCategory">diagnosticLogCategory</a>  | <pre>{<br>&nbsp;&nbsp;&nbsp;@description('The name of the log category')<br>&nbsp;&nbsp;&nbsp;category: string?<br><br>&nbsp;&nbsp;&nbsp;@description('The name of the log category group')<br>&nbsp;&nbsp;&nbsp;categoryGroup: string?<br><br>&nbsp;&nbsp;&nbsp;@description('Whether the log category is enabled')<br>&nbsp;&nbsp;&nbsp;enabled: bool<br><br>&nbsp;&nbsp;&nbsp;@description('The retention policy for the log category')<br>&nbsp;&nbsp;&nbsp;retentionPolicy: {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('The number of days to retain the logs')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;days: int<br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Whether the retention policy is enabled')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;enabled: bool<br>&nbsp;&nbsp;&nbsp;}?<br>}<br></pre> |  | Diagnostic settings log category configuration | 
| <a id="diagnosticMetricCategory">diagnosticMetricCategory</a>  | <pre>{<br>&nbsp;&nbsp;&nbsp;@description('The name of the metric category')<br>&nbsp;&nbsp;&nbsp;category: string<br><br>&nbsp;&nbsp;&nbsp;@description('Whether the metric category is enabled')<br>&nbsp;&nbsp;&nbsp;enabled: bool<br><br>&nbsp;&nbsp;&nbsp;@description('The retention policy for the metric category')<br>&nbsp;&nbsp;&nbsp;retentionPolicy: {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('The number of days to retain the metrics')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;days: int<br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@description('Whether the retention policy is enabled')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;enabled: bool<br>&nbsp;&nbsp;&nbsp;}?<br><br>&nbsp;&nbsp;&nbsp;@description('The time grain for the metric category')<br>&nbsp;&nbsp;&nbsp;timeGrain: string?<br>}</pre> |  | Diagnostic settings metrics category configuration | 

## Synopsis
Common diagnostic settings types for Azure resources

## Description
This module defines shared user-defined types for diagnostic settings that can be used across all Azure resource modules.<br>
These types provide type safety and documentation for diagnostic settings parameters.

## Links
- [Azure Monitor diagnostic settings](https://learn.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?pivots=deployment-language-bicep)
