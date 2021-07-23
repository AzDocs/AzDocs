[[_TOC_]]

# Description

This snippet will add a binding to the given appservice. You can also pass a slot if you want to add the binding to a specific deploymentslot

# Parameters

Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.
| Parameter | Required | Example Value | Description |
|--|--|--|--|
| AppServiceResourceGroupName | <input type="checkbox" checked> | `MyTeam-SomeApi-$(Release.EnvironmentName)` | The resourcegroup where the AppService resides in. |
| AppServiceName | <input type="checkbox" checked> | `App-Service-name` | Name of the app service to bind the domainname to. |
| DomainNameToBind | <input type="checkbox" checked> | `mysubdomain.myrootdomain.com`| The DNS entry to bind to your App Service |
| AppServiceSlotName | <input type="checkbox"> | `staging` | Name of the deployment slot to add the binding to. This is an optional field. |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
        - task: AzureCLI@2
           displayName: 'Add binding to App Service'
           condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
           inputs:
               azureSubscription: '${{ parameters.SubscriptionName }}'
               scriptType: pscore
               scriptPath: '$(Pipeline.Workspace)/AzDocs/App-Services/Add-Binding-To-App-Service.ps1'
               arguments: "-AppServiceResourceGroupName '$(AppServiceResourceGroupName)' -AppServiceName '$(AppServiceName)' -DomainNameToBind '$(DomainNameToBind)' -AppServiceSlotName '$(AppServiceSlotName)'"
```

# Code

[Click here to download this script](../../../../src/App-Services/Add-Binding-To-App-Service.ps1)
