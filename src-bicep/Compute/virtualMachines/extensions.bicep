/*
.SYNOPSIS
Creating an extension for a Virtual Machine
.DESCRIPTION
Creating an extension for a Virtual machine with the given specs.
.EXAMPLE
<pre>
module extensionAAD 'br:contosoregistry.azurecr.io/compute/virtualmachines/extensions:latest' = [for i in range(0, vmCount): {
  name: format('{0}-{1}', take('${deployment().name}', 41), 'aadextDeploy-${i}')
  params: {
    extensionName: '${virtualMachineName}-${i}-${environmentType}/AADSSHLoginForLinux'
    virtualMachineName: '${virtualMachineName}-${i}-${environmentType}'
    location: location
  }
  dependsOn: [
    vms
  ]
}]
</pre>
<p>Creates an extension called AADSSHLoginForLinux on a number of virtual machines with the name ${virtualMachineName}-${i}-${environmentType}</p>
.LINKS
- [Bicep Microsoft.Compute virtualMachines Extensions](https://learn.microsoft.com/en-us/azure/templates/microsoft.compute/virtualmachines/extensions?pivots=deployment-language-bicep)
*/

// ================================================= Parameters =================================================

@description('Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location.')
param location string = resourceGroup().location

@description('''
The name of the virtual machine. This need to be pre-existing.
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

@description('''
The name of the extension.
Example:
'${virtualMachineName}/AADSSHLoginForLinux'
''')
param extensionName string

@description('''
Setting up the properties for a particular extension. This cannot be empty.
For options and structure see: https://learn.microsoft.com/en-us/azure/templates/microsoft.compute/virtualmachines/extensions?pivots=deployment-language-bicep#virtualmachineextensionproperties
Example:
{
  publisher: 'Microsoft.Azure.ActiveDirectory'
  type: 'AADSSHLoginForLinux'
  typeHandlerVersion: '1.0'
  autoUpgradeMinorVersion: true
  settings: {}
  protectedSettings: {}
}
''')
param extensionProperties object = {
  publisher: 'Microsoft.Azure.ActiveDirectory'
  type: 'AADSSHLoginForLinux'
  typeHandlerVersion: '1.0'
  autoUpgradeMinorVersion: true
  settings: {}
  protectedSettings: {}
}

resource virtualMachine 'Microsoft.Compute/virtualMachines@2022-03-01' existing = {
  name: virtualMachineName
}

resource extension 'Microsoft.Compute/virtualMachines/extensions@2022-03-01' = {
  name: extensionName
  location: location
  tags: tags
  properties: extensionProperties
  dependsOn: [
    virtualMachine
  ]
}
