# runCommands

Target Scope: resourceGroup

## Synopsis
Runs a command on a Virtual Machine

## Description
Runs a command on a Virtual machine with the given specs.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| runCommandsName | string | <input type="checkbox" checked> | None | <pre></pre> | The name for the Run Command resource.<br>Example:<br>'&#36;{virtualMachineName}/myScriptName' |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | The Virtual Machine location. |
| asyncExecution | bool | <input type="checkbox"> | None | <pre>false</pre> | Optional. If set to true, provisioning will complete as soon as the script starts and will not wait for script to complete. |
| errorBlobUri | string | <input type="checkbox"> | None | <pre>''</pre> | Optional. The Azure storage blob where script error stream can be uploaded to. Upload a blob (e.g error.txt) and create a SAS token.<br>The template deployment outputs do not include the script execution outputs.<br>If you want to see the err outputs you can see it in the blobs using the errorBlobUri parameters.<br>Once the execution is completed, you will be able to download the output from blob container in the Storage Account.<br>Make sure to use unique blob names with multiple vm runs or they will be overwritten.<br>Example:<br>'https://stgaccountname.&#36;{environment().suffixes.storage}/error?sp=racwdl&st=2022-10-10T12:22:15Z&se=2022-10-10T20:22:15Z&spr=https&sv=2021-06-08&sr=c&sig=TOyBPkQIDISVjIxNeXy0lM1Nbne%2FyP5EydXH3juOLY%3D' |
| outputBlobUri | string | <input type="checkbox"> | None | <pre>''</pre> | Optional. The Azure storage blob where script output stream can be uploaded to. Upload a blob (e.g output.txt) and create a SAS token.<br>The template deployment outputs do not include the script execution outputs.<br>If you want to see stdout outputs you can see it in the blobs using the outputBlobUri parameters.<br>Once the execution is completed, you will be able to download the output from blob container in the Storage Account.<br>Make sure to use unique blob names with multiple vm runs or they will be overwritten.<br>Example:<br>'https://stgaccountname.&#36;{environment().suffixes.storage}/output?sp=racwdl&st=2022-10-10T12:22:15Z&se=2022-10-10T20:22:15Z&spr=https&sv=2021-06-08&sr=c&sig=TOyBPkQIDISVjIxNeXy0lM1Nbne%2FyP5EydXH3juOLQY%3' |
| scriptParameters | array | <input type="checkbox"> | None | <pre>[]</pre> | The parameters used by the script. Required properties for Windows VMs are: name, value, and for Linux VMs are: value<br>Example:<br>[<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;name: 'adminUsers'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;value: 'domain\\username'<br>&nbsp;&nbsp;&nbsp;}<br>] |
| protectedScriptParameters | array | <input type="checkbox"> | None | <pre>[]</pre> | The protected parameters used by the script. Required properties for Windows VMs are: name, value, and for Linux VMs are: value |
| commandId | string | <input type="checkbox"> | `'RunPowerShellScript'` or `'DisableNLA'` or `'DisableWindowsUpdate'` or `'EnableAdminAccount'` or `'EnableEMS'` or `'EnableRemotePS'` or `'EnableWindowsUpdate'` or `'IPConfig'` or `'RDPSetting'` or `'ResetRDPCert'` or `'SetRDPPort'` or `'RunShellScript'` or `'ifconfig'` or `''` | <pre>''</pre> | Specifies a commandId of predefined built-in script. i.e. \'RunPowerShellScript\' for Windows or \'RunShellScript\' for Linux<br>Do not specify this parameter together with the 'script' or 'scriptUri' parameters. |
| script | string | <input type="checkbox"> | None | <pre>''</pre> | The script content to be executed on the VM. required when the commandId and scriptUri are not specified. |
| scriptUri | string | <input type="checkbox"> | None | <pre>''</pre> | The script download location. required when the commandId and script are not specified. |
| timeoutInSeconds | int | <input type="checkbox"> | Value between 120-5400 | <pre>120</pre> | The timeout in seconds to execute the run command. Minimum value is 120 seconds (2 minutes) and default value is 300 seconds (5 minutes). Maximum value is 5400 seconds (90 minutes). |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| id | string | Outputs the id of the vmRunCmd |
| source | object | Outputs the source of the vmRunCmd |
| name | string | Outputs the name of the vmRunCmd |
| result | object | Outputs the result of the vmRunCmd |
## Examples
<pre>
module winvmruncmd 'br:contosoregistry.azurecr.io/compute/virtualmachines/runCommands:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 47), 'runWinCmd')
  params: {
    name: '${virtualMachineName}/scriptName'
    location: location
    asyncExecution: false
    scriptParameters: [
      {
        name: 'domainUsers'
        value: 'domain\\username'
      }
    ]
    script: loadTextContent('../scripts/scriptName.ps1', 'utf-8')
    timeoutInSeconds: 120
  }
}
</pre>
<p>Runs the script scriptName.ps1 on a virtual machine with the name of parameter virtualMachineName</p>

## Links
- [Bicep Microsoft.Compute virtualMachines runCommand](https://learn.microsoft.com/en-us/azure/templates/microsoft.compute/virtualmachines/runcommands?pivots=deployment-language-bicep)<br>
- [Bicep use runcommands](https://github.com/tyconsulting/BlogPosts/tree/master/Azure-Bicep/vm-run-cmd)


