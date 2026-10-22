# virtualMachines

Target Scope: resourceGroup

> [!NOTE]
> This module uses Bicep resource-derived types (`resourceInput<>` / `resourceOutput<>`).
> - [Resource-derived types](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/user-defined-data-types#resource-derived-types)
> - [Bicep data types](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/data-types)

## Synopsis
Creating a Virtual Machine

## Description
Creating a Virtual machine with the given specs.<br>
<br>
The defaults create a Windows Server 2025 Azure Edition VM of size `Standard_D2as_v6` with Trusted Launch (secure boot and vTPM), encryption at host and an NVMe disk controller.<br>
The Dasv6 family only supports Generation 2 images and the NVMe disk controller. When you choose an older size or a Generation 1 image, also set `diskControllerType` to `SCSI` and, for Generation 1 images, `virtualMachineSecurityType` to `Standard`.<br>
When you deploy this module over an existing virtual machine that was created without a security type, set `virtualMachineSecurityType` to an empty string. Azure does not allow adding a security type to such a virtual machine.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location. |
| operatingSystem | string | <input type="checkbox" checked> | `'Windows'` or `'Linux'` | <pre></pre> | Select the OS type to deploy: |
| virtualMachineName | string | <input type="checkbox" checked> | Length between 1-64 | <pre></pre> | The name of the virtual machine to be upserted.<br>Min length: 1<br>Max length: 15 for windows & 64 for linux. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| identity | [resourceInput<'Microsoft.Compute/virtualMachines@2025-04-01'>.identity](https://learn.microsoft.com/en-us/azure/templates/microsoft.compute/2025-04-01/virtualmachines?pivots=deployment-language-bicep) | <input type="checkbox"> | Schema-constrained (resource-derived type) | <pre>{<br>  type: 'SystemAssigned'<br>}</pre> | The managed identity configuration of the virtual machine. Defaults to a system assigned managed identity.<br>Allowed types are `SystemAssigned`, `UserAssigned`, `SystemAssigned, UserAssigned` and `None`.<br>Example with both a system assigned and a user assigned managed identity:<br>{<br>&nbsp;&nbsp;&nbsp;type: 'SystemAssigned, UserAssigned'<br>&nbsp;&nbsp;&nbsp;userAssignedIdentities: {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/{identityName}': {}<br>&nbsp;&nbsp;&nbsp;}<br>}<br><br>NOTE: Every deployment replaces the complete identity configuration of the virtual machine. User assigned identities that something outside this module attaches, for example an Azure Policy that assigns the identity the Azure Monitor Agent authenticates with, are removed on a redeploy unless you include them in `userAssignedIdentities`. Until the policy attaches the identity again, the agent cannot authenticate. |
| virtualMachineSubnetResourceId | string | <input type="checkbox"> | None | <pre>''</pre> | Specifies the resource id of the subnet where the default NIC should be onboarded into. If you don\'t fill the `networkInterfaces` parameter, this parameter is required. |
| virtualMachineAuthenticationMethod | string | <input type="checkbox"> | `'sshPublicKey'` or `'password'` | <pre>'password'</pre> | Specifies the type of authentication when accessing the Virtual Machine. SSH key is recommended for Linux. |
| virtualMachineAdminUsername | string | <input type="checkbox" checked> | Length between 1-32 | <pre></pre> | Specifies the name of the administrator account of the virtual machine. |
| virtualMachineAdminPasswordOrPublicKey | string | <input type="checkbox" checked> | Length between 12-* | <pre></pre> | Specifies the SSH Key or password for the virtual machine. SSH key is recommended for Linux.<br>For password: Please enter the password as a string.<br>For SSH keys: Please pass the SSH key as a string. This can be done for example using loadTextContent('publickey.pub') to load the text from the publickey.pub file which holds the public part of the SSH key.<br><br>To import a string (either password or SSH-key) you also have the option to do this securely using a keyvault. You can, for example, reference an existing keyvault and call the getSecret() method on it to fetch the secret to input into this module. |
| virtualMachineSize | string | <input type="checkbox"> | None | <pre>'Standard_D2as_v6'</pre> | Specifies the size of the virtual machine. Defaults to `Standard_D2as_v6` (2 vCPUs, 8 GiB memory).<br>The Dasv6 family requires a Generation 2 image and the `NVMe` disk controller. For more options, please refer to https://learn.microsoft.com/en-us/azure/virtual-machines/sizes |
| diskControllerType | string | <input type="checkbox"> | `'NVMe'` or `'SCSI'` | <pre>'NVMe'</pre> | Specifies the disk controller type of the virtual machine. Defaults to `NVMe`, which the default size `Standard_D2as_v6` requires.<br>Use `SCSI` for sizes that do not support NVMe, for example the Dv2 and Dv5 families. |
| virtualMachineSecurityType | string | <input type="checkbox"> | `''` or `'TrustedLaunch'` or `'ConfidentialVM'` or `'Standard'` | <pre>'TrustedLaunch'</pre> | Specifies the security type of the virtual machine. Defaults to `TrustedLaunch`, which requires a Generation 2 image.<br>Use `Standard` for Generation 1 images. `ConfidentialVM` requires a confidential VM size and a confidential OS disk configuration in `osDisk`.<br>Use an empty string to leave `securityType` out of the request. This is needed for an existing virtual machine that was created without a security type: Azure does not allow setting `securityType` on such a virtual machine afterwards, not even to `Standard`, and rejects the deployment with `PropertyChangeNotAllowed`. |
| secureBootEnabled | bool | <input type="checkbox"> | None | <pre>true</pre> | Specifies whether secure boot is enabled. Only used when `virtualMachineSecurityType` is `TrustedLaunch` or `ConfidentialVM`. Defaults to `true`. |
| vTpmEnabled | bool | <input type="checkbox"> | None | <pre>true</pre> | Specifies whether the virtual TPM is enabled. Only used when `virtualMachineSecurityType` is `TrustedLaunch` or `ConfidentialVM`. Defaults to `true`. |
| osDisk | [resourceInput<'Microsoft.Compute/virtualMachines@2025-04-01'>.properties.storageProfile.osDisk](https://learn.microsoft.com/en-us/azure/templates/microsoft.compute/2025-04-01/virtualmachines?pivots=deployment-language-bicep) | <input type="checkbox"> | Schema-constrained (resource-derived type) | <pre>{<br>  name: 'osdisk-&#36;{virtualMachineName}'<br>  caching: 'ReadWrite'<br>  createOption: 'FromImage'<br>  diskSizeGB: 128<br>  managedDisk: {<br>    storageAccountType: 'StandardSSD_LRS'<br>  }<br>}</pre> | This is the configuration for the OS Disk for this virtual machine. For formatting & options, please refer to https://learn.microsoft.com/en-us/azure/templates/microsoft.compute/virtualmachines?pivots=deployment-language-bicep#osdisk. |
| dataDisks | [resourceInput<'Microsoft.Compute/virtualMachines@2025-04-01'>.properties.storageProfile.dataDisks](https://learn.microsoft.com/en-us/azure/templates/microsoft.compute/2025-04-01/virtualmachines?pivots=deployment-language-bicep) | <input type="checkbox"> | Schema-constrained (resource-derived type) | <pre>[]</pre> | The datadisk configuration for this VM.<br>Defaults to no datadisks.<br><br>For easy creation of new Empty Datadisks, you can use this example:<br>dataDisks: [for j in range(0, numberOfDataDisks): {<br>&nbsp;&nbsp;&nbsp;caching: 'ReadWrite'<br>&nbsp;&nbsp;&nbsp;diskSizeGB: 200<br>&nbsp;&nbsp;&nbsp;lun: j<br>&nbsp;&nbsp;&nbsp;name: 'disk-&#36;{j >= 10 ? '&#36;{j}' : '0&#36;{j}'}-&#36;{virtualMachineName}'<br>&nbsp;&nbsp;&nbsp;createOption: 'Empty'<br>&nbsp;&nbsp;&nbsp;managedDisk: {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;storageAccountType: 'StandardSSD_LRS'<br>&nbsp;&nbsp;&nbsp;}<br>}] |
| networkInterfaces | array | <input type="checkbox"> | None | <pre>[]</pre> | The array of network interfaces to create for this VM. For formatting & options please refer to https://learn.microsoft.com/en-us/azure/templates/microsoft.compute/virtualmachines?pivots=deployment-language-bicep#networkinterfacereference.<br><br>If you leave this empty, this script will create 1 default NIC for you. If you fill this, the default option will be omitted/skipped.<br><br>Simple example with 1 NIC:<br>networkInterfaces: [<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;id: '/subscriptions/&#36;(SubscriptionId)/resourceGroups/&#36;(ResourceGroupName)/providers/Microsoft.Network/networkInterfaces/&#36;(NetworkInterfaceName)'<br>&nbsp;&nbsp;&nbsp;}<br>] |
| virtualMachineImageReference | object | <input type="checkbox"> | None | <pre>{<br>  publisher: 'MicrosoftWindowsServer'<br>  offer: 'WindowsServer'<br>  sku: '2025-datacenter-azure-edition'<br>  version: 'latest'<br>}</pre> | Define the image you want to use for this VM. Defaults to Windows Server 2025 Datacenter Azure Edition (Generation 2). For formatting & options, please refer to https://learn.microsoft.com/en-us/azure/templates/microsoft.compute/virtualmachines?pivots=deployment-language-bicep#imagereference.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;publisher: 'Canonical'<br>&nbsp;&nbsp;&nbsp;offer: 'ubuntu-24_04-lts'<br>&nbsp;&nbsp;&nbsp;sku: 'server'<br>&nbsp;&nbsp;&nbsp;version: 'latest'<br>}<br>Other examples:<br>Among others, options are:<br>`publisher`: Canonical (for Ubuntu), RedHat (for Red Hat Linux), MicrosoftWindowsServer (for Windows Server).<br>`offer`: ubuntu-24_04-lts (for Ubuntu), RHEL (for Red Hat Linux), WindowsServer (for Windows Server)<br>`sku`: server (for Ubuntu), 9-lvm-gen2 (for Red Hat Linux), 2025-datacenter-azure-edition (for Windows Server) |
| bootDiagnosticsStorageAccountName | string | <input type="checkbox"> | Length between 0-24 | <pre>''</pre> | Specifies the name of the storage account where the bootstrap diagnostic logs of the virtual machine are stored. Leave empty to use managed storage for boot diagnostics. |
| availabilitySetName | string | <input type="checkbox"> | Length between 0-80 | <pre>''</pre> | You cannot both have Availability Zone and Availability Set specified. Deploying an Availability Set to an Availability Zone is not supported. |
| availabilitySetPlatformFaultDomainCount | int | <input type="checkbox"> | Value between 1-20 | <pre>3</pre> | The amount of fault domains you want to assign to this availabilityset. |
| availabilitySetPlatformUpdateDomainCount | int | <input type="checkbox"> | Value between 1-20 | <pre>5</pre> | The amount of update domains you want to assign to this availabilityset. |
| virtualMachineNetworkInterfaceName | string | <input type="checkbox"> | Length between 0-80 | <pre>'nic-&#36;{take(virtualMachineName, 76)}'</pre> | The name of the NIC for this VM. Defaults to nic-<vmBaseName>-<environmentType>. |
| loadBalancerBackendAddressPoolResourceIds | array | <input type="checkbox"> | None | <pre>[]</pre> | A list of resource id\'s referencing to the backend address pools of the loadbalancer.<br>NOTE: If you use the `networkInterfaces` parameter, this value is not used.<br>Example:<br>[<br>&nbsp;&nbsp;&nbsp;'/resource/id/to/my/backEndAddressPool'<br>&nbsp;&nbsp;&nbsp;'/resource/id/to/my/backEndAddressPool'<br>] |
| loadBalancerInboundNatRuleResourceIds | array | <input type="checkbox"> | None | <pre>[]</pre> | A list of resource id\'s referencing to the inbound nat rules of the loadbalancer.<br>NOTE: If you use the `networkInterfaces` parameter, this value is not used.<br>Example:<br>[<br>&nbsp;&nbsp;&nbsp;'/resource/id/to/my/natRule'<br>&nbsp;&nbsp;&nbsp;'/resource/id/to/my/natRule2'<br>] |
| enableAcceleratedNetworking | bool | <input type="checkbox"> | None | <pre>true</pre> | Enable Accelerated Networking for the vm's default interface. Defaults to `true`, which the default size `Standard_D2as_v6` supports.<br>Set this to `false` for sizes that do not support accelerated networking. Changing this on an existing NIC requires the VM to be deallocated.<br>NOTE: If you use the `networkInterfaces` parameter, this value is not used. |
| availabilityZones | array | <input type="checkbox"> | Length between 0-1 | <pre>[]</pre> | Example:<br>['1']<br>You cannot both have Availability Zone and Availability Set specified. Deploying an Availability Set to an Availability Zone is not supported. |
| bootdiagnosticsEnabled | bool | <input type="checkbox"> | None | <pre>true</pre> | If you want to have bootdiagnostics enabled on the Virtual Machine. More info https://learn.microsoft.com/en-us/azure/virtual-machines/boot-diagnostics. |
| provisionVMAgent | bool | <input type="checkbox"> | None | <pre>true</pre> | If the provision agent should be installed. |
| bypassPlatformSafetyChecksOnUserSchedule | bool | <input type="checkbox"> | None | <pre>false</pre> | Specifies whether the virtual machine is patched by an Azure Update Manager maintenance configuration (patch orchestration "Customer Managed Schedules").<br>Set to `true` when a maintenance configuration covers this VM, for example through a dynamic scope on tags. Without a maintenance configuration assigned, a VM with `true` receives no automatic patches.<br>Defaults to `false`: Azure patches the VM in its off-peak hours.<br>On Windows, `true` also disables hotpatching, because Azure only allows hotpatching with the platform safety checks enabled.<br>Only applied when the `patchMode` in `windowsConfiguration` or `linuxConfiguration` is `AutomaticByPlatform`. See https://learn.microsoft.com/en-us/azure/update-manager/prerequsite-for-schedule-patching. |
| linuxConfiguration | [resourceInput<'Microsoft.Compute/virtualMachines@2025-04-01'>.properties.osProfile.linuxConfiguration](https://learn.microsoft.com/en-us/azure/templates/microsoft.compute/2025-04-01/virtualmachines?pivots=deployment-language-bicep) | <input type="checkbox"> | Schema-constrained (resource-derived type) | <pre>{<br>  patchSettings: {<br>    patchMode: 'AutomaticByPlatform'<br>    assessmentMode: 'AutomaticByPlatform'<br>  }<br>}</pre> | The bicep object to configure the linux vm configuration when creating the vm. For formatting & options, please refer to https://learn.microsoft.com/en-us/azure/templates/microsoft.compute/virtualmachines?pivots=deployment-language-bicep#linuxconfiguration.<br>Defaults to `AutomaticByPlatform` patching. Use `ImageDefault` for images that do not support platform patching, see https://learn.microsoft.com/en-us/azure/virtual-machines/automatic-vm-guest-patching#supported-os-images. |
| windowsConfiguration | [resourceInput<'Microsoft.Compute/virtualMachines@2025-04-01'>.properties.osProfile.windowsConfiguration](https://learn.microsoft.com/en-us/azure/templates/microsoft.compute/2025-04-01/virtualmachines?pivots=deployment-language-bicep) | <input type="checkbox"> | Schema-constrained (resource-derived type) | <pre>{<br>  enableAutomaticUpdates: true<br>  patchSettings: {<br>    patchMode: 'AutomaticByPlatform'<br>    assessmentMode: 'AutomaticByPlatform'<br>  }<br>}</pre> | The bicep object to configure the Windows vm configuration when creating the vm. For formatting & options, please refer to https://learn.microsoft.com/en-us/azure/templates/microsoft.compute/virtualmachines?pivots=deployment-language-bicep#windowsconfiguration.<br>Defaults to `AutomaticByPlatform` patching, which Hotpatch-compatible images such as the default `2025-datacenter-azure-edition` require. Use `AutomaticByOS` for images that do not support platform patching. |
| encryptionAtHost | bool | <input type="checkbox"> | None | <pre>true</pre> | This property can be used by user in the request to enable or disable the Host Encryption for the virtual machine or virtual machine scale set.<br>This will enable the encryption for all the disks including Resource/Temp disk at host itself.<br>Defaults to `true`. Requires the `EncryptionAtHost` feature to be registered on the subscription (`az feature register --namespace Microsoft.Compute --name EncryptionAtHost`).<br><br>Only set this to `false` for sizes that do not support encryption at host.<br>Azure Policy controlling this is described here [Virtual machines and virtual machine scale sets should have encryption at host enabled](https://www.azadvertizer.com/azpolicyadvertizer/fc4d8e41-e223-45ea-9bf5-eada37891d87.html) |
| OSLicenseType | string | <input type="checkbox"> | `'RHEL_BYOS'` or `'SLES_STANDARD'` or `'SLES_SAP'` or `'SLES_HPC'` or `'SLES'` or `'RHEL_SAPHA'` or `'RHEL_SAPAPPS'` or `'RHEL_ELS_6'` or `'RHEL_EUS'` or `'RHEL_BASE'` or `'SLES_BYOS'` or `'RHEL_BASESAPAPPS'` or `'RHEL_BASESAPHA'` or `'Windows_Server'` or `'Windows_Client'` or `'None'` or `''` | <pre>''</pre> | Type of OS licensing.<br>For customers with Software Assurance, Azure Hybrid Benefit for Windows Server allows you to use your on-premises Windows Server licenses and run Windows virtual machines on Azure at a reduced cost.<br>You can use Azure Hybrid Benefit for Windows Server to deploy new virtual machines with Windows OS.<br>Azure Hybrid Benefit provides software updates and integrated support directly from Azure infrastructure for Red Hat Enterprise Linux (RHEL) and SUSE Linux Enterprise Server (SLES) virtual machines. |
| customData | string? | <input type="checkbox" checked> | None | <pre></pre> | Specifies a base-64 encoded string of custom data.<br>The base-64 encoded string is decoded to a binary array that is saved as a file on the Virtual Machine.<br>The maximum length of the binary array is 65535 bytes.<br><br>**Note: Do not pass any secrets or passwords in customData property. **<br>This property cannot be updated after the VM is created.<br>The property 'customData' is passed to the VM to be saved as a file, for more information see [Custom Data on Azure VMs](https://azure.microsoft.com/blog/custom-data-and-cloud-init-on-windows-azure/).<br>For using cloud-init for your Linux VM, see [Using cloud-init to customize a Linux VM during creation](https://learn.microsoft.com/en-us/azure/virtual-machines/linux/using-cloud-init). |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| availabilitysetResourceId | string | Output the availability set\'s Resource ID. |
| virtualMachineName | string | Outputs the name of the virtual machine created or upserted |
| virtualMachineResourceId | string | Output the resourceId of the virtual machine created or upserted |
| virtualMachinePrincipalId | string | Output the principal id of the system assigned managed identity of the virtual machine. Empty when the virtual machine has no system assigned managed identity. |

## Examples
<pre>
resource keyVault 'Microsoft.KeyVault/vaults@2024-11-01' existing = {
  name: 'kv-myworkload-dev'
}

module vm 'br:contosoregistry.azurecr.io/compute/virtualmachines:latest' = {
  name: 'Creating_VM_MyFirstVM'
  scope: resourceGroup
  params: {
    operatingSystem: 'Windows'
    virtualMachineName: 'MyFirstVM'
    virtualMachineSubnetResourceId: virtualMachineSubnetResourceId
    virtualMachineAdminUsername: 'vmadmin'
    virtualMachineAdminPasswordOrPublicKey: keyVault.getSecret('vm-admin-password')
  }
}
</pre>
<p>Creates a Windows virtual machine with the name MyFirstVM and a system assigned managed identity.</p>
<pre>
resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2024-11-30' existing = {
  name: 'id-myworkload-dev'
}

module vm 'br:contosoregistry.azurecr.io/compute/virtualmachines:latest' = {
  name: 'Creating_VM_MyLinuxVM'
  scope: resourceGroup
  params: {
    operatingSystem: 'Linux'
    virtualMachineName: 'MyLinuxVM'
    virtualMachineSubnetResourceId: virtualMachineSubnetResourceId
    virtualMachineAdminUsername: 'vmadmin'
    virtualMachineAuthenticationMethod: 'sshPublicKey'
    virtualMachineAdminPasswordOrPublicKey: loadTextContent('publickey.pub')
    virtualMachineImageReference: {
      publisher: 'Canonical'
      offer: 'ubuntu-24_04-lts'
      sku: 'server'
      version: 'latest'
    }
    identity: {
      type: 'SystemAssigned, UserAssigned'
      userAssignedIdentities: {
        '${userAssignedIdentity.id}': {}
      }
    }
  }
}
</pre>
<p>Creates a Linux virtual machine with the name MyLinuxVM, SSH key authentication, and both a system assigned and a user assigned managed identity.</p>

## Links
- [Bicep Microsoft.Compute virtualMachines](https://learn.microsoft.com/en-us/azure/templates/microsoft.compute/virtualmachines?pivots=deployment-language-bicep)<br>
- [Virtual Machines sizes](https://learn.microsoft.com/en-us/azure/virtual-machines/sizes)<br>
- [Dasv6 series](https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/general-purpose/dasv6-series)<br>
- [Trusted Launch](https://learn.microsoft.com/en-us/azure/virtual-machines/trusted-launch)<br>
- [BYOL, Hybrid Benefit](https://learn.microsoft.com/en-us/azure/virtual-machines/windows/hybrid-use-benefit-licensing)
