# extensions

Target Scope: resourceGroup

## Synopsis
Creating an extension for a Virtual Machine

## Description
Creating an extension for a Virtual machine with the given specs.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location. |
| virtualMachineName | string | <input type="checkbox" checked> | Length between 1-64 | <pre></pre> | The name of the virtual machine. This need to be pre-existing.<br>Min length: 1<br>Max length: 15 for windows & 64 for linux. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| extensionName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the extension.<br>Example:<br>'${virtualMachineName}/AADSSHLoginForLinux' |
| properties | object | <input type="checkbox"> | None | <pre>{<br>  publisher: 'Microsoft.Azure.ActiveDirectory'<br>  type: 'AADSSHLoginForLinux'<br>  typeHandlerVersion: '1.0'<br>  autoUpgradeMinorVersion: true<br>  settings: {}<br>  protectedSettings: {}<br>}</pre> | Setting up the properties. |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |
## Examples
<pre>
module extensionAAD '../modules/Compute/virtualMachines/extensions.bicep' = [for i in range(0, vmCount): {
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

## Links
- [Bicep Microsoft.Compute virtualMachines Extensions](https://learn.microsoft.com/en-us/azure/templates/microsoft.compute/virtualmachines/extensions?pivots=deployment-language-bicep)


