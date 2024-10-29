/*
.SYNOPSIS
Creating a Virtual Machine
.DESCRIPTION
Creating a Virtual machine with the given specs.
.EXAMPLE
<pre>
module vm 'br:contosoregistry.azurecr.io/compute/virtualmachines:latest' = {
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
.LINKS
- [Bicep Microsoft.Compute virtualMachines](https://docs.microsoft.com/en-us/azure/templates/microsoft.compute/virtualmachines?pivots=deployment-language-bicep)
- [Virtual Machines sizes](https://docs.microsoft.com/en-us/azure/virtual-machines/sizes')
- [BYOL, Hybrid Benefit](https://learn.microsoft.com/en-us/azure/virtual-machines/windows/hybrid-use-benefit-licensing)
*/

// ================================================= Parameters =================================================
@description('Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location.')
param location string = resourceGroup().location

@description('Select the OS type to deploy:')
@allowed([
  'Windows'
  'Linux'
])
param operatingSystem string

@description('''
The name of the virtual machine to be upserted.
Min length: 1
Max length: 15 for windows & 64 for linux.
''')
@minLength(1)
@maxLength(64)
param virtualMachineName string

@description('''
The tags to apply to this resource. This is an object with key/value pairs.
Example:
{
  FirstTag: myvalue
  SecondTag: another value
}
''')
param tags object = {}

@description('Specifies the resource id of the subnet where the default NIC should be onboarded into. If you don\'t fill the `networkInterfaces` parameter, this parameter is required.')
param virtualMachineSubnetResourceId string = ''

@description('Specifies the type of authentication when accessing the Virtual Machine. SSH key is recommended for Linux.')
@allowed([
  'sshPublicKey'
  'password'
])
param virtualMachineAuthenticationMethod string = 'password'

@description('Specifies the name of the administrator account of the virtual machine.')
@minLength(1)
@maxLength(32)
param virtualMachineAdminUsername string

@description('''
Specifies the SSH Key or password for the virtual machine. SSH key is recommended for Linux.
For password: Please enter the password as a string.
For SSH keys: Please pass the SSH key as a string. This can be done for example using loadTextContent('publickey.pub') to load the text from the publickey.pub file which holds the public part of the SSH key.

To import a string (either password or SSH-key) you also have the option to do this securely using a keyvault. You can, for example, reference an existing keyvault and call the getSecret() method on it to fetch the secret to input into this module.
''')
@secure()
@minLength(12)
param virtualMachineAdminPasswordOrPublicKey string

@description('Specifies the size of the virtual machine. For more options, please refer to https://docs.microsoft.com/en-us/azure/virtual-machines/sizes')
param virtualMachineSize string = 'Standard_D1_v2'

@description('''
This is the configuration for the OS Disk for this virtual machine. For formatting & options, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.compute/virtualmachines?pivots=deployment-language-bicep#osdisk.
''')
param osDisk object = {
  name: 'osdisk-${virtualMachineName}'
  caching: 'ReadWrite'
  createOption: 'FromImage'
  diskSizeGB: 100
  managedDisk: {
    storageAccountType: 'StandardSSD_LRS'
  }
}

@description('''
The datadisk configuration for this VM.
Defaults to no datadisks.

For easy creation of new Empty Datadisks, you can use this example:
dataDisks: [for j in range(0, numberOfDataDisks): {
  caching: 'ReadWrite'
  diskSizeGB: 200
  lun: j
  name: 'disk-${j >= 10 ? '${j}' : '0${j}'}-${virtualMachineName}'
  createOption: 'Empty'
  managedDisk: {
    storageAccountType: 'StandardSSD_LRS'
  }
}]
''')
param dataDisks array = []

@description('''
The array of network interfaces to create for this VM. For formatting & options please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.compute/virtualmachines?pivots=deployment-language-bicep#networkinterfacereference.

If you leave this empty, this script will create 1 default NIC for you. If you fill this, the default option will be omitted/skipped.

Simple example with 1 NIC:
networkInterfaces: [
  {
    id: '/subscriptions/$(SubscriptionId)/resourceGroups/$(ResourceGroupName)/providers/Microsoft.Network/networkInterfaces/$(NetworkInterfaceName)'
  }
]
''')
param networkInterfaces array = []

@description('''
Define the image you want to use for this VM. For formatting & options, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.compute/virtualmachines?pivots=deployment-language-bicep#imagereference.
Example:
{
  publisher: 'Canonical'
  offer: '0001-com-ubuntu-server-focal'
  sku: '20_04-lts'
  version: 'latest'
}
Other examples:
Among others, options are:
`publisher`: Canonical (for Ubuntu), RedHat (for Red Hat Linux), MicrosoftWindowsServer (for Windows Server).
`offer`: UbuntuServer (for Ubuntu), RHEL for (Red Hat Linux), WindowsServer (for Windows Server)
`sku`: 18.04-LTS (for Ubuntu) , 7.8 (for Red Hat Linux), 2019-Datacenter (for Windows Server)
''')
param virtualMachineImageReference object = {
  publisher: 'MicrosoftWindowsServer'
  offer: 'WindowsServer'
  sku: '2019-Datacenter'
  version: 'latest'
}

@description('Specifies the name of the storage account where the bootstrap diagnostic logs of the virtual machine are stored. Leave empty to disable boot diagnostics.')
@maxLength(24)
param bootDiagnosticsStorageAccountName string = ''

@description('''If this parameter is filled, a availabilitySet will be upserted & the VM will be added to the availabilitySet. This parameter defines the name for that availabilitySet. If you leave this empty, the VM will not be added to any availabilitySets
You cannot both have Availability Zone and Availability Set specified. Deploying an Availability Set to an Availability Zone is not supported.
''')
@maxLength(80)
param availabilitySetName string = ''

@description('The amount of fault domains you want to assign to this availabilityset.')
@minValue(1)
@maxValue(20)
param availabilitySetPlatformFaultDomainCount int = 3

@description('The amount of update domains you want to assign to this availabilityset.')
@minValue(1)
@maxValue(20)
param availabilitySetPlatformUpdateDomainCount int = 5

@description('The name of the NIC for this VM. Defaults to nic-<vmBaseName>-<environmentType>.')
@maxLength(80)
param virtualMachineNetworkInterfaceName string = 'nic-${take(virtualMachineName, 76)}'

@description('''
A list of resource id\'s referencing to the backend address pools of the loadbalancer.
NOTE: If you use the `networkInterfaces` parameter, this value is not used.
Example:
[
  '/resource/id/to/my/backEndAddressPool'
  '/resource/id/to/my/backEndAddressPool'
]
''')
param loadBalancerBackendAddressPoolResourceIds array = []
@description('''
A list of resource id\'s referencing to the inbound nat rules of the loadbalancer.
NOTE: If you use the `networkInterfaces` parameter, this value is not used.
Example:
[
  '/resource/id/to/my/natRule'
  '/resource/id/to/my/natRule2'
]
''')
param loadBalancerInboundNatRuleResourceIds array = []

@description('''
Enable Accelerated Networking for the vm\'s default interface. Defaults to `false`.
NOTE: If you use the `networkInterfaces` parameter, this value is not used.
''')
param enableAcceleratedNetworking bool = false

@description('''The Azure availability zones your Virtual Machine can be in. See https://docs.microsoft.com/en-us/azure/availability-zones/az-overview.
Example:
[1]
You cannot both have Availability Zone and Availability Set specified. Deploying an Availability Set to an Availability Zone is not supported.
''')
@maxLength(1)
param availabilityZones array = []

@description('If you want to have bootdiagnostics enabled on the Virtual Machine. More info https://docs.microsoft.com/en-us/azure/virtual-machines/boot-diagnostics.')
param bootdiagnosticsEnabled bool = true

@description('If the provision agent should be installed.')
param provisionVMAgent bool = true

@description('The bicep object to configure the linux vm configuration when creating the vm.')
param linuxConfiguration object = {}

@description('The bicep object to configure the Windows vm configuration when creating the vm.')
param windowsConfiguration object = {
  enableAutomaticUpdates: true
  patchSettings: {
    patchMode: 'AutomaticByOS'
    assessmentMode: 'ImageDefault'
  }
  enableVMAgentPlatformUpdates: false
}

@description('''
This property can be used by user in the request to enable or disable the Host Encryption for the virtual machine or virtual machine scale set. 
This will enable the encryption for all the disks including Resource/Temp disk at host itself.

For Linux operating systems this is a mandatory to be set to True.
Azure Policy controling this is described here [Virtual machines and virtual machine scale sets should have encryption at host enabled](https://www.azadvertizer.com/azpolicyadvertizer/fc4d8e41-e223-45ea-9bf5-eada37891d87.html) 
''')
param encryptionAtHost bool = false

@description('''
Type of OS licensing.
For customers with Software Assurance, Azure Hybrid Benefit for Windows Server allows you to use your on-premises Windows Server licenses and run Windows virtual machines on Azure at a reduced cost.
You can use Azure Hybrid Benefit for Windows Server to deploy new virtual machines with Windows OS.
Azure Hybrid Benefit provides software updates and integrated support directly from Azure infrastructure for Red Hat Enterprise Linux (RHEL) and SUSE Linux Enterprise Server (SLES) virtual machines.
''')
@allowed([
    'RHEL_BYOS'
    'SLES_STANDARD'
    'SLES_SAP'
    'SLES_HPC'
    'SLES'
    'RHEL_SAPHA'
    'RHEL_SAPAPPS'
    'RHEL_ELS_6'
    'RHEL_EUS'
    'RHEL_BASE'
    'SLES_BYOS'
    'RHEL_BASESAPAPPS'
    'RHEL_BASESAPHA'
    'Windows_Server'
    'Windows_Client'
    'None'
    ''
])
param OSLicenseType string = ''

@description('''
Specifies a base-64 encoded string of custom data. 
The base-64 encoded string is decoded to a binary array that is saved as a file on the Virtual Machine. 
The maximum length of the binary array is 65535 bytes. 

**Note: Do not pass any secrets or passwords in customData property. **
This property cannot be updated after the VM is created. 
The property 'customData' is passed to the VM to be saved as a file, for more information see [Custom Data on Azure VMs](https://azure.microsoft.com/blog/custom-data-and-cloud-init-on-windows-azure/). 
For using cloud-init for your Linux VM, see [Using cloud-init to customize a Linux VM during creation](https://learn.microsoft.com/en-us/azure/virtual-machines/linux/using-cloud-init).
''')
param customData string = ''

@description('Union the different settings for the linux vm configuration')
var linuxConfigurationUnion = union(
  linuxConfiguration, //default configuration
  { provisionVMAgent: provisionVMAgent }, //adding the provision vm agent setting
  virtualMachineAuthenticationMethod == 'sshPublicKey' ? { //adding ssh public key authorization settings
    disablePasswordAuthentication: true
    ssh: {
      publicKeys: [
        {
          path: '/home/${virtualMachineAdminUsername}/.ssh/authorized_keys'
          keyData: virtualMachineAdminPasswordOrPublicKey
        }
      ]
    }
  } : {}
)

@description('Union the different settings for the windows vm configuration')
var windowsConfigurationUnion = union(
  windowsConfiguration, //default configuration
  { provisionVMAgent: provisionVMAgent } //adding the provision vm agent setting
)

// ================================================= Resources =================================================
@description('Upsert the availabilitySet using the given parameters if desired.')
resource availabilitySet 'Microsoft.Compute/availabilitySets@2022-03-01' = if (!empty(availabilitySetName)) {
  name: empty(availabilitySetName) ? 'dummy' : availabilitySetName
  location: location
  properties: {
    platformFaultDomainCount: availabilitySetPlatformFaultDomainCount
    platformUpdateDomainCount: availabilitySetPlatformUpdateDomainCount
  }
  sku: {
    name: 'Aligned'
  }
}

@description('Upsert the NIC using the given parameters. Only when the `networkInterfaces` is left empty.')
module virtualMachineNetworkInterface '../Network/networkInterfaces.bicep' = if (length(networkInterfaces) <= 0) {
  name: format('{0}-{1}', take('${deployment().name}', 47), 'networkInterface')
  scope: az.resourceGroup()
  params: {
    location: location
    subnetResourceId: virtualMachineSubnetResourceId
    enableAcceleratedNetworking: enableAcceleratedNetworking
    loadBalancerBackendAddressPoolResourceIds: loadBalancerBackendAddressPoolResourceIds
    loadBalancerInboundNatRuleResourceIds: loadBalancerInboundNatRuleResourceIds
    privateIPAllocationMethod: 'Dynamic'
    tags: tags
    networkInterfaceName: virtualMachineNetworkInterfaceName
  }
}

@description('Fetch the storageaccount used for boot diagnostics if desired.')
resource bootDiagnosticsStorageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' existing = if (!empty(bootDiagnosticsStorageAccountName)) {
  name: bootDiagnosticsStorageAccountName
}

@description('Upsert the Virtual Machine with the given parameters.')
resource virtualMachine 'Microsoft.Compute/virtualMachines@2022-03-01' = {
  name: virtualMachineName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    hardwareProfile: {
      vmSize: virtualMachineSize
    }
    licenseType: empty(OSLicenseType) ? null : OSLicenseType
    osProfile: {
      computerName: virtualMachineName
      adminUsername: virtualMachineAdminUsername
      adminPassword: virtualMachineAdminPasswordOrPublicKey
      linuxConfiguration: operatingSystem == 'Linux' ? linuxConfigurationUnion : null
      windowsConfiguration: operatingSystem == 'Windows' ? windowsConfigurationUnion : null
      customData: customData
    }
    storageProfile: {
      imageReference: virtualMachineImageReference
      osDisk: osDisk
      dataDisks: dataDisks
    }
    securityProfile: {
      encryptionAtHost: encryptionAtHost
    }
    availabilitySet: (!empty(availabilitySetName)) ? { id: availabilitySet.id } : null
    networkProfile: {
      networkInterfaces: length(networkInterfaces) <= 0 ? [ { id: virtualMachineNetworkInterface.outputs.networkInterfaceResourceId } ] : networkInterfaces
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: bootdiagnosticsEnabled
        storageUri: !empty(bootDiagnosticsStorageAccountName) ? bootDiagnosticsStorageAccount.properties.primaryEndpoints.blob : null
      }
    }
  }
  zones: availabilityZones
  dependsOn: !empty(availabilitySetName) ? [
    availabilitySet
  ] : []
}

@description('Output the availability set\'s Resource ID.')
output availabilitysetResourceId string = !empty(availabilitySetName) ? availabilitySet.id : ''
@description('Outputs the name of the virtual machine created or upserted')
output virtualMachineName string = virtualMachine.name
@description('Output the resourceId of the virtual machine created or upserted')
output virtualMachineResourceId string = virtualMachine.id
