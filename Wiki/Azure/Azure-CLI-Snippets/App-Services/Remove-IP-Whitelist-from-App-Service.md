[[_TOC_]]

# Description
This snippet will remove an IP range from the whitelist so that the website or SCM-part of the website cannot be accessed by the given ip range. Please note that does not work if the website has a private endpoint. So this should not work for a regular website that is bound to the compliancy rules.

> NOTE: It is strongly suggested to set the condition, of this task in the pipeline, to always run. Even if your previous steps have failed. This is to avoid unintended whitelists whenever pipelines crash in the middle of something.

# Parameters
Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.
| Parameter | Required | Example Value | Description |
|--|--|--|--|
| AppServiceResourceGroupName | <input type="checkbox" checked> | `MyTeam-SomeApi-$(Release.EnvironmentName)` | The resourcegroup where the AppService resides in. |
| AppServiceName | <input type="checkbox" checked> | `App-Service-name` | Name of the app service to set the whitelist on. | 
| AccessRestrictionRuleName | <input type="checkbox"> | `company hq` | OPTIONAL: You can override the name for this accessrule. If you leave this empty, the CIDRToRemoveFromWhitelist will be used for the naming (automatically). |
| CIDRToRemoveFromWhitelist | <input type="checkbox"> | `1.2.3.4/32` | IP range in [CIDR](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing) notation that should be removed from thge whitelist. If you leave this value empty, it will use the machine's outbound ip (the machine where you are running this script from). |  
| AppServiceDeploymentSlotName | <input type="checkbox"> | `staging` |  Name of the deployment slot to add ip whitelisting to. This is an optional field. |
| ApplyToAllSlots | <input type="checkbox"> | `$true`/`$false` | Applies the current script to all slots revolving this resource |

# Code
[Click here to download this script](../../../../src/App-Services/Remove-Ip-Whitelist-For-App_service.ps1)