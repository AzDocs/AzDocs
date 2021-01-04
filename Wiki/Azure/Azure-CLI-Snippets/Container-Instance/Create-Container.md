[[_TOC_]]

# Description

This snippet will create an Azure Container Instances instance for you. It will be integrated into the given subnet.

# Parameters

Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.

| Parameter | Example Value | Description |
|--|--|--|
| ContainerName | `mycontainername` | The name of the container instance. |
| ContainerResourceGroupName | `Myteam-MyApp-$(Release.EnvironmentName)` | The resourcegroup where the container should be. |
| ContainerCpuCount | `4` | The amount of CPU-cores the container should be able to use. |
| ContainerMemoryInGb | `8` | The amount of memory your container may use. Expressed in GB's. |
| ContainerOs | `Linux` | The OS which is used in & underneath the container. Can be either `Linux` or `Windows`. |
| ContainerPorts | `80 443` | Space delimited list of ports you want to expose to the container. |
| ContainerImageName | `myacr.azurecr.io/mycompany/myimage:latest` | The image name to use. Please refer to [this docker documentation](https://docs.docker.com/engine/reference/commandline/tag/) for information about image & tag naming. |
| ContainerSubnetName | `my-subnet-123` | The subnetname for the subnet where the container should land in. |
| RegistryLoginServer | `myacr.azurecr.io` | OPTIONAL: The address of the registry login server. This is usualy the address of the image repository itself. |
| RegistryUserName | `myuser` | OPTIONAL: The username to use to authenticate against the image registry. |
| RegistryPassword | `S0m3S3cre7P@ssw0rd123!` | OPTIONAL: The password to use to authenticate against the image registry. |
| ContainerEnvironmentVariables | `'ENVIRONMENT="ACC";SOMECONNECTIONSTRING="THISISMYCONNECTIONSTRING"` | OPTIONAL: A list of environmentvariables which should be made available inside the container. This should be delimited by the value from `ContainerEnvironmentVariablesDelimiter`. |
| ContainerEnvironmentVariablesDelimiter | `;` | OPTIONAL: This is the delimiter for `ContainerEnvironmentVariables`. This defaults to `;`. |
| AzureFileShareName | `myfileshare` | OPTIONAL: The name of the fileshare inside the storage account. |
| AzureFileShareStorageAccountName | `mystorageaccount` | OPTIONAL: The name of the storage accountname where the fileshare resides in. |
| AzureFileShareStorageAccountResourceGroupName | `MyTeam-MyApp-$(Release.EnvironmentName)` | OPTIONAL: The resourcegroupname of the resourcegroup where the storageaccount resides in. |
| AzureFileShareMountPat | `/var/log/someapp` | OPTIONAL: The path to mount the given fileshare inside the container. |
| logAnalyticsWorkspaceId | `225c2873-c15f-42da-a5d2-0dfb3df76da0` | OPTIONAL: The log analytics workspace Id |
| logAnalyticsWorkspaceKey | `RGl0IGlzIGVlbiBvbmdlbGRpZ2UgdG9rZW4g8J+YgfCfmIHwn5iB8J+YgfCfmIHwn5iBLg==`| OPTIONAL: Primary or Secondary Key of the log analytics workspace. |

# Code

[Click here to download this script](../../../../src/Container-Instance/Create-Container.ps1)

# Links

[Azure CLI - az network vnet show](https://docs.microsoft.com/en-us/cli/azure/network/vnet?view=azure-cli-latest#az_network_vnet_show)

[Azure CLI - az container create](https://docs.microsoft.com/en-us/cli/azure/container?view=azure-cli-latest#az_container_create)