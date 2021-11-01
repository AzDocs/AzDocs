[[_TOC_]]

# Description

This snippet will wait until the given extension is installed on the Virtual Machine.

# Parameters

| Parameter                       | Required                        | Example Value                               | Description                                                                                                                                                                                                                            |
| ------------------------------- | ------------------------------- | ------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| VirtualMachineResourceGroupName | <input type="checkbox" checked> | `myteam-testapi-$(Release.EnvironmentName)` | The name for the resource group where your Virtual Machine resides in.                                                                                                                                                                 |
| VirtualMachineBaseName          | <input type="checkbox" checked> | `win2019serv`                               | Prefix of the vm name, example `winsrv` for `winsrv01`                                                                                                                                                                                 |
| VirtualMachineExtensionName     | <input type="checkbox" checked> | `JoinDomain`                                | Name of the extension to wait for                                                                                                                                                                                                      |
| VirtualMachineExtensionState    | <input type="checkbox">         | `InProgress`                                | The state to wait for for example, by default it waits for the `Succeeded` state if this parameter is not supplied. For values see [here](https://docs.microsoft.com/en-us/rest/api/azurestack/vm-extensions/create#provisioningstate) |

# YAML task

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Wait until the vm has the proper extension for joining the domain"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/VirtualMachine/Wait-Until-Extension-Found.ps1"
    arguments:
      -VirtualMachineResourceGroupName '$(VirtualMachineResourceGroupName)'
      -VirtualMachineBaseName '$(VirtualMachineBaseName)'
      -VirtualmachineExtensionName 'JoinDomain'
      -VirtualMachineExtensionState 'Failed'
```

# Code

[Click here to download this script](../../../../src/VirtualMachine/Wait-Until-Extension-Found.ps1)

# Links

- [Azure CLI - az vm create](https://docs.microsoft.com/en-us/cli/azure/vm/extension?view=azure-cli-latest#az_vm_extension_list)

- [Azure Rest API - vm-extensions - provisioning state](https://docs.microsoft.com/en-us/rest/api/azurestack/vm-extensions/create#provisioningstate)
