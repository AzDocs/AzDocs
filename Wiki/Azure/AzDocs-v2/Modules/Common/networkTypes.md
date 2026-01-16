# networkTypes

Target Scope: resourceGroup

## User Defined Types
| Name | Type | Discriminator | Description
| -- |  -- | -- | -- |
| <a id="virtualNetworkRule">virtualNetworkRule</a>  | <pre>{</pre> |  | Virtual network rule for network access control | 
| <a id="ipRule">ipRule</a>  | <pre>{</pre> |  | IP rule for network access control | 

## Synopsis
Common network access control types for Azure resources

## Description
This module defines shared user-defined types for network access controls that can be used across all Azure resource modules.<br>
These types provide type safety and documentation for network security parameters.

## Links
- [Azure network access controls](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/networksecuritygroups?pivots=deployment-language-bicep)
