/*
.SYNOPSIS
Runs a command on a Virtual Machine
.DESCRIPTION
Runs a command on a Virtual machine with the given specs.
.EXAMPLE
<pre>
module winvmruncmd 'runCommands.bicep' = {
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
.LINKS
- [Bicep Microsoft.Compute virtualMachines runCommand](https://learn.microsoft.com/en-us/azure/templates/microsoft.compute/virtualmachines/runcommands?pivots=deployment-language-bicep)
- [Bicep use runcommands](https://github.com/tyconsulting/BlogPosts/tree/master/Azure-Bicep/vm-run-cmd)
*/

// ================================================= Parameters =================================================

@description('''
The name for the Run Command resource.
Example:
'${virtualMachineName}/myScriptName'
''')
param runCommandsName string

@description('The Virtual Machine location.')
param location string = resourceGroup().location

@description('Optional. If set to true, provisioning will complete as soon as the script starts and will not wait for script to complete.')
param asyncExecution bool = false

@description('''
Optional. The Azure storage blob where script error stream can be uploaded to. Upload a blob (e.g error.txt) and create a SAS token.
The template deployment outputs do not include the script execution outputs.
If you want to see the err outputs you can see it in the blobs using the errorBlobUri parameters.
Once the execution is completed, you will be able to download the output from blob container in the Storage Account.
Make sure to use unique blob names with multiple vm runs or they will be overwritten.
Example:
'https://stgaccountname.${environment().suffixes.storage}/error?sp=racwdl&st=2022-10-10T12:22:15Z&se=2022-10-10T20:22:15Z&spr=https&sv=2021-06-08&sr=c&sig=TOyBPkQIDISVjIxNeXy0lM1Nbne%2FyP5EydXH3juOLY%3D'
''')
param errorBlobUri string = ''

@description('''
Optional. The Azure storage blob where script output stream can be uploaded to. Upload a blob (e.g output.txt) and create a SAS token.
The template deployment outputs do not include the script execution outputs.
If you want to see stdout outputs you can see it in the blobs using the outputBlobUri parameters.
Once the execution is completed, you will be able to download the output from blob container in the Storage Account.
Make sure to use unique blob names with multiple vm runs or they will be overwritten.
Example:
'https://stgaccountname.${environment().suffixes.storage}/output?sp=racwdl&st=2022-10-10T12:22:15Z&se=2022-10-10T20:22:15Z&spr=https&sv=2021-06-08&sr=c&sig=TOyBPkQIDISVjIxNeXy0lM1Nbne%2FyP5EydXH3juOLQY%3'
''')
param outputBlobUri string = ''

@description('''
The parameters used by the script. Required properties for Windows VMs are: name, value, and for Linux VMs are: value
Example:
[
  {
    name: 'adminUsers'
    value: 'domain\\username'
  }
]
''')
param scriptParameters array = []

@description('The protected parameters used by the script. Required properties for Windows VMs are: name, value, and for Linux VMs are: value')
param protectedScriptParameters array = []

@description('''
Specifies a commandId of predefined built-in script. i.e. \'RunPowerShellScript\' for Windows or \'RunShellScript\' for Linux
Do not specify this parameter together with the 'script' or 'scriptUri' parameters.
''')
@allowed([
  'RunPowerShellScript'
  'DisableNLA'
  'DisableWindowsUpdate'
  'EnableAdminAccount'
  'EnableEMS'
  'EnableRemotePS'
  'EnableWindowsUpdate'
  'IPConfig'
  'RDPSetting'
  'ResetRDPCert'
  'SetRDPPort'
  'RunShellScript'
  'ifconfig'
  ''
])
param commandId string = ''

@description('The script content to be executed on the VM. required when the commandId and scriptUri are not specified.')
param script string = ''

@description('The script download location. required when the commandId and script are not specified.')
param scriptUri string = ''

@description('The timeout in seconds to execute the run command. Minimum value is 120 seconds (2 minutes) and default value is 300 seconds (5 minutes). Maximum value is 5400 seconds (90 minutes).')
@minValue(120)
@maxValue(5400)
param timeoutInSeconds int = 120

@description('RunPowerShellScript for Windows and RunShellScript for Linux is not required when the commandId is specified.')
var commandIdVar = commandId =~ 'RunPowerShellScript' || commandId =~ 'RunShellScript' ? '' : commandId

var scriptSource = {
  script: script
}

var scriptUriSource = {
  scriptUri: scriptUri
}

var commandIdSource = {
  commandId: commandIdVar
}

var scriptUriVar = empty(scriptUri) ? null : scriptUri

var sourceVar = empty(commandIdVar) ? (empty(scriptUri) ? scriptSource : scriptUriSource) : commandIdSource

resource vmRunCmd 'Microsoft.Compute/virtualMachines/runCommands@2021-07-01' = {
  name: runCommandsName
  location: location
  properties: {
    asyncExecution: asyncExecution
    errorBlobUri: errorBlobUri
    outputBlobUri: outputBlobUri
    parameters: scriptParameters
    protectedParameters: protectedScriptParameters
    source: sourceVar
    timeoutInSeconds: timeoutInSeconds
  }
}

@description('Outputs the id of the vmRunCmd')
output id string = vmRunCmd.id
@description('Outputs the source of the vmRunCmd')
output source object = sourceVar
@description('Outputs the name of the vmRunCmd')
output name string = vmRunCmd.name
@description('Outputs the result of the vmRunCmd')
output result object = vmRunCmd
