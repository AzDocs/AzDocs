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

param extensionName string = toLower('${virtualMachineName}/AADSSHLoginForLinux')

@description('Setting up the properties.')
param properties object = {
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

resource extension'Microsoft.Compute/virtualMachines/extensions@2022-03-01' = {
  name: extensionName
  location: location
  tags: tags
  properties: properties
  dependsOn: [
    virtualMachine
  ]
}
