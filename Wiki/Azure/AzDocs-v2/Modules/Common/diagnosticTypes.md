# diagnosticTypes

Target Scope: resourceGroup

## User Defined Types
| Name | Type | Discriminator | Description
| -- |  -- | -- | -- |
| <a id="diagnosticLogCategory">diagnosticLogCategory</a>  | <pre>{</pre> |  | Diagnostic settings log category configuration | 
| <a id="diagnosticMetricCategory">diagnosticMetricCategory</a>  | <pre>{</pre> |  | Diagnostic settings metrics category configuration | 

## Synopsis
Common diagnostic settings types for Azure resources

## Description
This module defines shared user-defined types for diagnostic settings that can be used across all Azure resource modules.<br>
These types provide type safety and documentation for diagnostic settings parameters.

## Links
- [Azure Monitor diagnostic settings](https://learn.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?pivots=deployment-language-bicep)
