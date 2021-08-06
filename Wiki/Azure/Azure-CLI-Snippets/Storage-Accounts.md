[[_TOC_]]

# Storage Accounts

When creating a [Storage Account](/Azure/Azure-CLI-Snippets/Storage-Accounts/Create-Storage-account), you have some options to choose from:

## Networking

When creating your storage account, we have enabled the ability to configure different ways of setting up the network for your storage account.

The following options are available:

- Public
- Private endpoints
- VNET whitelisting
- A combination of private endpoints and vnet whitelisting

**To be clear, we strongly advise against using public resources for obvious security implications.** Please refer to [Networking - When to use what?](/Azure/Documentation/Networking#when-to-use-what?) to find out what networking type suits you best. If you however do need to create a public resource, make sure to add the switch `-ForcePublic` to your task, if not, your task will fail.

You can use the [Add-Network-Whitelist-to-StorageAccount](/Azure/Azure-CLI-Snippets/Storage-Accounts/Add-Network-Whitelist-to-StorageAccount) script to whitelist IP's or subnets (VNet Whitelisting) on your Azure Storage Account.

## Tier

You can create your storage account based upon different types and corresponding tiers. You specify these values in the parameter `StorageAccountKind` and `StorageAccountSku`. For more information about which types and tiers you can choose, see [Storage account tiers](https://docs.microsoft.com/en-us/azure/storage/common/storage-account-overview)

## Logging

Diagnostic settings are enabled for your Storage Account These logs get written to the Log Analytics Workspace that you specified. Easy as that!
