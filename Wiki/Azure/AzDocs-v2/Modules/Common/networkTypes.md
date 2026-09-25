# networkTypes

Target Scope: resourceGroup

## User Defined Types
| Name | Type | Discriminator | Description
| -- |  -- | -- | -- |
| <a id="virtualNetworkRule">virtualNetworkRule</a>  | <pre>{<br>&nbsp;&nbsp;&nbsp;@description('The resource ID of the subnet')<br>&nbsp;&nbsp;&nbsp;id: string<br><br>&nbsp;&nbsp;&nbsp;@description('Whether to ignore missing virtual network service endpoint')<br>&nbsp;&nbsp;&nbsp;ignoreMissingVnetServiceEndpoint: bool?<br>}<br></pre> |  | Virtual network rule for network access control | 
| <a id="ipRule">ipRule</a>  | <pre>{<br>&nbsp;&nbsp;&nbsp;@description('The IP address or CIDR range to allow access from')<br>&nbsp;&nbsp;&nbsp;value: string<br>}</pre> |  | IP rule for network access control | 

## Synopsis
Common network access control types for Azure resources

## Description
This module defines shared user-defined types for network access controls that can be used across all Azure resource modules.<br>
These types provide type safety and documentation for network security parameters.

## Links
- [Azure network access controls](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/networksecuritygroups?pivots=deployment-language-bicep)
