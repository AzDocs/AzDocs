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

When creating resources inside of your storage account (blobcontainer / queues / fileshare), we recommend creating these inside your application. Find more information here:

- [Blob container creation](https://docs.microsoft.com/en-us/azure/storage/blobs/storage-quickstart-blobs-dotnet#code-examples)
- [Queue creation](https://docs.microsoft.com/en-us/azure/storage/queues/storage-dotnet-how-to-use-queues?tabs=dotnet)
- [Fileshare creation](https://docs.microsoft.com/en-us/azure/storage/files/storage-dotnet-how-to-use-files?tabs=dotnet#access-the-file-share-programmatically)

If you do want to create these resources by using the scripts, we recommend, because of the following [Github issue](https://github.com/MicrosoftDocs/azure-docs/issues/19456), using a selfhosted agent to deploy your storage account when using VNet whitelisting and/or private endpoints. More information about creating a selfhosted agent can be found here [Selfhosted Agents](/Azure/Documentation/How-to-use-the-scripts#Deploying-to-SelfHosted-Agents-in-Pool).

You can use the [Add-Network-Whitelist-to-StorageAccount](/Azure/Azure-CLI-Snippets/Storage-Accounts/Add-Network-Whitelist-to-StorageAccount) script to whitelist IP's or subnets (VNet Whitelisting) on your Azure Storage account. When choosing VNet whitelisting, make sure to whitelist the subnet the selfhosted agent resides in.

## Tier

You can create your storage account based upon different types and corresponding tiers. You specify these values in the parameter `StorageAccountKind` and `StorageAccountSku`. For more information about which types and tiers you can choose, see [Storage account tiers](https://docs.microsoft.com/en-us/azure/storage/common/storage-account-overview)

## Logging

Diagnostic settings are enabled for your Storage Account These logs get written to the Log Analytics Workspace that you specified. Easy as that!
