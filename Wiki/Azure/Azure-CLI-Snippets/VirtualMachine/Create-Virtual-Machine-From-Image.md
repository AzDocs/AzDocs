[[_TOC_]]

# Description
This snippet will create a Virtual machine from an image. The virtual machine name will be the base name and appended with an ascending number.
For example, if there are 2 vm's needed, with a `VirtualMachineBaseName` of 'winsrv' and `VirtualMachineTotalCount` of 2, the following vm's are created:
- winsrv01
- winsrv02

If the same script runs with `VirtualMachineTotalCount` of 4, the first two are not touched, and 2 extra vm's are created:
- winsrv03
- winsrv04

If you would remove winsrv03 and run the script again, only winsrv03 will be created.

# Parameters
| Parameter                           | Required                        | Example Value                                                                                                                       | Description                                                                                                                                    |
| ----------------------------------- | ------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| VirtualMachineResourceGroupName     | <input type="checkbox" checked> | `myteam-testapi-$(Release.EnvironmentName)`                                                                                         | The name of the resource group where the Virtual Machine will reside in.                                                                       |
| VirtualMachineBaseName              | <input type="checkbox" checked> | `win2019serv`                                                                                                                       | Prefix of the vm name, example `winsrv` for `winsrv01`                                                                                         |
| VirtualMachineTotalCount            | <input type="checkbox" checked> | `2`                                                                                                                                 | Number of virtual machines to have. Number of vm's create is depended on how many vm's with the proper name are already in the resource group. |
| VirtualMachineImageName             | <input type="checkbox" checked> | `win2019` or `/subscriptions/{subscriptionId}/resourceGroups/{resourceGoupName}/providers/Microsoft.Compute/images/{name of image}` | The name of the Azure Image in the same resourcegroup or resourceid of the Azure image.                                                        |
| VirtualmachineAdminUsername         | <input type="checkbox" checked> | `admin`                                                                                                                             | The name of Virtual Machine's Administrator account                                                                                            |
| VirtualmachineAdminPassword         | <input type="checkbox" checked> | `passwrd`                                                                                                                           | The password of the Virtual Machine's Administrator account                                                                                    |
| VirtualMachineVnetResourceGroupName | <input type="checkbox" checked> | `sharedservices-rg`                                                                                                                 | The ResourceGroup name of the VNet where the Virtual Machine's network interface will be in.                                                   |
| VirtualMachineVnetName              | <input type="checkbox" checked> | `my-vnet-$(Release.EnvironmentName)`                                                                                                | The name of the VNet where the Virtual Machine's network interface will be in.                                                                 |
| VirtualMachineSubnetName            | <input type="checkbox" checked> | `app-subnet-4`                                                                                                                      | The name of the subnet the Virtual Machine's network interface will be in.                                                                     |
| VirtualMachineAvailabilitySetName   | <input type="checkbox">         | `win2019serv-avail`                                                                                                                 | Name of the availability set to add the vm's to.                                                                                                |
| VirtualMachineSizeSku               | <input type="checkbox">         | `Standard_DS1_v2`                                                                                                                   | Name of the SKU (size and options) for the VM(s) to be created.                                                                                |
| VirtualMachineStorageSku            | <input type="checkbox">         | `Standard_LRS`                                                                                                                      | Name of SKU for the disks for the VM(s) to be created.                                                                                         |
| ResourceTagForVirtualMachineName    | <input type="checkbox">         | `VMName`                                                                                                                            | Optional tag for the VM to be created.                                                                                                 |


# YAML task

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
        - task: AzureCLI@2
           displayName: 'Create VirtualMachine'
           condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
           inputs:
               azureSubscription: '${{ parameters.SubscriptionName }}'
               scriptType: pscore
               scriptPath: '$(Pipeline.Workspace)/AzDocs/VirtualMachine/Create-Virtual-Machine-From-Image.ps1'
               arguments:
                  -VirtualMachineResourceGroupName '$(VirtualMachineResourceGroupName)'
                  -VirtualMachineBaseName '$(VirtualMachineBaseName)'
                  -VirtualMachineTotalCount '$(VirtualMachineCount)'
                  -VirtualMachineImageName '$(VirtualMachineImageName)'
                  -VirtualMachineAdminUsername '$(VirtualMachineAdminUsername)'
                  -VirtualMachineAdminPassword '$(VirtualMachineAdminPassword)'
                  -VirtualmachineVnetResourceGroupName '$(VirtualMachineVnetResourceGroupName)'
                  -VirtualMachineVnetName '$(VirtualMachineVnetName)'
                  -VirtualMachineSubnetName '$(VirtualMachineSubnetName)'
                  -VirtualMachineAvailabilitySetName '$(VirtualMachineBaseName)-avail'
                  -VirtualMachineSizeSku 'Standard_B4ms'
                  -VirtualMachineStorageSku 'StandardSSD_LRS'
                  -ResourceTagForVirtualMachineName 'VMName'
                  -ResourceTags $(ResourceTagsVM)
```

# Code

[Click here to download this script](../../../../src/VirtualMachine/Create-Virtual-Machine-From-Image.ps1)


# Links

[Azure CLI - az vm create](https://docs.microsoft.com/en-us/cli/azure/vm?view=azure-cli-latest#az_vm_create)