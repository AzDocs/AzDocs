[[_TOC_]]

# Description
This snippet will Add an IP range from the whitelist so that the website or SCM-part of the website can be accessed by the given ip range. Please note that does not work if the website has a private endpoint. So this should not work for a regular website that is bound to the compliancy rules.

# Parameters
Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.
| Parameter | Example Value | Description |
|--|--|--|
| AppServiceResourceGroupName | `MyTeam-SomeApi-$(Release.EnvironmentName)` | The resourcegroup where the AppService resides in. |
| AppServiceName | `App-Service-name` | Name of the app service to set the whitelist on. | 
| AccessRestrictionRuleName | `Hosted Agent` | Name of the Rule to add to the whitelist  |
| CIDRToWhitelist | `1.2.3.4/32` | IP range in [CIDR](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing) notation that should be whitelisted |  
| WhiteListMyIp | Switch to enable whitelisting the machine's ip where you're running the script from |
| AppServiceDeploymentSlotName | `staging` | Name of the deployment slot to add ip whitelisting to. This is an optional field. |
| AccessRestrictionAction | `Deny` | The access restriction can be changed here. Value can be 'Allow' or 'Deny'. Default value is 'Allow' (this is an optional field). | 
| Priority | `10` | The priority can be changed here. Default value is '10' (this is an optional field) |
| ApplyToAllSlots | `$true`/`$false` | Applies the current script to all slots revolving this resource |

# Code
[Click here to download this script](../../../../src/App-Services/Add-IP-Whitelist-for-App-Service.ps1)

#Links

- [CIDR notation](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing)
- [Azure cli access restriction](https://docs.microsoft.com/en-us/cli/azure/webapp/config/access-restriction?view=azure-cli-latest)

