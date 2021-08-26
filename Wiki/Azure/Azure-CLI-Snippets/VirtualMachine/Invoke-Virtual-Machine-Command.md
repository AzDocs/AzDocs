[[_TOC_]]

# Description
This snippet will execute a command on a Virtual Machine.

# Parameters
| Parameter                        | Required                        | Example Value                               | Description                                                              |
| -------------------------------- | ------------------------------- | ------------------------------------------- | ------------------------------------------------------------------------ |
| VirtualMachineResourceGroupName  | <input type="checkbox" checked> | `myteam-testapi-$(Release.EnvironmentName)` | The name of the resource group where the virtual machine will reside in. |
| VirtualMachineBaseName           | <input type="checkbox" checked> | `win2019serv`                               | Prefix of the vm name, example `winsrv` for `winsrv01`                   |
| VirtualMachineOS                 | <input type="checkbox" checked> | `Windows`                                   | Type of OS the virtual has. Can be `Windows` or `Linux`                  |
| CommandToExecuteOnVirtualMachine | <input type="checkbox" checked> | `Write-Host 'abba'`                         | The script to run on the VM                                              |

# YAML task

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
      - task: AzurePowerShell@5
         displayName: 'Add cur admins to remote desktop users group'
         condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
         inputs:
            azureSubscription: '${{ parameters.SubscriptionName }}'
            ScriptType: 'FilePath'
            scriptPath: '$(Pipeline.Workspace)/AzDocs/VirtualMachine/Invoke-Virtual-Machine-Command.ps1'
            azurePowerShellVersion: 'LatestVersion'
            ScriptArguments:
               -VirtualMachineResourceGroupName '$(ResourceGroupName)'
               -VirtualMachineBaseName '$(VirtualMachineBaseName)'
               -VirtualMachineOS 'Windows'
               -CommandToExecuteOnVirtualMachine  'Add-LocalGroupMember -Group "Remote Desktop Users" -Member "$(DomainAdminGroup)"'
```

# Code
[Click here to download this script](../../../../src/VirtualMachine/Create-Virtual-Machine-From-Image.ps1)


# Links

[Azure CLI - az vm create](https://docs.microsoft.com/en-us/cli/azure/vm?view=azure-cli-latest#az_vm_create)