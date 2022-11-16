# virtualMachines

Target Scope: resourceGroup

## Synopsis
Creating a Virtual Machine

## Description
Creating a Virtual machine with the given specs.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location. |
| operatingSystem | string | <input type="checkbox" checked> | `'Windows'` or  `'Linux'` | <pre></pre> | Select the OS type to deploy: |
| virtualMachineName | string | <input type="checkbox" checked> | Length between 1-64 | <pre></pre> | The name of the virtual machine to be upserted.<br>Min length: 1<br>Max length: 15 for windows & 64 for linux. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| virtualMachineSubnetResourceId | string | <input type="checkbox"> | None | <pre>''</pre> | Specifies the resource id of the subnet where the default NIC should be onboarded into. If you don\'t fill the `networkInterfaces` parameter, this parameter is required. |
| virtualMachineAuthenticationMethod | string | <input type="checkbox"> | `'sshPublicKey'` or  `'password'` | <pre>'password'</pre> | Specifies the type of authentication when accessing the Virtual Machine. SSH key is recommended for Linux. |
| virtualMachineAdminUsername | string | <input type="checkbox" checked> | Length between 1-32 | <pre></pre> | Specifies the name of the administrator account of the virtual machine. |
| virtualMachineAdminPasswordOrPublicKey | string | <input type="checkbox" checked> | Length between 12-* | <pre></pre> | Specifies the SSH Key or password for the virtual machine. SSH key is recommended for Linux.<br>For password: Please enter the password as a string.<br>For SSH keys: Please pass the SSH key as a string. This can be done for example using loadTextContent('publickey.pub') to load the text from the publickey.pub file which holds the public part of the SSH key.<br><br>To import a string (either password or SSH-key) you also have the option to do this securely using a keyvault. You can, for example, reference an existing keyvault and call the getSecret() method on it to fetch the secret to input into this module. |
| virtualMachineSize | string | <input type="checkbox"> | None | <pre>'Standard_D1_v2'</pre> | Specifies the size of the virtual machine. For more options, please refer to https://docs.microsoft.com/en-us/azure/virtual-machines/sizes |
| osDisk | object | <input type="checkbox"> | None | <pre>{<br>  name: 'osdisk-${virtualMachineName}'<br>  caching: 'ReadWrite'<br>  createOption: 'FromImage'<br>  diskSizeGB: 100<br>  managedDisk: {<br>    storageAccountType: 'StandardSSD_LRS'<br>  }<br>}</pre> | This is the configuration for the OS Disk for this virtual machine. For formatting & options, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.compute/virtualmachines?pivots=deployment-language-bicep#osdisk. |
| dataDisks | array | <input type="checkbox"> | None | <pre>[]</pre> | The datadisk configuration for this VM.<br>Defaults to no datadisks.<br><br>For easy creation of new Empty Datadisks, you can use this example:<br>dataDisks: [for j in range(0, numberOfDataDisks): {<br>&nbsp;&nbsp;&nbsp;caching: 'ReadWrite'<br>&nbsp;&nbsp;&nbsp;diskSizeGB: 200<br>&nbsp;&nbsp;&nbsp;lun: j<br>&nbsp;&nbsp;&nbsp;name: 'disk-${j >= 10 ? '${j}' : '0${j}'}-${virtualMachineName}'<br>&nbsp;&nbsp;&nbsp;createOption: 'Empty'<br>&nbsp;&nbsp;&nbsp;managedDisk: {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;storageAccountType: 'StandardSSD_LRS'<br>&nbsp;&nbsp;&nbsp;}<br>}] |
| networkInterfaces | array | <input type="checkbox"> | None | <pre>[]</pre> | The array of network interfaces to create for this VM. For formatting & options please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.compute/virtualmachines?pivots=deployment-language-bicep#networkinterfacereference.<br><br>If you leave this empty, this script will create 1 default NIC for you. If you fill this, the default option will be omitted/skipped.<br><br>Simple example with 1 NIC:<br>networkInterfaces: [<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;id: '/subscriptions/$(SubscriptionId)/resourceGroups/$(ResourceGroupName)/providers/Microsoft.Network/networkInterfaces/$(NetworkInterfaceName)'<br>&nbsp;&nbsp;&nbsp;}<br>] |
| virtualMachineImageReference | object | <input type="checkbox"> | None | <pre>{<br>  publisher: 'MicrosoftWindowsServer'<br>  offer: 'WindowsServer'<br>  sku: '2019-Datacenter'<br>  version: 'latest'<br>}</pre> | Define the image you want to use for this VM. For formatting & options, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.compute/virtualmachines?pivots=deployment-language-bicep#imagereference.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;publisher: 'Canonical'<br>&nbsp;&nbsp;&nbsp;offer: '0001-com-ubuntu-server-focal'<br>&nbsp;&nbsp;&nbsp;sku: '20_04-lts'<br>&nbsp;&nbsp;&nbsp;version: 'latest'<br>}<br>Other examples:<br>Among others, options are:<br>`publisher`: Canonical (for Ubuntu), RedHat (for Red Hat Linux), MicrosoftWindowsServer (for Windows Server).<br>`offer`: UbuntuServer (for Ubuntu), RHEL for (Red Hat Linux), WindowsServer (for Windows Server)<br>`sku`: 18.04-LTS (for Ubuntu) , 7.8 (for Red Hat Linux), 2019-Datacenter (for Windows Server) |
| bootDiagnosticsStorageAccountName | string | <input type="checkbox"> | Length between 0-24 | <pre>''</pre> | Specifies the name of the storage account where the bootstrap diagnostic logs of the virtual machine are stored. Leave empty to disable boot diagnostics. |
| availabilitySetName | string | <input type="checkbox"> | Length between 0-80 | <pre>''</pre> | You cannot both have Availability Zone and Availability Set specified. Deploying an Availability Set to an Availability Zone is not supported. |
| availabilitySetPlatformFaultDomainCount | int | <input type="checkbox"> | Value between 1-20 | <pre>3</pre> | The amount of fault domains you want to assign to this availabilityset. |
| availabilitySetPlatformUpdateDomainCount | int | <input type="checkbox"> | Value between 1-20 | <pre>5</pre> | The amount of update domains you want to assign to this availabilityset. |
| virtualMachineNetworkInterfaceName | string | <input type="checkbox"> | Length between 0-80 | <pre>'nic-${take(virtualMachineName, 76)}'</pre> | The name of the NIC for this VM. Defaults to nic-<vmBaseName>-<environmentType>. |
| loadBalancerBackendAddressPoolResourceIds | array | <input type="checkbox"> | None | <pre>[]</pre> | A list of resource id\'s referencing to the backend address pools of the loadbalancer.<br>NOTE: If you use the `networkInterfaces` parameter, this value is not used.<br>Example:<br>[<br>&nbsp;&nbsp;&nbsp;'/resource/id/to/my/backEndAddressPool'<br>&nbsp;&nbsp;&nbsp;'/resource/id/to/my/backEndAddressPool'<br>] |
| loadBalancerInboundNatRuleResourceIds | array | <input type="checkbox"> | None | <pre>[]</pre> | A list of resource id\'s referencing to the inbound nat rules of the loadbalancer.<br>NOTE: If you use the `networkInterfaces` parameter, this value is not used.<br>Example:<br>[<br>&nbsp;&nbsp;&nbsp;'/resource/id/to/my/natRule'<br>&nbsp;&nbsp;&nbsp;'/resource/id/to/my/natRule2'<br>] |
| enableAcceleratedNetworking | bool | <input type="checkbox"> | None | <pre>false</pre> | Enable Accelerated Networking for the vm\'s default interface. Defaults to `false`.<br>NOTE: If you use the `networkInterfaces` parameter, this value is not used. |
| availabilityZones | array | <input type="checkbox"> | Length between 0-1 | <pre>[]</pre> | Example:<br>[1]<br>You cannot both have Availability Zone and Availability Set specified. Deploying an Availability Set to an Availability Zone is not supported. |
| bootdiagnosticsEnabled | bool | <input type="checkbox"> | None | <pre>true</pre> | If you want to have bootdiagnostics enabled on the Virtual Machine. More info https://docs.microsoft.com/en-us/azure/virtual-machines/boot-diagnostics. |
| provisionVMAgent | bool | <input type="checkbox"> | None | <pre>true</pre> | If the provision agent should be installed. |
| linuxConfiguration | object | <input type="checkbox"> | None | <pre>{}</pre> | The bicep object to configure the linux vm configuration when creating the vm. |
| windowsConfiguration | object | <input type="checkbox"> | None | <pre>{<br>  enableAutomaticUpdates: true<br>  patchSettings: {<br>    patchMode: 'AutomaticByOS'<br>    assessmentMode: 'ImageDefault'<br>  }<br>  enableVMAgentPlatformUpdates: false<br>}</pre> | The bicep object to configure the Windows vm configuration when creating the vm. |
| OSLicenseType | string | <input type="checkbox"> | `'RHEL_BYOS'` or  `'SLES_STANDARD'` or  `'SLES_SAP'` or  `'SLES_HPC'` or  `'SLES'` or  `'RHEL_SAPHA'` or  `'RHEL_SAPAPPS'` or  `'RHEL_ELS_6'` or  `'RHEL_EUS'` or  `'RHEL_BASE'` or  `'SLES_BYOS'` or  `'RHEL_BASESAPAPPS'` or  `'RHEL_BASESAPHA'` or  `'Windows_Server'` or  `'Windows_Client'` or  `'None'` or  `''` | <pre>''</pre> | Type of OS licensing.<br>For customers with Software Assurance, Azure Hybrid Benefit for Windows Server allows you to use your on-premises Windows Server licenses and run Windows virtual machines on Azure at a reduced cost.<br>You can use Azure Hybrid Benefit for Windows Server to deploy new virtual machines with Windows OS.<br>Azure Hybrid Benefit provides software updates and integrated support directly from Azure infrastructure for Red Hat Enterprise Linux (RHEL) and SUSE Linux Enterprise Server (SLES) virtual machines. |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| availabilitysetResourceId | string | Output the availability set\'s Resource ID. |
| virtualMachineName | string | Outputs the name of the virtual machine created or upserted |
| virtualMachineResourceId | string | Output the resourceId of the virtual machine created or upserted |
## Examples
<pre>
module vm '../../AzDocs/src-bicep/Compute/virtualMachines.bicep' = {
  name: 'Creating_VM_MyFirstVM'
  scope: resourceGroup
  params: {
    operatingSystem: 'Windows'
    virtualMachineName: 'MyFirstVM'
    virtualMachineSubnetResourceId: virtualMachineSubnetResourceId
    virtualMachineAdminUsername: 'vmadmin'
    virtualMachineAdminPasswordOrPublicKey: 'VerySecretPassW0rd'
  }
}
</pre>
<p>Creates a virtual machine with the name MyFirstVM</p>

## Links
- [Bicep Microsoft.Compute virtualMachines](https://docs.microsoft.com/en-us/azure/templates/microsoft.compute/virtualmachines?pivots=deployment-language-bicep)<br>
- [Virtual Machines sizes](https://docs.microsoft.com/en-us/azure/virtual-machines/sizes')<br>
- [BYOL, Hybrid Benefit](https://learn.microsoft.com/en-us/azure/virtual-machines/windows/hybrid-use-benefit-licensing)


