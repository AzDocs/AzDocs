[[_TOC_]]

# Description

This snippet will remove an IP range from the whitelist so that the function app or SCM-part of the function app cannot be accessed by the given ip range. Please note that does not work if the function app has a private endpoint. So this should not work for a regular function app that is bound to the compliancy rules.

# Parameters

Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.
| Parameter | Required | Example Value | Description |
|--|--|--|--|
| FunctionAppResourceGroupName | <input type="checkbox" checked> | `MyTeam-SomeApi-$(Release.EnvironmentName)` | The resourcegroup where the function app resides in. |
| FunctionAppName | <input type="checkbox" checked> | `Function-App-name` | Name of the function app to set the whitelist on. |
| AccessRestrictionRuleName | <input type="checkbox"> | `company hq` | You can delete an accessrule based on it's rulename. If you leave this empty, it will take the `CIDRToRemoveFromWhitelist` to delete the IP address/range. |
| CIDRToRemoveFromWhitelist | <input type="checkbox"> | `1.2.3.4/32` | IP range in [CIDR](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing) notation that should be removed from the whitelist. If you leave this value empty, it will use the machine's outbound `/32` ip (the machine where you are running this script from). |
| FunctionAppDeploymentSlotName | <input type="checkbox"> | `staging` | Name of the deployment slot to add ip whitelisting to. This is an optional field. |
| ApplyToAllSlots | <input type="checkbox"> | `$true`/`$false` | Applies the current script to all slots revolving this resource |
| ApplyToMainEntrypoint | <input type="checkbox"> | `$true`/`$false` | Allows you to enable/disable applying this rule to the main entrypoint of this webapp. Defaults to `$true` |
| ApplyToScmEntrypoint | <input type="checkbox"> | `$true`/`$false` | Allows you to enable/disable applying this rule to the scm entrypoint of this webapp. Defaults to `$true` |
| SubnetToRemoveSubnetName | <input type="checkbox"> | `gateway2-subnet` | The name of the subnet you want to remove from the whitelist.|
| SubnetToRemoveVnetName | <input type="checkbox"> | `sp-dc-dev-001-vnet` | The vnetname of the subnet you want to remove from the whitelist. |
| SubnetToRemoveVnetResourceGroupName | <input type="checkbox"> | `sharedservices-rg` | The VnetResourceGroupName your Vnet resides in. |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Remove Network Whitelist from Function App"
  condition: always()
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/Functions/Remove-Network-Whitelist-from-Function-App.ps1"
    arguments: "-FunctionAppResourceGroupName '$(FunctionAppResourceGroupName)' -FunctionAppName '$(FunctionAppName)' -AccessRestrictionRuleName '$(AccessRestrictionRuleName)' -CIDRToRemoveFromWhitelist '$(CIDRToRemoveFromWhitelist)' -FunctionAppDeploymentSlotName '$(FunctionAppDeploymentSlotName)' -ApplyToAllSlots $(ApplyToAllSlots) -ApplyToMainEntrypoint '$(ApplyToMainEntrypoint)' -ApplyToScmEntrypoint '$(ApplyToScmEntrypoint)' -SubnetToRemoveSubnetName '$(SubnetToRemoveSubnetName)' -SubnetToRemoveVnetName '$(SubnetToRemoveVnetName)' -SubnetToRemoveVnetResourceGroupName '$(SubnetToRemoveVnetResourceGroupName)'"
```

# Code

[Click here to download this script](../../../../src/Functions/Remove-IP-Whitelist-from-Function-App.ps1)
