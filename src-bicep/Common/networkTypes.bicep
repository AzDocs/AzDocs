metadata name = 'Common Network Types'
metadata description = 'Shared user-defined types for Azure network access controls across all modules.'

/*
.SYNOPSIS
Common network access control types for Azure resources
.DESCRIPTION
This module defines shared user-defined types for network access controls that can be used across all Azure resource modules.
These types provide type safety and documentation for network security parameters.
.LINKS
- [Azure network access controls](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/networksecuritygroups?pivots=deployment-language-bicep)
*/

// ================================================= User-Defined Types =================================================

@export()
@description('Virtual network rule for network access control')
type virtualNetworkRule = {
  @description('The resource ID of the subnet')
  id: string

  @description('Whether to ignore missing virtual network service endpoint')
  ignoreMissingVnetServiceEndpoint: bool?
}

@export()
@description('IP rule for network access control')
type ipRule = {
  @description('The IP address or CIDR range to allow access from')
  value: string
}
