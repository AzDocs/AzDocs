[[_TOC_]]

# Description
This snippet will Add an IP range from the whitelist so that the function app or SCM-part of the function app can be accessed by the given ip range. Please note that does not work if the function app has a private endpoint. So this should not work for a regular function app that is bound to the compliancy rules.

# Parameters
Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.
| Parameter | Example Value | Description |
|--|--|--|
| FunctionAppResourceGroupName | `MyTeam-SomeApi-$(Release.EnvironmentName)` | The resourcegroup where the AppService resides in. |
| FunctionAppName | `Function-App-name` | Name of the app service to set the whitelist on. | 
| AccessRestrictionRuleName | `Hosted Agent` | Name of the Rule to add to the whitelist  |
| CIDRToWhitelist | `1.2.3.4/32` | IP range in [CIDR](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing) notation that should be whitelisted |  
| WhiteListMyIp | Switch to enable whitelisting the machine's ip where you're running the script from |
| FunctionAppDeploymentSlotName | `staging` | Name of the deployment slot to add ip whitelisting to. This is an optional field. |
| AccessRestrictionAction | `Deny` | The access restriction can be changed here. Value can be 'Allow' or 'Deny'. Default value is 'Allow' (this is an optional field). | 
| Priority | `10` | The priority can be changed here. Default value is '10' (this is an optional field) |

# Code
[Click here to download this script](../../../../src/Functions/Add-IP-Whitelist-for-Function-App.ps1)

#Links

- [CIDR notation](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing)
- [Azure cli access restriction](https://docs.microsoft.com/en-us/cli/azure/functionapp/config/access-restriction?view=azure-cli-latest#az_functionapp_config_access_restriction)

