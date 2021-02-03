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

# Code
[Click here to download this script](../../../../src/App-Services/Add-IP-Whitelist-for-App-Service.ps1)

#Links

- [CIDR notation](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing)
- [Azure cli access restriction](https://docs.microsoft.com/en-us/cli/azure/webapp/config/access-restriction?view=azure-cli-latest)

