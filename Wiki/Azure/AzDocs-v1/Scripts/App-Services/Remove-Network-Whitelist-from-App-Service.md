[[_TOC_]]

# Description

This snippet will remove an IP range from the whitelist so that the website or SCM-part of the website cannot be accessed by the given ip range. Please note that does not work if the website has a private endpoint. So this should not work for a regular website that is bound to the compliancy rules.

> NOTE: It is strongly suggested to set the condition, of this task in the pipeline, to always run. Even if your previous steps have failed. This is to avoid unintended whitelists whenever pipelines crash in the middle of something.

# Parameters

Some parameters from [General Parameter](/Azure/AzDocs-v1/Scripts) list.
| Parameter | Required | Example Value | Description |
|--|--|--|--|
| AppServiceResourceGroupName | <input type="checkbox" checked> | `MyTeam-SomeApi-$(Release.EnvironmentName)` | The resourcegroup where the AppService resides in. |
| AppServiceName | <input type="checkbox" checked> | `App-Service-name` | Name of the app service to set the whitelist on. |
| AccessRestrictionRuleName | <input type="checkbox"> | `company hq` | You can delete an accessrule based on it's rulename. If you leave this empty, it will take the `CIDRToRemoveFromWhitelist` to delete the IP address/range. |
| CIDRToRemoveFromWhitelist | <input type="checkbox"> | `1.2.3.4/32` | IP range in [CIDR](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing) notation that should be removed from the whitelist. If you leave this value empty, it will use the machine's outbound `/32` ip (the machine where you are running this script from). |  
| AppServiceDeploymentSlotName | <input type="checkbox"> | `staging` | Name of the deployment slot to add ip whitelisting to. This is an optional field. |
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
  displayName: "Remove Network Whitelist from App Service"
  condition: always()
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/App-Services/Remove-Network-Whitelist-from-App-Service.ps1"
    arguments: "-AppServiceResourceGroupName '$(AppServiceResourceGroupName)' -AppServiceName '$(AppServiceName)' -AppServiceDeploymentSlotName '$(AppServiceDeploymentSlotName)' -ApplyToAllSlots $(ApplyToAllSlots) -ApplyToMainEntrypoint '$(ApplyToMainEntrypoint)' -ApplyToScmEntrypoint '$(ApplyToScmEntrypoint)' -AccessRestrictionRuleName '$(AccessRestrictionRuleName)' -CIDRToRemoveFromWhitelist '$(CIDRToRemoveFromWhitelist)' -SubnetToRemoveSubnetName '$(SubnetToRemoveSubnetName)' -SubnetToRemoveVnetName '$(SubnetToRemoveVnetName)' -SubnetToRemoveVnetResourceGroupName '$(SubnetToRemoveVnetResourceGroupName)'"
```

# Code

[Click here to download this script](../../../../../src/App-Services/Remove-Ip-Whitelist-For-App_service.ps1)
