[[_TOC_]]

# Container Instances

When creating a [Container Instance](/Azure/Azure-CLI-Snippets/Container-Instance/Create-Container), you have some options to choose from:

## Networking

When creating a Container Instance, we have enabled the ability to configure different ways of setting up the network.

The following options are available:

- Public
- Private

**To be clear, we strongly advise against using public resources for obvious security implications.** If you however do need to create a public resource, make sure to add the switch `-ForcePublic` to your task, if not, your task will fail.

## Mounting volumes

You have the possibility to mount an Azure Fileshare to the container by specifying the following parameters: `StorageAccountFileShareName`, `FileShareStorageAccountName` and `FileShareStorageAccountResourceGroupName`.

## Managed identities

We don't enable managed identity out of the box for this script, because it's not Generally Available yet. For more information, see [Azure Container Instance](https://docs.microsoft.com/en-us/azure/container-instances/container-instances-managed-identity)
