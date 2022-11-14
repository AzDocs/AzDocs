[[_TOC_]]

# Description

Add the service tag for Front Door to an Appservice or a function app.

# Parameters

| Parameter                                       | Required                        | Example Value                                 | Description                                                                                                            |
| ----------------------------------------------- | ------------------------------- | --------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| AppType                                         | <input type="checkbox" checked> | `functionapp`/`webapp`                        | The apptype.                                                                                                           |
| ResourceGroupName                               | <input type="checkbox" checked> | `rg-$(Release.EnvironmentName)`               | The name of the resourcegroup the resource resides in.                                                                 |
| ResourceName                                    | <input type="checkbox" checked> | `myruleset`                                   | The name of the resource.                                                                                              |
| AccessRestrictionRuleName                       | <input type="checkbox" checked> | `service-tag`                                 | The name of the Access Restriction rule.                                                                               |
| ServiceTag                                      | <input type="checkbox" checked> | `AzureFrontDoor.Backend`                      | The name of the Service Tag.                                                                                           |
| ServiceTagHttpHeaders                           | <input type="checkbox">         | `X-Azure-FDID=id X-Forwarded-For=123.123.123` | The headers you want to add to the service tag. The headers follow the above template and the list is space-separated. |
| AccessRestrictionRuleDescription                | <input type="checkbox" >        | `this is my restriction`                      |
| The description of the Access Restriction rule. |
| DeploymentSlotName                              | <input type="checkbox">         | `staging-slot`                                | The name of the deployment slot name.                                                                                  |
| AccessRestrictionAction                         | <input type="checkbox">         | `Allow`/`Deny`                                | The Access Restriction Action. Defaults to `Allow`.                                                                    |
| Priority                                        | <input type="checkbox">         | `10`                                          | The priority of the Access Restriction rule. Defaults to `10`.                                                         |
| ApplyToMainEntrypoint                           | <input type="checkbox">         | `$true`/`$false`                              | Apply to the main entry point. Defaults to `$true`.                                                                    |
| ApplyToScmEntrypoint                            | <input type="checkbox">         | `$true`/`$false`                              | Apply to the scm entry point. Defaults to `$true`.                                                                     |
| ApplyToAllSlots                                 | <input type="checkbox">         | `$true`/`$false`                              | If the access restriction should be applied to all slots. Defaults to `$true`.                                         |


# YAML task

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Add Front Door Service Tag To Resource"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/Front-Door/Add-Front-Door-ServiceTag-To-Resource.ps1"
    arguments: >
        -AppType '$(AppType)'
        -ResourceGroupName '$(ResourceGroupName)'
        -ResourceName '$(ResourceName)'
        -AccessRestrictionRuleName '$(AccessRestrictionRuleName)'
        -ServiceTag '$(ServiceTag)'
        -ServiceTagHttpHeaders '$(ServiceTagHttpHeaders)'
        -AccessRestrictionRuleDescription '$(AccessRestrictionRuleDescription)'
        -DeploymentSlotName '$(DeploymentSlotName)'
        -AccessRestrictionAction '$(AccessRestrictionAction)'
        -Priority '$(Priority)'
        -ApplyToMainEntrypoint $(ApplyToMainEntrypoint)
        -ApplyToScmEntrypoint $(ApplyToScmEntrypoint)
        -ApplyToAllSlots $(ApplyToAllSlots)
```

# Code

[Click here to download this script](../../../../../src/Front-Door/Add-Front-Door-ServiceTag-To-Resource.ps1)

# Links

[Azure CLI - az webapp config access-restriction add](https://docs.microsoft.com/en-us/cli/azure/webapp/config/access-restriction?view=azure-cli-latest#az-webapp-config-access-restriction-add)

[Azure CLI - az functionapp config access-restriction add](https://docs.microsoft.com/en-us/cli/azure/functionapp/config/access-restriction?view=azure-cli-latest#az-functionapp-config-access-restriction-add)